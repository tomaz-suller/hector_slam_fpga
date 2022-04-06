module vga_driver
#(
    parameter FRAME_WIDTH = 1600,
    parameter FRAME_HEIGHT = 900,
    
    parameter H_FP = 24, // H front porch width (pixels)
    parameter H_PW = 80, // H sync pulse width (pixels)
    parameter H_MAX = 1800, // H total period (pixels)
  
    parameter V_FP = 1, // V front porch width (lines)
    parameter V_PW = 3, // V sync pulse width (lines)
    parameter V_MAX = 1000, // V total period (lines)
  
    parameter H_POL = 0,
    parameter V_POL = 0
) (
  input clock, // clk 100MHz
  input pxlClk, //clk 108MHz active
  input reset,
  input [11:0] rgb_input,
  output reg [13:0] hCntr,
  output reg [13:0] vCntr,
  output screanClk, // 60Hz
  output [3:0] vgaRed,
  output [3:0] vgaBlue,
  output [3:0] vgaGreen,
  output reg Hsync,
  output reg Vsync,
  output buzy
);

  // Horizontal counter
  wire hCntrEnd = hCntr == (H_MAX-1);
  always @(posedge pxlClk) begin
    if (reset == 1 || hCntrEnd) hCntr <= 0;
    else hCntr <= hCntr + 1;
  end

  // Vertical counter
  wire vCntrEnd = vCntr == (V_MAX-1);
  always @(posedge pxlClk) begin
    if (reset == 1 || (hCntrEnd && vCntrEnd)) vCntr <= 0;
    else if (hCntrEnd) vCntr <= vCntr + 1;
  end
  
  // Horizontal sync
  always @(posedge pxlClk) begin
    if ((hCntr >= (H_FP + FRAME_WIDTH -1)) && (hCntr < (H_FP + FRAME_WIDTH + H_PW -1))) Hsync <= H_POL;
    else Hsync <= ~H_POL;
  end
  
  // Vertical sync
  always @(posedge pxlClk) begin
    if ((vCntr >= (V_FP + FRAME_HEIGHT -1)) && (vCntr < (V_FP + FRAME_HEIGHT + V_PW -1))) Vsync <= V_POL;
    else Vsync <= ~V_POL;
  end
  
  // up on end off screen
  assign screanClk = Vsync;
  
  // The active signal is used to signal the active region of the screen (when not blank)
  wire active = hCntr < FRAME_WIDTH && vCntr < FRAME_HEIGHT;
  assign {vgaRed, vgaBlue, vgaGreen} = active ? rgb_input : 0;

  assign buzy = hCntr <= FRAME_WIDTH & vCntr <= FRAME_HEIGHT; 
endmodule
