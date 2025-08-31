`timescale 1ns/1ps
`default_nettype none

// Alias for EF_I2C compatibility
module ef_util_gating_cell(
    `ifdef USE_POWER_PINS 
    input   wire    vpwr,
    input   wire    vgnd,
    `endif // USE_POWER_PINS
    input   wire    clk,
    input   wire    clk_en,
    output  wire    clk_o
);
    `ifdef SKY130
    (* keep *) sky130_fd_sc_hd__dlclkp_4 clk_gate(
    `ifdef USE_POWER_PINS 
        .VPWR(vpwr), 
        .VGND(vgnd), 
        .VNB(vpwr),
        .VPB(vgnd),
    `endif // USE_POWER_PINS
        .GCLK(clk_o), 
        .GATE(clk_en), 
        .CLK(clk)
        );
    `else // SKY130
    assign clk_o = clk & clk_en; 
    `endif // SKY130
endmodule

`default_nettype wire