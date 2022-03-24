module TMNTColor(
	input V6M,
	input [12:1] AB,
	input [9:0] CD,
	input SHADOW,
	input NCBLK,
	input COLCS,
	input NLWR,
	input NREAD,
	input [7:0] CPU_DIN,
	output [7:0] CPU_DOUT,
	output [5:0] RED_OUT,
	output [5:0] GREEN_OUT,
	output [5:0] BLUE_OUT
);

	reg [12:0] C_REG;
	wire [10:0] CR;
	wire [7:0] RAM_DOUT_LOW;
	wire [7:0] RAM_DOUT_HIGH;
	reg [15:0] COL;
	wire [15:0] COL_OUT;
	wire [5:0] RED;
	wire [5:0] GREEN;
	wire [5:0] BLUE;
	wire [15:0] I;
	
	always @(posedge V6M)
		C_REG <= {C_REG[11], SHADOW, NCBLK, CD};
	
	assign {nCOE, CR} = COLCS ? {1'b0, 1'b0, C_REG[9:0]} : {NREAD, AB[12:2]};
	// nCOE useless ?

	assign I[7:0] = (~COLCS & AB[1] & NREAD) ? CPU_DIN : 8'bzzzzzzzz;
	assign I[15:8] = (~COLCS & ~AB[1] & NREAD) ? CPU_DIN : 8'bzzzzzzzz;
	
	assign CPU_DOUT = (~COLCS & ~NREAD) ? AB[1] ? RAM_DOUT_LOW : RAM_DOUT_HIGH : 8'bzzzzzzzz;
	
	// TMNT only uses half of palette RAM ?
	ram_sim #(8, 11, "") RAM_PAL_LOW(CR, ~AB[1] | COLCS | NLWR, 1'b0, I[7:0], RAM_DOUT_LOW);
	ram_sim #(8, 11, "") RAM_PAL_HIGH(CR, AB[1] | COLCS | NLWR, 1'b0, I[15:8], RAM_DOUT_HIGH);
	
	always @(posedge V6M)
		COL <= {C_REG[10], RAM_DOUT_HIGH[6:0], RAM_DOUT_LOW};
	
	// COL[15] = NCBLK
	assign RED = COL[15] ? 5'd0 : COL[4:0];
	assign GREEN = COL[15] ? 5'd0 : COL[9:5];
	assign BLUE = COL[15] ? 5'd0 : COL[14:10];
	
	assign RED_OUT = C_REG[10] ? {RED, RED[0]} : {1'b0, RED};
	assign GREEN_OUT = C_REG[10] ? {GREEN, GREEN[0]} : {1'b0, GREEN};
	assign BLUE_OUT = C_REG[10] ? {BLUE, BLUE[0]} : {1'b0, BLUE};
	
endmodule
