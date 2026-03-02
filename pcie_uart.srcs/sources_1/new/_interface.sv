`ifndef _INTERFACE
`define _INTERFACE

interface axi_lite_if #(
    parameter int ADDR_W = 32,
    parameter int DATA_W = 32
)(
    input logic clk,
    input logic rst
);
    localparam int STRB_W = DATA_W / 8;

    logic [ADDR_W-1:0]  awaddr  ;
    logic [2:0]         awprot  ;
    logic               awvalid ;
    logic               awready ;
    logic [DATA_W-1:0]  wdata   ;
    logic [STRB_W-1:0]  wstrb   ;
    logic               wvalid  ;
    logic               wready  ;
    logic [1:0]         bresp   ;
    logic               bvalid  ;
    logic               bready  ;
    logic [ADDR_W-1:0]  araddr  ;
    logic [2:0]         arprot  ;
    logic               arvalid ;
    logic               arready ;
    logic [DATA_W-1:0]  rdata   ;
    logic [1:0]         rresp   ;
    logic               rvalid  ;
    logic               rready  ;

    modport master (
        input  clk, rst,
        output awaddr, awprot, awvalid,
        input  awready,
        output wdata,  wstrb,  wvalid,
        input  wready,
        input  bresp,  bvalid,
        output bready,
        output araddr, arprot, arvalid,
        input  arready,
        input  rdata,  rresp,  rvalid,
        output rready
    );

    modport slave (
        input  clk, rst,
        input  awaddr, awprot, awvalid,
        output awready,
        input  wdata,  wstrb,  wvalid,
        output wready,
        output bresp,  bvalid,
        input  bready,
        input  araddr, arprot, arvalid,
        output arready,
        output rdata,  rresp,  rvalid,
        input  rready
    );

    modport monitor (
        input  clk, rst,
        input  awaddr, awprot, awvalid, awready,
        input  wdata,  wstrb,  wvalid,  wready,
        input  bresp,  bvalid, bready,
        input  araddr, arprot, arvalid, arready,
        input  rdata,  rresp,  rvalid,  rready
    );

endinterface : axi_lite_if


interface axi_full_if #(
    parameter int ID_W   = 4,
    parameter int ADDR_W = 64,
    parameter int DATA_W = 64
);
    localparam int STRB_W = DATA_W / 8;

    logic [ID_W-1:0]    awid    ;
    logic [ADDR_W-1:0]  awaddr  ;
    logic [7:0]         awlen   ;
    logic [2:0]         awsize  ;
    logic [1:0]         awburst ;
    logic [2:0]         awprot  ;
    logic               awvalid ;
    logic               awlock  ;
    logic [3:0]         awcache ;
    logic               awready ;

    logic [DATA_W-1:0]  wdata   ;
    logic [STRB_W-1:0]  wstrb   ;
    logic               wlast   ;
    logic               wvalid  ;
    logic               wready  ;

    logic [ID_W-1:0]    bid     ;
    logic [1:0]         bresp   ;
    logic               bvalid  ;
    logic               bready  ;

    logic [ID_W-1:0]    arid    ;
    logic [ADDR_W-1:0]  araddr  ;
    logic [7:0]         arlen   ;
    logic [2:0]         arsize  ;
    logic [1:0]         arburst ;
    logic [2:0]         arprot  ;
    logic               arvalid ;
    logic               arlock  ;
    logic [3:0]         arcache ;
    logic               arready ;

    logic [ID_W-1:0]    rid     ;
    logic [DATA_W-1:0]  rdata   ;
    logic [1:0]         rresp   ;
    logic               rlast   ;
    logic               rvalid  ;
    logic               rready  ;

    modport master(
        output awid,  awaddr, awlen,  awsize, awburst, awprot, awvalid, awlock, awcache,
        input  awready,
        output wdata, wstrb,  wlast,  wvalid,
        input  wready,
        input  bid,   bresp,  bvalid,
        output bready,
        output arid,  araddr, arlen,  arsize, arburst, arprot, arvalid, arlock, arcache,
        input  arready,
        input  rid,   rdata,  rresp,  rlast,  rvalid,
        output rready
    );

    modport master_write(
        output awid,  awaddr, awlen,  awsize, awburst, awprot, awvalid, awlock, awcache,
        input  awready,
        output wdata, wstrb,  wlast,  wvalid,
        input  wready,
        input  bid,   bresp,  bvalid,
        output bready
    );

    modport master_read(
        output arid,  araddr, arlen,  arsize, arburst, arprot, arvalid, arlock, arcache,
        input  arready,
        input  rid,   rdata,  rresp,  rlast,  rvalid,
        output rready
    );

    modport slave(
        input  awid,  awaddr, awlen,  awsize, awburst, awprot, awvalid, awlock, awcache,
        output awready,
        input  wdata, wstrb,  wlast,  wvalid,
        output wready,
        output bid,   bresp,  bvalid,
        input  bready,
        input  arid,  araddr, arlen,  arsize, arburst, arprot, arvalid, arlock, arcache,
        output arready,
        output rid,   rdata,  rresp,  rlast,  rvalid,
        input  rready
    );

    modport slave_write(
        input  awid,  awaddr, awlen,  awsize, awburst, awprot, awvalid, awlock, awcache,
        output awready,
        input  wdata, wstrb,  wlast,  wvalid,
        output wready,
        output bid,   bresp,  bvalid,
        input  bready
    );

    modport slave_read(
        input  arid,  araddr, arlen,  arsize, arburst, arprot, arvalid, arlock, arcache,
        output arready,
        output rid,   rdata,  rresp,  rlast,  rvalid,
        input  rready
    );

    modport monitor(
        input  awid,  awaddr, awlen,  awsize, awburst, awprot, awvalid, awlock, awcache, awready,
        input  wdata, wstrb,  wlast,  wvalid,  wready,
        input  bid,   bresp,  bvalid, bready,
        input  arid,  araddr, arlen,  arsize, arburst, arprot, arvalid, arlock, arcache, arready,
        input  rid,   rdata,  rresp,  rlast,  rvalid,  rready
    );

endinterface : axi_full_if

interface uart_rx_cfg_if;

	logic		[31:0]	baud_rate_phase_acc_step_len;
	logic		[23:0]	baud_rate_phase_acc_frac_step_len;
	logic		[3:0]	data_width;
	logic		[3:0]	parity_check;
	logic		[3:0]	stop_bit_width;
	logic		[31:0]	fifo_timeout_thrd;

	modport i(
		input	baud_rate_phase_acc_step_len,
		input	baud_rate_phase_acc_frac_step_len,
		input	data_width,
		input	parity_check,
		input	stop_bit_width,
		input	fifo_timeout_thrd
	);

	modport o(
		output	baud_rate_phase_acc_step_len,
		output	baud_rate_phase_acc_frac_step_len,
		output	data_width,
		output	parity_check,
		output	stop_bit_width,
		output	fifo_timeout_thrd
	);
endinterface: uart_rx_cfg_if

interface uart_tx_cfg_if;

	logic		[31:0]	baud_rate_phase_acc_step_len;
	logic		[23:0]	baud_rate_phase_acc_frac_step_len;
	logic		[3:0]	data_width;
	logic		[3:0]	parity_check;
	logic		[3:0]	stop_bit_width;
	logic		[9:0]	frame_interval_unit_s;
	logic		[9:0]	frame_interval_unit_ms;
	logic		[9:0]	frame_interval_unit_us;
	logic		[31:0]	frame_interval_unit_baud_rate;
	modport i(
		input	baud_rate_phase_acc_step_len,
		input	baud_rate_phase_acc_frac_step_len,
		input	data_width,
		input	parity_check,
		input	stop_bit_width,
		input	frame_interval_unit_s,
		input	frame_interval_unit_ms,
		input	frame_interval_unit_us,
		input	frame_interval_unit_baud_rate
	);

	modport o(
		output	baud_rate_phase_acc_step_len,
		output	baud_rate_phase_acc_frac_step_len,
		output	data_width,
		output	parity_check,
		output	stop_bit_width,
		output	frame_interval_unit_s,
		output	frame_interval_unit_ms,
		output	frame_interval_unit_us,
		output	frame_interval_unit_baud_rate
	);
endinterface: uart_tx_cfg_if

interface debug_if #(
	parameter	P_DEBUG_ENABLE = 0
);
	logic			ext_uart_rx_enable;
	logic	[7:0]	ext_uart_rx_data;
	logic			ext_uart_rx_data_vld;
	logic	[7:0]	ext_uart_rx_data_mask;
	logic	[7:0]	monitor_uart_tx_data;
	logic			monitor_uart_tx_data_vld;
	logic	[7:0]	monitor_uart_tx_data_mask;

	logic			internal_stim_enable;

	debug_status_t	status;

//	modport s(
//		);

endinterface: debug_if

`else `endif
