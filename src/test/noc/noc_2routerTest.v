/*
TODO:
-1)check request overflow
 */
module noc_2routerTest;
parameter N=16, DATA_W=16,RESP_W=DATA_W+6+3,REQ_W=12,DEPTH=32;
reg clk;
reg reset;
reg [5:0] request0; //request page id,16~64
reg [5:0] request1;  //-->request_id
reg [5:0] request2; 
reg [5:0] request3;
reg [DATA_W-1:0] reply0;  //--->reply from ants 
reg [DATA_W-1:0] reply1;
reg [DATA_W-1:0] reply2;
reg [DATA_W-1:0] reply3;
wire [5:0] query_id0;  //--->query_id, page value that requestd
wire [5:0] query_id1;
wire [5:0] query_id2;
wire [5:0] query_id3;
wire [DATA_W+5:0] response0; //resonsder out-->response to ants
wire [DATA_W+5:0] response1; 
wire [DATA_W+5:0] response2;
wire [DATA_W+5:0] response3;


noc #(N, DATA_W,RESP_W,REQ_W,DEPTH) noc 
		(clk,reset,
		request0, //request page id,16~64
		request1,  //-->request_id
		request2,  
		request3,
		reply0,  //--->reply from ants 
		reply1,
		reply2,
		reply3,
		query_id0,  //--->query_id, page value that requestd
		query_id1,
		query_id2,
		query_id3,
		response0, //resonsder out-->response to ants
		response1, 
		response2,
		response3);

always 
	#2 clk <= ~clk;

initial begin
	clk=0;
	reset=1'b0;
	// request0=60;
	// request1=63;
	// request2=1;
	// request3=2;

	reply0=0;
	reply1=1;
	reply2=2;
	reply3=3;

	#5 reset=1;
	#5 reset=0;
	#5
	request0=60;
	// request1=32;
	// request2=63;
	// request3=0;
end
endmodule