/*
TODO:
1) splite input task into 4 ants
2) merge results from ants
3) sort
 */
module pageRank #(parameter M=64, WIDTH=16)
(input clk,
input reset,
input [M*M-1:0]adj,
input [M*WIDTH-1:0]nodeWeight,
output reg [10*WIDTH-1:0]top10Vals,
output reg [10*6-1:0] top10IDs,
output wire [WIDTH-1:0] nodeVal0,
output wire [WIDTH-1:0] nodeVal16,
output wire [WIDTH-1:0] nodeVal32,
output wire [WIDTH-1:0] nodeVal48
);
parameter N=16,RESP_W=WIDTH+6+3,REQ_W=12,DEPTH=32;
wire [5:0] query [3:0];
wire [WIDTH+5:0] response [3:0];

wire [5:0] request [3:0];
wire [WIDTH-1:0] reply[3:0];
wire [WIDTH-1:0] node0Val[3:0];
assign nodeVal0= node0Val[0];
assign nodeVal16=node0Val[1];
assign nodeVal32=node0Val[2];
assign nodeVal48=node0Val[3];

generate
	genvar i;
	for(i=0;i<4;i=i+1)begin
		ant #(N,M,WIDTH) ant(clk,reset,
			adj[i*N*M+:N*M],nodeWeight[i*N*WIDTH+:N*WIDTH],i[1:0],query[i],response[i],
			request[i],reply[i],node0Val[i]);
	end
endgenerate

noc #(N, WIDTH,RESP_W,REQ_W,DEPTH) noc (clk,reset,
		request[0], request[1],  request[2],  request[3],//-->request_id,request page id,16~64
		reply[0],  reply[1],reply[2],reply[3], //--->reply from ants
		query[0],  query[1],query[2],query[3],//--->query_id, page value that requestd
		response[0], response[1], response[2],response[3]);//resonsder out-->response to ants

endmodule
