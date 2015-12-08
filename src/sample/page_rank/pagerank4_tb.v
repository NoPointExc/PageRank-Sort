module pageRank_tb;

localparam N=4;
localparam WIDTH=16;

reg clk;
reg reset;

always begin
  #1 clk  = 1;
  #1 clk = 0;
end

reg [N*N-1:0] adj;
reg [N*WIDTH-1:0] nodeWeight;

pageRank pr(clk,reset,adj,nodeWeight);


initial begin
	reset = 1'b0;

	


	#1 reset = 1'b1;

	//Adjaceny matrix
	// 0 0 1 1
	// 1 0 0 0
	// 1 1 0 1
	// 1 1 0 0
	adj[0] = 1'b0; 
	adj[1] = 1'b0; 
	adj[2] = 1'b1; 
	adj[3] = 1'b1;
	adj[4] = 1'b1; 
	adj[5] = 1'b0; 
	adj[6] = 1'b0; 
	adj[7] = 1'b0;
	adj[8] = 1'b1; 
	adj[9] = 1'b1; 
	adj[10] = 1'b0; 
	adj[11] = 1'b1;
	adj[12] = 1'b1; 
	adj[13] = 1'b1; 
	adj[14] = 1'b0; 
	adj[15] = 1'b0;
	
	//Node weights 
	// 0.33, 0.5, 1, 0.5
	// 16'h5555 , 16'h8000 , 16'hFFFF, 16'h8000 
	nodeWeight[WIDTH-1:0] =  16'h5555;
	nodeWeight[2*WIDTH-1:WIDTH] =  16'h8000;
	nodeWeight[3*WIDTH-1:2*WIDTH] =  16'hffff;
	nodeWeight[4*WIDTH-1:3*WIDTH] =  16'h8000;

	#2 reset = 1'b0;
end

endmodule
