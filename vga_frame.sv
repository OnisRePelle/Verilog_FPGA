/*******************************************************************************
 * CS220: Digital Circuit Lab
 * Computer Science Department
 * University of Crete
 * 
 * Date: 2023/04/05
 * Author: Onisiforos Ioannou
 * Filename: vga_frame.sv
 * Description: Your description here
 *
 ******************************************************************************/

module vga_frame(
  input logic clk,
  input logic rst,

  input logic i_pix_valid,
  input logic [9:0] i_col,
  input logic [9:0] i_row,

  input logic [5:0] i_player_bcol,
  input logic [5:0] i_player_brow,

  input logic [5:0] i_exit_bcol,
  input logic [5:0] i_exit_brow,

  output logic [3:0] o_red,
  output logic [3:0] o_green,
  output logic [3:0] o_blue
);

logic delayed_i_pix_valid;
logic [9:0] delayed_i_col;
logic [9:0] delayed_i_row;

logic [15:0] player_pixel;
logic [15:0] maze_pixel;
logic [15:0] exit_pixel;

logic [10:0] maze_address;
logic [7:0] player_address;
logic [7:0] exit_address;

logic maze_en;
logic player_en;
logic exit_en;

always_ff @( posedge clk or posedge rst ) begin
    if ( rst ) begin delayed_i_pix_valid <= 0; end
    else begin delayed_i_pix_valid <= i_pix_valid; end
end

always_ff @( posedge clk or posedge rst ) begin
    if ( rst ) begin delayed_i_col <= 0; end
    else begin delayed_i_col <= i_col; end
end

always_ff @( posedge clk or posedge rst ) begin
    if ( rst ) begin delayed_i_row <= 0; end
    else begin delayed_i_row <= i_row; end
end


always_comb begin

    maze_en = i_pix_valid;
    player_en = i_pix_valid;
    exit_en = i_pix_valid;
    
    
    maze_address = ( i_col >> 4 ) + ( ( i_row >> 4 ) << 6 );
    player_address = ( ( i_col % 16 ) << 4 ) + ( i_row % 16 ); 
    exit_address = ( ( i_col % 16 ) << 4 ) + ( i_row % 16 ); 
    
    
    if ( delayed_i_pix_valid ) begin
        if ( ( i_player_brow == ( delayed_i_row >> 4 ) ) && ( i_player_bcol == ( delayed_i_col >> 4 ) ) ) begin
            o_red = player_pixel [11:8];
            o_green = player_pixel [7:4];
            o_blue = player_pixel [3:0];
        end
        else if ( ( i_exit_brow == ( delayed_i_row >> 4 ) ) && ( i_exit_bcol == ( delayed_i_col >> 4 ) ) ) begin
            o_red = exit_pixel [11:8];
            o_green = exit_pixel [7:4];
            o_blue = exit_pixel [3:0];
        end
        else begin
            o_red = maze_pixel [11:8];
            o_green = maze_pixel [7:4];
            o_blue = maze_pixel [3:0];
        end
    end
    else begin 
        o_red = 0;
        o_green = 0;
        o_blue = 0;
    end
end


// ROM Template Instantiation
rom #(
  .size(2048),
  .file("/home/constantinos/Documents/CSD/HY220/lab_code/lab2_code/roms/maze1.rom") 
)
maze_rom (
  .clk(clk),
  .en(maze_en),
  .addr(maze_address),
  .dout(maze_pixel)
);

rom #(
  .size(256),
  .file("/home/constantinos/Documents/CSD/HY220/lab_code/lab2_code/roms/player.rom") 
)
player_rom (
  .clk(clk),
  .en(player_en),
  .addr(player_address),
  .dout(player_pixel)
);

rom #(
  .size(256),
  .file("/home/constantinos/Documents/CSD/HY220/lab_code/lab2_code/roms/exit.rom") 
)
exit_rom (
  .clk(clk),
  .en(exit_en),
  .addr(exit_address),
  .dout(exit_pixel)
);


endmodule
