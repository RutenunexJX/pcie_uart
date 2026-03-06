// =============================================================================
// tb_axi_uart_tx.sv  —  Directed Testbench for axi_uart_tx
// Vivado 2022.2 / xsim
//
// Simulation baud rate: BAUD_STEP = 2^32 / CLKS_PER_BIT
//   At 125 MHz with CLKS_PER_BIT=100 → ~1.25 Mbaud
//   Formula: baud_rate = clk_freq * BAUD_STEP / 2^32
//
// NOTE: axi_uart_tx instantiates uart_ff_8k (Xilinx FIFO Generator IP).
//       Add the IP simulation model path in Vivado project settings:
//       Project → Simulation Sources → include IP .xci or generated sim files.
//
// Test cases:
//   TC1  Single beat, full strobe  (8 bytes → 8 UART frames)
//   TC2  Partial strobe 0x0E       (bytes [1:3] only → 3 frames)
//   TC3  Multi-beat burst          (2 beats × 8B → 16 frames)
//   TC4  Odd parity                (parity bit verified per byte)
//   TC5  Invalid tx_para clamping  (parity out of range → NONE)
//   TC6  FIFO stress               (4 back-to-back bursts, check drain)
// =============================================================================
`timescale 1ns / 1ps
`include "_svh.svh"

module tb_axi_uart_tx;

// ─────────────────────────────────────────── parameters
localparam int  CLK_HALF     = 4;           // 8 ns → 125 MHz
localparam int  CLKS_PER_BIT = 100;         // simulation baud divisor
localparam      BAUD_STEP    = 32'd42_949_673; // 2^32 / 100

// ─────────────────────────────────────────── clock & reset
logic clk = 0;
logic rst = 1;
always #CLK_HALF clk = ~clk;

// ─────────────────────────────────────────── AXI interface
axi_full_if axi_if();

// ─────────────────────────────────────────── DUT signals
logic        uart_tx;
tx_para_t    tx_para;
logic [15:0] axi_wr_max_len;
logic [15:0] axi_wr_eff_len;
logic [10:0] tx_fifo_usedw;

// ─────────────────────────────────────────── DUT
axi_uart_tx DUT (
    .clk            (clk),
    .rst            (rst),
    .uart_tx        (uart_tx),
    .sw_axi_full_if (axi_if.slave_write),
    .tx_para        (tx_para),
    .axi_wr_max_len (axi_wr_max_len),
    .axi_wr_eff_len (axi_wr_eff_len),
    .tx_fifo_usedw  (tx_fifo_usedw)
);

// ─────────────────────────────────────────── AXI idle init
// Drive on negedge to avoid posedge race with DUT registers
task axi_idle();
    @(negedge clk);
    axi_if.awvalid = 0; axi_if.awid    = '0; axi_if.awaddr  = '0;
    axi_if.awlen   = '0; axi_if.awsize  = 3'b011; axi_if.awburst = 2'b01;
    axi_if.awprot  = '0; axi_if.awlock  = '0; axi_if.awcache = '0;
    axi_if.wdata   = '0; axi_if.wstrb   = '0; axi_if.wlast   = '0;
    axi_if.wvalid  = '0; axi_if.bready  = 1'b1;
    // read channel: tie off (not used)
    axi_if.arvalid = '0; axi_if.arid    = '0; axi_if.araddr  = '0;
    axi_if.arlen   = '0; axi_if.arsize  = '0; axi_if.arburst = '0;
    axi_if.arprot  = '0; axi_if.arlock  = '0; axi_if.arcache = '0;
    axi_if.rready  = '0;
endtask

// ─────────────────────────────────────────── tx_para helper
task set_tx_para(
    input logic [31:0]   bstep,
    input logic [23:0]   fstep,
    input logic [3:0]    dw,
    input parity_check_e pchk,
    input stop_bit_e     sbit
);
    tx_para.baud_rate_phase_acc_step_len      = bstep;
    tx_para.baud_rate_phase_acc_frac_step_len = fstep;
    tx_para.data_width                        = dw;
    tx_para.parity_check                      = pchk;
    tx_para.stop_bit_width                    = sbit;
    tx_para.frame_interval_unit_s             = '0;
    tx_para.frame_interval_unit_ms            = '0;
    tx_para.frame_interval_unit_us            = '0;
    tx_para.frame_interval_unit_baud_rate     = 32'd1;
endtask

// ─────────────────────────────────────────── AXI write burst task
// Max 8 beats.  Drive on negedge; handshake check on posedge.
task automatic axi_write_burst(
    input  logic [63:0] addr,
    input  logic [63:0] data [8],
    input  logic [7:0]  strb [8],
    input  int unsigned beat_cnt
);
    int timeout;

    // ── AW channel ─────────────────────────────
    @(negedge clk);
    axi_if.awvalid = 1'b1;
    axi_if.awaddr  = addr;
    axi_if.awlen   = 8'(beat_cnt - 1);
    axi_if.awid    = 4'h0;
    axi_if.awsize  = 3'b011;   // 8-byte beat
    axi_if.awburst = 2'b01;    // INCR

    // wait for awready (DUT deasserts after aw_hs)
    timeout = 0;
    @(posedge clk);
    while (!axi_if.awready) begin
        @(posedge clk);
        if (++timeout > 1000) begin $display("[ERR] AW timeout"); $finish; end
    end
    @(negedge clk);
    axi_if.awvalid = 1'b0;

    // ── W channel ──────────────────────────────
    for (int i = 0; i < int'(beat_cnt); i++) begin
        // wait for wready (rises one cycle after aw_hs)
        timeout = 0;
        @(posedge clk);
        while (!axi_if.wready) begin
            @(posedge clk);
            if (++timeout > 1000) begin $display("[ERR] W timeout beat %0d", i); $finish; end
        end
        @(negedge clk);
        axi_if.wvalid = 1'b1;
        axi_if.wdata  = data[i];
        axi_if.wstrb  = strb[i];
        axi_if.wlast  = (i == int'(beat_cnt) - 1) ? 1'b1 : 1'b0;
    end

    // deassert W after last beat acknowledged
    @(posedge clk);  // w_hs of last beat
    @(negedge clk);
    axi_if.wvalid = 1'b0;
    axi_if.wlast  = 1'b0;
    axi_if.wstrb  = '0;

    // ── B channel ──────────────────────────────
    // bready is permanently 1; just wait for bvalid
    timeout = 0;
    @(posedge clk);
    while (!axi_if.bvalid) begin
        @(posedge clk);
        if (++timeout > 1000) begin $display("[ERR] B timeout"); $finish; end
    end
    $display("[AXI] burst done  addr=0x%016X  beats=%0d  t=%0t", addr, beat_cnt, $time);
endtask

// ─────────────────────────────────────────── UART decode queue
logic [7:0] rx_queue[$];
int         rx_cnt = 0;

// Decode one UART frame (no parity) and push to rx_queue.
// Sampling: middle of each bit = CLKS_PER_BIT/2 clocks after previous edge.
task automatic uart_mon_noparity();
    logic [7:0] b;
    forever begin
        // detect start bit falling edge
        @(negedge uart_tx);
        // advance to middle of start bit, then one more bit to bit[0]
        repeat (CLKS_PER_BIT + CLKS_PER_BIT/2) @(posedge clk);
        // sample 8 data bits
        for (int i = 0; i < 8; i++) begin
            b[i] = uart_tx;
            if (i < 7) repeat (CLKS_PER_BIT) @(posedge clk);
        end
        // stop bit (just consume, check it's 1)
        repeat (CLKS_PER_BIT) @(posedge clk);
        if (uart_tx !== 1'b1)
            $display("[MON][WARN] stop bit low  byte_idx=%0d  t=%0t", rx_cnt, $time);
        rx_queue.push_back(b);
        $display("[MON] t=%0t  rx[%0d]=0x%02X", $time, rx_cnt++, b);
    end
endtask

// Decode one UART frame with parity bit and verify.
task automatic uart_mon_parity(input parity_check_e pchk);
    logic [7:0] b;
    logic pbit, exp_p;
    forever begin
        @(negedge uart_tx);
        repeat (CLKS_PER_BIT + CLKS_PER_BIT/2) @(posedge clk);
        for (int i = 0; i < 8; i++) begin
            b[i] = uart_tx;
            if (i < 7) repeat (CLKS_PER_BIT) @(posedge clk);
        end
        // parity bit
        repeat (CLKS_PER_BIT) @(posedge clk);
        pbit = uart_tx;
        case (pchk)
            E_PARITY_CHECK_ODD  : exp_p = ~(^b);
            E_PARITY_CHECK_EVEN : exp_p =  (^b);
            E_PARITY_CHECK_MARK : exp_p = 1'b1;
            E_PARITY_CHECK_SPACE: exp_p = 1'b0;
            default             : exp_p = 1'bx;
        endcase
        if (pbit !== exp_p)
            $display("[MON][PARITY FAIL] byte=0x%02X  got=%b  exp=%b  t=%0t",
                     b, pbit, exp_p, $time);
        else
            $display("[MON][PARITY OK]   byte=0x%02X  parity=%b  t=%0t", b, pbit, $time);
        // stop bit
        repeat (CLKS_PER_BIT) @(posedge clk);
        rx_queue.push_back(b);
        rx_cnt++;
    end
endtask

// ─────────────────────────────────────────── byte checker
// Block until rx_queue has enough bytes (or timeout), then compare.
task automatic check_bytes(input logic [7:0] exp[$], input int timeout_clks = 50000);
    int t = 0;
    automatic int n = exp.size();
    while (rx_queue.size() < n) begin
        @(posedge clk);
        if (++t >= timeout_clks) begin
            $display("[CHK] TIMEOUT: got %0d / %0d bytes", rx_queue.size(), n);
            return;
        end
    end
    foreach (exp[i]) begin
        automatic logic [7:0] got = rx_queue.pop_front();
        if (got !== exp[i])
            $display("[CHK] FAIL  byte[%0d]  got=0x%02X  exp=0x%02X", i, got, exp[i]);
        else
            $display("[CHK] PASS  byte[%0d] = 0x%02X", i, got);
    end
endtask

// ─────────────────────────────────────────── test data
logic [63:0] d[8];
logic [7:0]  s[8];

// ─────────────────────────────────────────── main test
initial begin : TB_MAIN

    // ── power-on init ──────────────────────────────────────────────
    axi_idle();
    axi_wr_max_len = 16'd8;
    axi_wr_eff_len = 16'd8;
    set_tx_para(BAUD_STEP, 24'd0, 4'd8, E_PARITY_CHECK_NONE, E_STOP_BIT_1);

    rst = 1;
    repeat (12) @(posedge clk);
    @(negedge clk); rst = 0;
    repeat (5)  @(posedge clk);

    // ══════════════════════════════════════════════════════════════
    // TC1  Single beat, full strobe → 8 UART bytes 0x11..0x88
    // ══════════════════════════════════════════════════════════════
    $display("\n───── TC1: single beat strb=0xFF ─────");
    rx_queue.delete(); rx_cnt = 0;
    fork : MON1 uart_mon_noparity(); join_none

    d[0] = 64'h88_77_66_55_44_33_22_11;
    s[0] = 8'hFF;
    axi_write_burst(64'h0, d, s, 1);

    begin
        automatic logic [7:0] exp[$] =
            '{8'h11,8'h22,8'h33,8'h44,8'h55,8'h66,8'h77,8'h88};
        check_bytes(exp, CLKS_PER_BIT * 120);
    end
    disable MON1;

    // ══════════════════════════════════════════════════════════════
    // TC2  Partial strobe 0x0E → bytes wdata[23:8] → 0x22,0x33,0x44
    //       strb bit[0]=0 (byte0 invalid), bits[1..3]=1 (bytes 1-3 valid)
    // ══════════════════════════════════════════════════════════════
    $display("\n───── TC2: partial strobe 0x0E ─────");
    rx_queue.delete(); rx_cnt = 0;
    fork : MON2 uart_mon_noparity(); join_none

    d[0] = 64'h00_00_00_00_44_33_22_00;
    s[0] = 8'h0E;
    axi_write_burst(64'h0, d, s, 1);

    begin
        automatic logic [7:0] exp[$] = '{8'h22, 8'h33, 8'h44};
        check_bytes(exp, CLKS_PER_BIT * 60);
    end
    disable MON2;

    // ══════════════════════════════════════════════════════════════
    // TC3  Two-beat burst → 16 UART bytes
    // ══════════════════════════════════════════════════════════════
    $display("\n───── TC3: 2-beat burst ─────");
    rx_queue.delete(); rx_cnt = 0;
    fork : MON3 uart_mon_noparity(); join_none

    d[0] = 64'h88_77_66_55_44_33_22_11;
    d[1] = 64'hFF_EE_DD_CC_BB_AA_99_10;
    s[0] = 8'hFF; s[1] = 8'hFF;
    axi_write_burst(64'h0, d, s, 2);

    begin
        automatic logic [7:0] exp[$] = '{
            8'h11,8'h22,8'h33,8'h44,8'h55,8'h66,8'h77,8'h88,
            8'h10,8'h99,8'hAA,8'hBB,8'hCC,8'hDD,8'hEE,8'hFF
        };
        check_bytes(exp, CLKS_PER_BIT * 230);
    end
    disable MON3;

    // ══════════════════════════════════════════════════════════════
    // TC4  Odd parity — parity bit verified for each UART frame
    // ══════════════════════════════════════════════════════════════
    $display("\n───── TC4: odd parity ─────");
    rx_queue.delete(); rx_cnt = 0;
    set_tx_para(BAUD_STEP, 24'd0, 4'd8, E_PARITY_CHECK_ODD, E_STOP_BIT_1);
    repeat (5) @(posedge clk);
    fork : MON4 uart_mon_parity(E_PARITY_CHECK_ODD); join_none

    // 0xAA = 8'b10101010 (4 ones → odd parity bit = 1)
    // 0x55 = 8'b01010101 (4 ones → odd parity bit = 1)
    d[0] = 64'h00_00_00_00_00_00_55_AA;
    s[0] = 8'h03;   // bytes 0 and 1
    axi_write_burst(64'h0, d, s, 1);
    repeat (CLKS_PER_BIT * 35) @(posedge clk);
    disable MON4;

    // ══════════════════════════════════════════════════════════════
    // TC5  TX_PARA_VALIDITY_CHECK: parity enum out of range
    //      → RTL clamps to E_PARITY_CHECK_NONE → no parity bit
    // ══════════════════════════════════════════════════════════════
    $display("\n───── TC5: invalid parity clamped to NONE ─────");
    rx_queue.delete(); rx_cnt = 0;
    tx_para.parity_check = parity_check_e'(4'hF);   // >= E_PARITY_CHECK_END
    repeat (5) @(posedge clk);
    fork : MON5 uart_mon_noparity(); join_none

    d[0] = 64'h00_00_00_00_00_00_00_A5;
    s[0] = 8'h01;   // byte 0 only
    axi_write_burst(64'h0, d, s, 1);

    begin
        automatic logic [7:0] exp[$] = '{8'hA5};
        check_bytes(exp, CLKS_PER_BIT * 25);
    end
    disable MON5;

    // ══════════════════════════════════════════════════════════════
    // TC6  FIFO stress: 4 back-to-back bursts without TX gap
    //      → FIFO fills up, check tx_fifo_usedw, then drains
    // ══════════════════════════════════════════════════════════════
    $display("\n───── TC6: FIFO stress ─────");
    rx_queue.delete(); rx_cnt = 0;
    set_tx_para(BAUD_STEP, 24'd0, 4'd8, E_PARITY_CHECK_NONE, E_STOP_BIT_1);
    repeat (5) @(posedge clk);
    fork : MON6 uart_mon_noparity(); join_none

    for (int i = 0; i < 4; i++) begin
        // fill beat with recognizable pattern: byte_k = i*8 + k + 1
        d[0] = 64'(8'(i*8+8)) << 56 | 64'(8'(i*8+7)) << 48 |
               64'(8'(i*8+6)) << 40 | 64'(8'(i*8+5)) << 32 |
               64'(8'(i*8+4)) << 24 | 64'(8'(i*8+3)) << 16 |
               64'(8'(i*8+2)) << 8  | 64'(8'(i*8+1));
        s[0] = 8'hFF;
        axi_write_burst(64'h0, d, s, 1);
    end
    $display("[TC6] tx_fifo_usedw immediately after 4 bursts = %0d", tx_fifo_usedw);
    // wait for full drain (4 bursts × 8 bytes × 11 bits/frame × CLKS_PER_BIT + margin)
    repeat (CLKS_PER_BIT * 400) @(posedge clk);
    $display("[TC6] tx_fifo_usedw after drain             = %0d", tx_fifo_usedw);
    disable MON6;

    // ── done ───────────────────────────────────────────────────────
    $display("\n═══ All test cases complete ═══");
    repeat (20) @(posedge clk);
    $finish;

end : TB_MAIN

// ─────────────────────────────────────────── waveform dump (xsim / vcs)
initial begin
    $dumpfile("tb_axi_uart_tx.vcd");
    $dumpvars(0, tb_axi_uart_tx);
end

endmodule