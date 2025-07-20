/*******************************************************************************
 * CS220: Digital Circuit Lab
 * Computer Science Department
 * University of Crete
 * 
 * Date: 2023/04/07
 * Author: Onisiforos Ioannou
 * Filename: vga_sync.sv
 * Description: Implements VGA HSYNC and VSYNC timings for 640 x 480 @ 60Hz
 *
 ******************************************************************************/

module vga_sync(
  input logic clk,
  input logic rst,

  output logic o_pix_valid,
  output logic [9:0] o_col,
  output logic [9:0] o_row,

  output logic o_hsync,
  output logic o_vsync
);


parameter int FRAME_HPIXELS     = 640;
parameter int FRAME_HFPORCH     = 16;
parameter int FRAME_HSPULSE     = 96;
parameter int FRAME_HBPORCH     = 48;
parameter int FRAME_MAX_HCOUNT  = 800;

parameter int FRAME_VLINES      = 480;
parameter int FRAME_VFPORCH     = 10;
parameter int FRAME_VSPULSE     = 2;
parameter int FRAME_VBPORCH     = 29;
parameter int FRAME_MAX_VCOUNT  = 521;


/*****************************************/
/* Horizontal Sychronization Begins Here */
/*****************************************/

logic [9:0] hcnt;
logic hcnt_clr;
logic hs_set;
logic hs_clr;
logic hsync;
logic hsync_delayed;

// Managing the register used to store the value of hcnt
// If a reset signal is received, the value is reset to 0
always_ff @( posedge clk or posedge rst ) begin
    if ( rst ) begin 
        hcnt <= 0;
    end 
    else if ( hcnt_clr ) begin 
        hcnt <= 0; 
        end
    else begin 
        hcnt ++; 
    end
end


// Combinatorial Logic for determining the values of the signals hcnt_clr, hs_set, hs_clr
// Use of logical operator "==", due to the need of values of only 0 and 1
always_comb begin
    hcnt_clr = ( hcnt == ( FRAME_MAX_HCOUNT - 1 ) );
    hs_set = ( hcnt == ( FRAME_HPIXELS + FRAME_HFPORCH - 1 ) );
    hs_clr = ( hcnt == ( FRAME_HPIXELS + FRAME_HFPORCH + FRAME_HSPULSE - 1 ) );
end

// Managing the register used to store the value of hsync
// If a reset signal is received, the value is reset to 0
always_ff @( posedge clk or posedge rst ) begin
    if ( rst ) begin 
        hsync <= 0; 
    end
    else begin 
        hsync <= ( ~hs_clr & ( hs_set | hsync ) ); 
    end
end

// Managing the register used to store the value of hsync_delayed
// If a reset signal is received, the value is reset to 0
always_ff @( posedge clk or posedge rst ) begin
    if ( rst ) begin
        hsync_delayed <= 0; 
    end
    else begin 
        hsync_delayed <= hsync;
    end
end




/***************************************/
/* Vertical Sychronization Begins Here */
/***************************************/

logic [9:0] vcnt;
logic vcnt_clear;
logic vs_set;
logic vs_clr;
logic vsync;

// Managing the register used to store the value of vcnt
// If a reset signal is received, the value is reset to 0
always_ff @( posedge clk or posedge rst ) begin
    if ( rst ) begin
        vcnt <= 0;
    end 
    else if ( vcnt_clear ) begin 
        vcnt <= 0; 
        end
    else begin 
        if ( hcnt_clr ) begin  
            vcnt ++;
        end 
    end
end

// Combinatorial Logic for determining the values of the signals vcnt_clear, vs_set, vs_clr
// Use of logical operator "==", due to the need of values of only 0 and 1
always_comb begin
    vcnt_clear = ( ( vcnt == ( FRAME_MAX_VCOUNT - 1 ) ) & hcnt_clr ) ;
    vs_set = ( hcnt_clr & ( vcnt == ( FRAME_VLINES + FRAME_VFPORCH - 1 ) ) );
    vs_clr = ( hcnt_clr & ( vcnt == ( FRAME_VLINES + FRAME_VFPORCH + FRAME_VSPULSE - 1 ) ) );
end


// Managing the register used to store the value of vsync
// If a reset signal is received, the value is reset to 0
always_ff @( posedge clk or posedge rst ) begin
    if ( rst ) begin 
        vsync <= 0; 
    end
    else begin 
        vsync <= ( ( vs_set | vsync ) & ~vs_clr ); 
    end
end

// Use of combinatorial logic to push the values of the output signals
always_comb begin 
    o_hsync = ~hsync_delayed;
    o_col = hcnt;
    o_row = vcnt;
    o_vsync = ~vsync;
    o_pix_valid = ( ( FRAME_VLINES > vcnt ) & ( FRAME_HPIXELS > hcnt ) ) ;
end


endmodule
