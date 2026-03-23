`ifndef _INTERFACE
`define _INTERFACE

import common_package::*;

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

interface byte_stream_if;

	logic	[7:0]	data;
	logic			valid;
	logic			last;
	logic			ready;

	modport m(
		output	data, valid, last,
		input	ready
	);

	modport s(
		input	data, valid, last,
		output	ready
	);

endinterface: byte_stream_if

interface u64_stream_if;

	logic	[63:0]	data;
	logic			valid;
	logic			last;
	logic			ready;

	modport m(
		output	data, valid, last,
		input	ready
	);

	modport s(
		input	data, valid, last,
		output	ready
	);

endinterface: u64_stream_if







































//  ______   ________  ______  _____  _____   ______
// |_   _ `.|_   __  ||_   _ \|_   _||_   _|.' ___  |
//   | | `. \ | |_ \_|  | |_) | | |    | | / .'   \_|
//   | |  | | |  _| _   |  __'. | '    ' | | |   ____
//  _| |_.' /_| |__/ | _| |__) | \ \__/ /  \ `.___]  |
// |______.'|________||_______/   `.__.'    `._____.'

`define P_ENA(name) ,parameter bit P_ENA_``name = P_DISABLE
`define DIS(name) if(P_ENA_``name == P_DISABLE) assign name = '0;

interface mux_buffer_debug_if #(
	parameter	bit	P_GLB_ENA		= P_DISABLE,

	parameter	bit P_ENA_ERRO		= P_DISABLE,
	parameter	bit P_ENA_WARN		= P_DISABLE,
	parameter	bit P_ENA_INFO		= P_DISABLE,
	parameter	bit P_ENA_SNAPSHOT	= P_DISABLE,
	parameter	bit P_ENA_CTRL		= P_DISABLE

	// custom
	`P_ENA(erro_byte_stream_no_gap)
);
	// signal template
	logic	erro_;
	logic	warn_;
	logic	info_;
	logic	snapshot_trig_;
	logic	snapshot_data_;
	logic	ctrl_;

	// user begin
	logic	erro_byte_stream_no_gap; `DIS(erro_byte_stream_no_gap)
	logic	erro_fifo_overflow;


	modport	source(
		output erro_byte_stream_no_gap, erro_fifo_overflow
	);

	modport monitor(
		input erro_byte_stream_no_gap, erro_fifo_overflow

	);
endinterface: mux_buffer_debug_if

interface axi_mux_debug_if #(
	parameter	bit	P_GLB_ENA		= P_DISABLE,

	parameter	bit P_ENA_ERRO		= P_DISABLE,
	parameter	bit P_ENA_WARN		= P_DISABLE,
	parameter	bit P_ENA_INFO		= P_DISABLE,
	parameter	bit P_ENA_SNAPSHOT	= P_DISABLE,
	parameter	bit P_ENA_CTRL		= P_DISABLE

	// custom
	,parameter	bit	P_CUSTOM	= P_DISABLE
);
	// signal template
	logic	erro_;
	logic	warn_;
	logic	info_;
	logic	snapshot_trig_;
	logic	snapshot_data_;
	logic	ctrl_;

	modport	source(
		output erro_
	);

	modport monitor(
		input erro_
	);
endinterface: axi_mux_debug_if

interface uart_rx_debug_if #(
	parameter	bit	P_GLB_ENA		= P_DISABLE,

	parameter	bit P_ENA_ERRO		= P_DISABLE,
	parameter	bit P_ENA_WARN		= P_DISABLE,
	parameter	bit P_ENA_INFO		= P_DISABLE,
	parameter	bit P_ENA_SNAPSHOT	= P_DISABLE,
	parameter	bit P_ENA_CTRL		= P_DISABLE

	// custom
	,parameter	bit P_CUSTOM = P_DISABLE
);
	// signal template
	logic	erro_;
	logic	warn_;
	logic	info_;
	logic	snapshot_trig_;
	logic	snapshot_data_;
	logic	ctrl_;

	modport	source(
		output erro_
	);

	modport monitor(
		input erro_
	);
endinterface: uart_rx_debug_if

interface uart_tx_debug_if #(
	parameter	bit	P_GLB_ENA		= P_DISABLE,

	parameter	bit P_ENA_ERRO		= P_DISABLE,
	parameter	bit P_ENA_WARN		= P_DISABLE,
	parameter	bit P_ENA_INFO		= P_DISABLE,
	parameter	bit P_ENA_SNAPSHOT	= P_DISABLE,
	parameter	bit P_ENA_CTRL		= P_DISABLE

	// custom
	,parameter	bit	P_CUSTOM	= P_DISABLE
);
	// signal template
	logic	erro_;
	logic	warn_;
	logic	info_;
	logic	snapshot_trig_;
	logic	snapshot_data_;
	logic	ctrl_;

	modport	source(
		output erro_
	);

	modport monitor(
		input erro_
	);
endinterface: uart_tx_debug_if

`else `endif
