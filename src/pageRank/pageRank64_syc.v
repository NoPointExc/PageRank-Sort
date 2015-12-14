/*
TODO:
-1) splite input task into 4 ants
-?2) merge results from ants
-3) sort
-4)sort ID
 */
module pageRank #(parameter M=64, WIDTH=16)
(input clk,
input reset,
input [M*M-1:0]adj,
input [M*WIDTH-1:0]nodeWeight,
output  [10*WIDTH-1:0]top10Vals,
output  [10*6-1:0] top10IDs,
output wire [WIDTH-1:0] nodeVal0,
output wire [WIDTH-1:0] nodeVal16,
output wire [WIDTH-1:0] nodeVal32,
output wire [WIDTH-1:0] nodeVal48
);
parameter N=16,RESP_W=WIDTH+6+3,REQ_W=12,DEPTH=32,MAX_UPDATE_TIME=400;
wire [5:0] query [3:0];
wire [WIDTH+5:0] response [3:0];

wire [5:0] request [3:0];
wire [WIDTH-1:0] reply [3:0];
wire [WIDTH-1:0] node0Val [3:0];
wire [WIDTH*N-1:0] array [3:0];
reg  done;
reg syc_in=1'b1 ; //input to ants
wire syc_out [3:0];//output from ants

assign nodeVal0= node0Val[0];
assign nodeVal16=node0Val[1];
assign nodeVal32=node0Val[2];
assign nodeVal48=node0Val[3];

always@(*)begin

	$display($time,"%d",nodeVal0);
end

//----------------update time count--------

reg [8:0] update_time;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		update_time<=0;
		done<=0;
	end
	else if (~done) begin
		update_time<=update_time+1;
		if(update_time==MAX_UPDATE_TIME) done<=1;
	end
end


//---------------cpu------------------
always @(posedge clk or posedge reset) begin
	if (reset) begin
		syc_in=1;		
	end
	else begin
		syc_in=syc_out[0]&&syc_out[1]&&syc_out[2]&&syc_out[3];
	end
end

// always @(*)begin
// 	$display($time,"syc_in=%d",syc_in);
// end
generate
	genvar i;
	for(i=0;i<4;i=i+1)begin
		ant #(N,M,WIDTH) ant(clk,reset,
			adj[i*N*M+:N*M],nodeWeight[i*N*WIDTH+:N*WIDTH],i[1:0],query[i],response[i],syc_in,
			request[i],reply[i],node0Val[i],array[i],syc_out[i]);
	end
endgenerate

//-----------------noc(ReqRouter+RespRouter+requester+responser)---------------
noc #(N, WIDTH,RESP_W,REQ_W,DEPTH) noc (clk,reset,
		request[0], request[1],  request[2],  request[3],//-->request_id,request page id,16~64
		reply[0],  reply[1],reply[2],reply[3], //--->reply from ants
		query[0],  query[1],query[2],query[3],//--->query_id, page value that requestd
		response[0], response[1], response[2],response[3]);//resonsder out-->response to ants

//---------------sortvals------------
wire enable_sort;
wire [M*WIDTH-1:0] array_in;
wire [10*WIDTH-1:0] array_out;

//merge
generate
	genvar j;
	for(j=0;j<4;j=j+1)begin
		assign array_in[j*N*WIDTH+:N*WIDTH] =array[j] ;
	end	
endgenerate


top10 # (WIDTH,M) sortvals
(clk,reset,done,array_in, top10Vals, top10IDs);




endmodule
