`timescale 1ns/1ps
`default_nettype none

//=============================================================================
// Module: alpha2_3_simple_wb_wrapper
// Description: Simplified multi-peripheral Wishbone wrapper for Caravel integration
//              Integrates 1x SPI master and 1x GPIO for testing
// Author: NativeChips Agent
// Date: 2025-08-31
// License: Apache 2.0
//=============================================================================

module alpha2_3_simple_wb_wrapper (
`ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // IO Pads
    input [7:0] io_in,
    output [7:0] io_out,
    output [7:0] io_oeb,

    // Interrupt outputs
    output [2:0] irq
);

    // Address decode parameters
    localparam SPI0_BASE = 32'h3000_0000;
    localparam GPIO_BASE = 32'h3000_1000;
    
    // Address decode logic
    wire spi0_sel = (wbs_adr_i[31:12] == SPI0_BASE[31:12]);
    wire gpio_sel = (wbs_adr_i[31:12] == GPIO_BASE[31:12]);

    // Wishbone signals for each peripheral
    wire spi0_ack, gpio_ack;
    wire [31:0] spi0_dat_o, gpio_dat_o;
    wire spi0_irq, gpio_irq;

    // SPI signals
    wire spi0_miso, spi0_mosi, spi0_csb, spi0_sclk;

    // GPIO signals
    wire [7:0] gpio_in, gpio_out, gpio_oe;

    // Wishbone multiplexing
    assign wbs_ack_o = spi0_sel ? spi0_ack :
                       gpio_sel ? gpio_ack : 1'b0;

    assign wbs_dat_o = spi0_sel ? spi0_dat_o :
                       gpio_sel ? gpio_dat_o : 32'h0;

    // Interrupt aggregation
    assign irq[0] = gpio_irq;           // GPIO interrupts
    assign irq[1] = spi0_irq;           // SPI interrupts
    assign irq[2] = 1'b0;               // Unused

    // SPI Master 0 instance
    CF_SPI_WB #(
        .CDW(8),
        .FAW(4)
    ) spi0_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(spi0_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i & spi0_sel),
        .stb_i(wbs_stb_i & spi0_sel),
        .ack_o(spi0_ack),
        .we_i(wbs_we_i),
        .IRQ(spi0_irq),
        .miso(spi0_miso),
        .mosi(spi0_mosi),
        .csb(spi0_csb),
        .sclk(spi0_sclk)
    );

    // GPIO instance (using only 2 pins out of 8)
    EF_GPIO8_WB gpio_inst (
        .ext_clk(wb_clk_i),
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(gpio_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i & gpio_sel),
        .stb_i(wbs_stb_i & gpio_sel),
        .ack_o(gpio_ack),
        .we_i(wbs_we_i),
        .IRQ(gpio_irq),
        .io_in(gpio_in),
        .io_out(gpio_out),
        .io_oe(gpio_oe)
    );

    // IO Pin assignments
    // SPI Master 0: io_out[3:0] = {sclk0, mosi0, csb0, miso0}
    assign io_out[0] = spi0_miso;   // Input from external device
    assign io_out[1] = spi0_csb;
    assign io_out[2] = spi0_mosi;
    assign io_out[3] = spi0_sclk;
    assign spi0_miso = io_in[0];

    // GPIO: io_out[5:4] = {gpio1, gpio0}
    assign io_out[4] = gpio_out[0];
    assign io_out[5] = gpio_out[1];
    assign gpio_in[0] = io_in[4];
    assign gpio_in[1] = io_in[5];
    assign gpio_in[7:2] = 6'b0; // Unused GPIO pins

    // Unused pins
    assign io_out[7:6] = 2'b0;

    // IO Output Enable control
    assign io_oeb[0] = 1'b1;    // SPI0 MISO is input
    assign io_oeb[1] = 1'b0;    // SPI0 CSB is output
    assign io_oeb[2] = 1'b0;    // SPI0 MOSI is output
    assign io_oeb[3] = 1'b0;    // SPI0 SCLK is output

    assign io_oeb[4] = ~gpio_oe[0];   // GPIO0 direction
    assign io_oeb[5] = ~gpio_oe[1];   // GPIO1 direction

    assign io_oeb[7:6] = 2'b1;  // Unused pins as inputs

endmodule

`default_nettype wire