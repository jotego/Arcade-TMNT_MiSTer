module FDE(
	input CK,
	input D,
	input nCL,
	output reg Q,
	output nQ
);

// Same function as FDO and FDG ?

always @(posedge CK or negedge nCL) begin
	if (!nCL)
		Q <= 0;
	else
		Q <= D;
end

assign nQ = ~Q;

endmodule
