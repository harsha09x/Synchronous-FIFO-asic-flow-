//==============================================================================
// CHIP TOP WITH PAD WRAPPER 
// SCL 180nm IO Library (tsl18cio150)
//==============================================================================

`timescale 1ns/1ps

module chip_top (
    // External PAD pins (inout to allow bidirectional pad cells)
    inout  wire       PAD_CLK,
    inout  wire       PAD_RSTN,
    inout  wire       PAD_WR_EN,
    inout  wire       PAD_RD_EN,
    inout  wire [7:0] PAD_DIN,
    inout  wire [7:0] PAD_DOUT,
    inout  wire       PAD_FULL,
    inout  wire       PAD_EMPTY
);

    //--------------------------------------------------------------------------
    // Internal core signals (post-pad, pre-core)
    //--------------------------------------------------------------------------
    wire       clk;
    wire       rst_n;
    wire       wr_en;
    wire       rd_en;
    wire [7:0] din;
    wire [7:0] dout;
    wire       full;
    wire       empty;

    //--------------------------------------------------------------------------
    // INPUT PADS (pc3d01)
    //--------------------------------------------------------------------------
    pc3d01 u_pad_clk (.PAD(PAD_CLK), .CIN(clk));
    pc3d01 u_pad_rst (.PAD(PAD_RSTN), .CIN(rst_n));
    pc3d01 u_pad_wr  (.PAD(PAD_WR_EN), .CIN(wr_en));
    pc3d01 u_pad_rd  (.PAD(PAD_RD_EN), .CIN(rd_en));

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : DIN_PADS
            pc3d01 u_pad_din (.PAD(PAD_DIN[i]), .CIN(din[i]));
        end
    endgenerate

    //--------------------------------------------------------------------------
    // OUTPUT PADS (pt3t03u) — OEN = 1'b0 permanently enables output
    //--------------------------------------------------------------------------
    pt3t03u u_pad_full  (.PAD(PAD_FULL),  .I(full),  .OEN(1'b0));
    pt3t03u u_pad_empty (.PAD(PAD_EMPTY), .I(empty), .OEN(1'b0));

    generate
        for (i = 0; i < 8; i = i + 1) begin : DOUT_PADS
            pt3t03u u_pad_dout (.PAD(PAD_DOUT[i]), .I(dout[i]), .OEN(1'b0));
        end
    endgenerate

    //--------------------------------------------------------------------------
    // FIFO CORE INSTANTIATION
    //--------------------------------------------------------------------------
    fifo_8bit u_fifo (
        .clk   (clk),
        .rst_n (rst_n),
        .wr_en (wr_en),
        .rd_en (rd_en),
        .din   (din),
        .dout  (dout),
        .full  (full),
        .empty (empty)
    );

endmodule
