`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:59:48 04/17/2017 
// Design Name: 
// Module Name:    vga 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga(
    input wire clk,reset,
    output wire hsync,vsync,
    //**output red, // three bit signal to drive color red
    //**output green, // three bit signal to drive color green
    //**output blue, // two bit signal to drive color blue (human eye is less sensitive to color blue)
    output red,
    output green,
    output blue,
    output reg video_on
);
     

// defining constants
localparam HD = 800; // horizontal display area
localparam HF = 56; // front porch (right border)
localparam HB = 64; //right porch (left border)
localparam HR = 120; // horizontal retrace
localparam VD = 600; // vertical display area
localparam VF = 37; // front porch (bottom border)
localparam VB = 23; // back porch (top border)
localparam VR = 6; // vertical retrace
localparam h_end = 1040; // total horizontal timing
localparam v_end = 666; // total vertical timing

//localparam sq_size = 20; // size of square
localparam sq_x_l = 0; //  left coordinate of square
localparam sq_x_r = 800;
localparam sq_y_t = 0;     
localparam sq_y_b = 600;

//horizontal and vertical counter

reg [10:0] h_count_reg,v_count_reg ; // registers for sequential horizontal and vertical counters
reg[10:0] h_count_next , v_count_next;
//reg v_sync_reg , h_sync_reg ;
//wire v_sync_next , h_sync_next ;
reg v_sync_next , h_sync_next = 0 ;

always @ ( posedge clk , posedge reset)
if (reset)
begin
v_count_reg <= 0;
h_count_reg <= 0 ;
//v_sync_reg <= 1'b0;
//h_sync_reg <= 1'b0;
end
else
begin
v_count_reg <= v_count_next;
h_count_reg <= h_count_next;
//v_sync_reg <= v_sync_next ;
//h_sync_reg <= h_sync_next ;
end

// horizontal and vertical counters
always @(posedge clk) 
begin
if(h_count_next < h_end-1)
begin
            
h_count_next <= h_count_next + 1;
end
else 
begin
h_count_next <= 0;
            
if(v_count_next < v_end-1)
v_count_next <= v_count_next + 1;
else
v_count_next <= 0;
end
end

// horizontal and vertical synchronization signals
always @(posedge clk)
if(h_count_reg < HR)
h_sync_next <= 1;
else
h_sync_next <= 0;
            
    
//VSync logic        
    
always @(posedge clk)
if(v_count_reg < VR)
v_sync_next <= 1;
else
v_sync_next <= 0;

assign hsync = h_sync_next;
assign vsync = v_sync_next;


    
reg h_video_on,v_video_on; // these registers ensure that the display signals are sent only when the pixels are within the display region of the monitor.

// Horizontal Logic

always @(posedge clk) 
if((h_count_reg >= HR + HF) && (h_count_reg < HR + HF + HD))
h_video_on <= 1;
else
h_video_on <= 0;
            
    
// Vertical Logic
    
always @(posedge clk)
if((v_count_reg >= VR + VF) && (v_count_reg < VR + VF+ VD))
v_video_on <= 1;
else
v_video_on <= 0;

always @(posedge clk)
if(h_video_on && v_video_on)
video_on <= 1;
else
video_on <= 0;


reg [9:0] pixel_x,pixel_y; // registers to describe current position of pixel within display area.

always @(posedge clk)
if(h_video_on)
pixel_x <= h_count_reg - HR - HF;
else
pixel_x <= 0;

always @(posedge clk) 
if(v_video_on)
pixel_y <= v_count_reg - VR - VF;
else
pixel_y <= 0;

//color output
reg [7:0] coloroutput; // 8 bit register which describes which color has to be displayed but only when video_on signal is turned on.

always @(posedge clk)
if(~video_on)
coloroutput <= 0;
else
begin
if(pixel_x >= 0 && pixel_x < 100)
coloroutput[7:0] <= 8'b00000000;

if(pixel_x >= 100 && pixel_x < 200)
coloroutput[7:0] <= 8'b11100000;

if(pixel_x >= 200 && pixel_x < 300)
coloroutput[7:0] <= 8'b00000000;

if(pixel_x >= 300 && pixel_x < 400)
coloroutput[7:0] <= 8'b11100000;

if(pixel_x >= 400 && pixel_x < 500)
coloroutput[7:0] <= 8'b00000000;

if(pixel_x >= 500 && pixel_x < 600)
coloroutput[7:0] <= 8'b11100000;

if(pixel_x >= 600 && pixel_x < 700)
coloroutput[7:0] <= 8'b00000000;

if(pixel_x >= 700 && pixel_x < 800)
coloroutput[7:0] <= 8'b11100000;

end

assign red = coloroutput[7];
assign green = coloroutput[6] ;
assign blue = coloroutput[5] ;

endmodule