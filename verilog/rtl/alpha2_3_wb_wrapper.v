`timescale 1ns/1ps
`default_nettype none

//=============================================================================
// Module: alpha2_3_wb_wrapper
// Description: Multi-peripheral Wishbone wrapper for Caravel integration
//              Integrates 2x SPI masters, 1x I2C controller, and 2x GPIO lines
// Author: NativeChips Agent
// Date: 2025-08-31
// License: Apache 2.0
//=============================================================================

module alpha2_3_wb_wrapper (
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
    input [15:0] io_in,
    output [15:0] io_out,
    output [15:0] io_oeb,

    // Interrupt outputs
    output [2:0] irq
);

    // Address decode parameters
    localparam SPI0_BASE = 32'h3000_0000;
    localparam SPI1_BASE = 32'h3000_1000;
    localparam I2C_BASE  = 32'h3000_2000;
    localparam GPIO_BASE = 32'h3000_3000;
    
    // Address decode logic
    wire spi0_sel = (wbs_adr_i[31:12] == SPI0_BASE[31:12]);
    wire spi1_sel = (wbs_adr_i[31:12] == SPI1_BASE[31:12]);
    wire i2c_sel  = (wbs_adr_i[31:12] == I2C_BASE[31:12]);
    wire gpio_sel = (wbs_adr_i[31:12] == GPIO_BASE[31:12]);

    // Wishbone signals for each peripheral
    wire spi0_ack, spi1_ack, i2c_ack, gpio_ack;
    wire [31:0] spi0_dat_o, spi1_dat_o, i2c_dat_o, gpio_dat_o;
    wire spi0_irq, spi1_irq, i2c_irq, gpio_irq;

    // SPI signals
    wire spi0_miso, spi0_mosi, spi0_csb, spi0_sclk;
    wire spi1_miso, spi1_mosi, spi1_csb, spi1_sclk;

    // I2C signals
    wire i2c_scl_i, i2c_scl_o, i2c_scl_oen_o;
    wire i2c_sda_i, i2c_sda_o, i2c_sda_oen_o;

    // GPIO signals
    wire [7:0] gpio_in, gpio_out, gpio_oe;

    // Wishbone multiplexing
    assign wbs_ack_o = spi0_sel ? spi0_ack :
                       spi1_sel ? spi1_ack :
                       i2c_sel  ? i2c_ack  :
                       gpio_sel ? gpio_ack : 1'b0;

    assign wbs_dat_o = spi0_sel ? spi0_dat_o :
                       spi1_sel ? spi1_dat_o :
                       i2c_sel  ? i2c_dat_o  :
                       gpio_sel ? gpio_dat_o : 32'h0;

    // Interrupt aggregation
    assign irq[0] = gpio_irq;           // GPIO interrupts
    assign irq[1] = spi0_irq | spi1_irq; // SPI interrupts
    assign irq[2] = i2c_irq;            // I2C interrupts

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

    // SPI Master 1 instance
    CF_SPI_WB #(
        .CDW(8),
        .FAW(4)
    ) spi1_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(spi1_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i & spi1_sel),
        .stb_i(wbs_stb_i & spi1_sel),
        .ack_o(spi1_ack),
        .we_i(wbs_we_i),
        .IRQ(spi1_irq),
        .miso(spi1_miso),
        .mosi(spi1_mosi),
        .csb(spi1_csb),
        .sclk(spi1_sclk)
    );

    // I2C Master instance
    EF_I2C_WB #(
        .DEFAULT_PRESCALE(1),
        .FIXED_PRESCALE(0),
        .CMD_FIFO(1),
        .CMD_FIFO_DEPTH(16),
        .WRITE_FIFO(1),
        .WRITE_FIFO_DEPTH(16),
        .READ_FIFO(1),
        .READ_FIFO_DEPTH(16)
    ) i2c_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(i2c_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i & i2c_sel),
        .stb_i(wbs_stb_i & i2c_sel),
        .ack_o(i2c_ack),
        .we_i(wbs_we_i),
        .IRQ(i2c_irq),
        .scl_i(i2c_scl_i),
        .scl_o(i2c_scl_o),
        .scl_oen_o(i2c_scl_oen_o),
        .sda_i(i2c_sda_i),
        .sda_o(i2c_sda_o),
        .sda_oen_o(i2c_sda_oen_o)
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
    // SPI Master 0: io_out[7:4] = {sclk0, mosi0, csb0, miso0}
    assign io_out[4] = spi0_miso;   // Input from external device
    assign io_out[5] = spi0_csb;
    assign io_out[6] = spi0_mosi;
    assign io_out[7] = spi0_sclk;
    assign spi0_miso = io_in[4];

    // SPI Master 1: io_out[11:8] = {sclk1, mosi1, csb1, miso1}
    assign io_out[8] = spi1_miso;   // Input from external device
    assign io_out[9] = spi1_csb;
    assign io_out[10] = spi1_mosi;
    assign io_out[11] = spi1_sclk;
    assign spi1_miso = io_in[8];

    // I2C Controller: io_out[13:12] = {scl, sda}
    assign io_out[12] = i2c_scl_oen_o ? 1'bz : i2c_scl_o;
    assign io_out[13] = i2c_sda_oen_o ? 1'bz : i2c_sda_o;
    assign i2c_scl_i = io_in[12];
    assign i2c_sda_i = io_in[13];

    // GPIO: io_out[15:14] = {gpio1, gpio0}
    assign io_out[14] = gpio_out[0];
    assign io_out[15] = gpio_out[1];
    assign gpio_in[0] = io_in[14];
    assign gpio_in[1] = io_in[15];
    assign gpio_in[7:2] = 6'b0; // Unused GPIO pins

    // IO Output Enable control
    assign io_oeb[4] = 1'b1;    // SPI0 MISO is input
    assign io_oeb[5] = 1'b0;    // SPI0 CSB is output
    assign io_oeb[6] = 1'b0;    // SPI0 MOSI is output
    assign io_oeb[7] = 1'b0;    // SPI0 SCLK is output

    assign io_oeb[8] = 1'b1;    // SPI1 MISO is input
    assign io_oeb[9] = 1'b0;    // SPI1 CSB is output
    assign io_oeb[10] = 1'b0;   // SPI1 MOSI is output
    assign io_oeb[11] = 1'b0;   // SPI1 SCLK is output

    assign io_oeb[12] = i2c_scl_oen_o; // I2C SCL open-drain
    assign io_oeb[13] = i2c_sda_oen_o; // I2C SDA open-drain

    assign io_oeb[14] = ~gpio_oe[0];   // GPIO0 direction
    assign io_oeb[15] = ~gpio_oe[1];   // GPIO1 direction

    // Unused pins
    assign io_out[3:0] = 4'b0;
    assign io_oeb[3:0] = 4'b1;

endmodule

`default_nettype wire