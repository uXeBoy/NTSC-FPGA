// http://chasingtrons.com/main/2012/6/14/television-fpga-verilog.html

module top_ntsc(
  input        clk100,
  output [3:0] ntsc_out
);

  wire clk;
  reg  [3:0]  pixel_data;
  wire [9:0]  pixel_x;
  wire [9:0]  pixel_y;
  wire        pixel_is_visible;

  localparam [3:0]  SIGNAL_LEVEL_SYNC         = 4'b0000,
                    SIGNAL_LEVEL_BLANK        = 4'b0001,
                    SIGNAL_LEVEL_DARK_GREY    = 4'b0011,
                    SIGNAL_LEVEL_LIGHT_GREY   = 4'b0111,
                    SIGNAL_LEVEL_WHITE        = 4'b1111;

  always @*
    if ( pixel_is_visible )
    begin
      // display black bar
      if ( pixel_x >= 0 && pixel_x < 140 )
        pixel_data = SIGNAL_LEVEL_BLANK;
      // display dark grey bar
      else if ( pixel_x >= 140 && pixel_x < 280 )
        pixel_data = SIGNAL_LEVEL_DARK_GREY;
      // display light grey bar
      else if ( pixel_x >= 280 && pixel_x < 420 )
        pixel_data = SIGNAL_LEVEL_LIGHT_GREY;
      // display white bar
      else if ( pixel_x >= 420 && pixel_x < 560 )
        pixel_data = SIGNAL_LEVEL_WHITE;
    end
    else
      pixel_data = SIGNAL_LEVEL_BLANK;

  interlaced_ntsc ntsc (
    .clk              ( clk ),
    .ntsc_out         ( ntsc_out ),
    .pixel_is_visible ( pixel_is_visible ),
    .pixel_data       ( pixel_data ),
    .pixel_y          ( pixel_y ),
    .pixel_x          ( pixel_x )
  );

  SB_PLL40_PAD #(
    .FEEDBACK_PATH ( "SIMPLE" ),
    .DIVR ( 4'b0000 ),
    .DIVF ( 7'b0000111 ),
    .DIVQ ( 3'b100 ),
    .FILTER_RANGE ( 3'b101 )
  ) uut (
    .RESETB         ( 1'b1 ),
    .BYPASS         ( 1'b0 ),
    .PACKAGEPIN     ( clk100 ),
    .PLLOUTGLOBAL   ( clk )
  );

endmodule

