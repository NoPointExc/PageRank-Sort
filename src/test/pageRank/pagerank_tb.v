module pageRank_tb;

localparam N=16;
localparam WIDTH=16;

reg clk;
reg reset;

always begin
  #1 clk  = 1;
  #1 clk = 0;
end

reg [N*N-1:0] adj;
reg [N*WIDTH-1:0] nodeWeight;
wire [WIDTH-1:0] node0Val;
// wire [WIDTH-1:0] node1Val;
// wire [WIDTH-1:0] node2Val;
// wire [WIDTH-1:0] node3Val;

pageRank  #(N,WIDTH) pr(clk,reset,adj,nodeWeight,node0Val);

integer i;
initial begin
	reset = 1'b0;

	
	$monitor($time,"node0Val=%d",node0Val);

	#1 reset = 1'b1;


	
	for(i=0;i<16;i=i+1)begin
		//Adjaceny matrix
		// 0 0 1 1
		// 1 0 0 0
		// 1 1 0 1
		// 1 1 0 0
		adj[0+i*16] = 1'b0; 
		adj[1+i*16] = 1'b0; 
		adj[2+i*16] = 1'b1; 
		adj[3+i*16] = 1'b1;
		adj[4+i*16] = 1'b1; 
		adj[5+i*16] = 1'b0; 
		adj[6+i*16] = 1'b0; 
		adj[7+i*16] = 1'b0;
		adj[8+i*16] = 1'b1; 
		adj[9+i*16] = 1'b1; 
		adj[10+i*16] = 1'b0; 
		adj[11+i*16] = 1'b1;
		adj[12+i*16] = 1'b1; 
		adj[13+i*16] = 1'b1; 
		adj[14+i*16] = 1'b0; 
		adj[15+i*16] = 1'b0;

		//Node weights 
		// 0.33, 0.5, 1, 0.5
		// 16'h5555 , 16'h8000 , 16'hFFFF, 16'h8000 
		nodeWeight[WIDTH-1:0] =  16'h5555;
		nodeWeight[2*WIDTH-1:WIDTH] =  16'h8000;
		nodeWeight[3*WIDTH-1:2*WIDTH] =  16'hffff;
		nodeWeight[4*WIDTH-1:3*WIDTH] =  16'h8000;
		
		nodeWeight[5*WIDTH-1:4*WIDTH] =  16'h5555;
		nodeWeight[6*WIDTH-1:5*WIDTH] =  16'h8000;
		nodeWeight[7*WIDTH-1:6*WIDTH] =  16'hffff;
		nodeWeight[8*WIDTH-1:7*WIDTH] =  16'h8000;
		
		nodeWeight[9*WIDTH-1:8*WIDTH] =  16'h5555;
		nodeWeight[10*WIDTH-1:9*WIDTH] =  16'h8000;
		nodeWeight[11*WIDTH-1:10*WIDTH] =  16'hffff;
		nodeWeight[12*WIDTH-1:11*WIDTH] =  16'h8000;
		
		nodeWeight[13*WIDTH-1:12*WIDTH] =  16'h5555;
		nodeWeight[14*WIDTH-1:13*WIDTH] =  16'h8000;
		nodeWeight[15*WIDTH-1:14*WIDTH] =  16'hffff;
		nodeWeight[16*WIDTH-1:15*WIDTH] =  16'h8000;
	end



	#2 reset = 1'b0;
end

endmodule
