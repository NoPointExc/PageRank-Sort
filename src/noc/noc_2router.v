/*
TODO: check size/width of reply
 */

module noc 
#(parameter N=16, DATA_W=16,RESP_W=DATA_W+6+3,REQ_W=12)
(input clk,input reset,
input [5:0] request0, //request page id,16~64
input [5:0] request1,  //-->request_id
input [5:0] request2,  
input [5:0] request3,
input [DATA_W-1:0] reply0,  //--->reply from ants 
input [DATA_W-1:0] reply1,
input [DATA_W-1:0] reply2,
input [DATA_W-1:0] reply3,
output [5:0] query_id0,  //--->query_id, page value that requestd
output [5:0] query_id1,
output [5:0] query_id2,
output [5:0] query_id3,
output [DATA_W+5:0] reg response0, //resonsder out-->response to ants
output [DATA_W+5:0] reg response1, 
output [DATA_W+5:0] reg response2,
output [DATA_W+5:0] reg response3);

//map I/O to array
wire [5:0] request_id [3:0];

assign request_id[0] =request0;
assign request_id[1] =request1;
assign request_id[2] =request2;
assign request_id[3] =request3;

wire [28:0] reply [3:0];
assign reply[0] = reply0;
assign reply[1] = reply1;
assign reply[2] = reply2;
assign reply[3] = reply3;

wire [5:0] query_id [3:0];
assign query_id[0] = query_id0;
assign query_id[1] = query_id1;
assign query_id[2] = query_id2;
assign query_id[3] = query_id3;

wire write_req[3:0];
wire read_Full_req[3:0];
wire read_almostFull_req[3:0];
wire [11:0] dataIn_req[3:0];
reg [11:0] dataOut_req[3:0];
reg writeOut_req[3:0];
reg full_req[3:0];
reg almost_full_req[3:0];

noc_router #(12,DEPTH) noc_req(clk,reset,
	write_req[0],write_req[1],write_req[2],write_req[3],
	read_Full_req[0],read_Full_req[1],read_Full_req[2],read_Full_req[3],
	read_almostFull_req[0],read_almostFull_req[1],read_almostFull_req[2],read_almostFull_req[3],
	dataIn_req[0],dataIn_req[1],dataIn_req[2],dataIn_req[3], //input

	dataOut_req[0],dataOut_req[1],dataOut_req[2],dataOut_req[3],
	writeOut_req[0],writeOut_req[1],writeOut_req[2],writeOut_req[3],
	full_req[0],full_req[1],full_req[2],full_req[3],
	almost_full_req[0],almost_full_req[1],almost_full_req[2],almost_full_req[3]//output
 );


wire write_rsp[3:0];
wire read_Full_rsp[3:0];
wire read_almostFull_rsp[3:0];
wire [DATA_W-1:0] dataIn_rsp[3:0];
reg [DATA_W+5:0] dataOut_rsp[3:0]; //return to each packrank16, directly
reg writeOut_rsp[3:0];
reg full_rsp[3:0];
reg almost_full_rsp[3:0];

noc_router #(DATA_W,DEPTH) noc_rsp(clk,reset,
	write_rsp[0],write_rsp[1],write_rsp[2],write_rsp[3],
	read_Full_rsp[0],read_Full_rsp[1],read_Full_rsp[2],read_Full_rsp[3],
	read_almostFull_rsp[0],read_almostFull_rsp[1],read_almostFull_rsp[2],read_almostFull_rsp[3],
	dataIn_rsp[0],dataIn_rsp[1],dataIn_rsp[2],dataIn_rsp[3], //input

	dataOut_rsp[0],dataOut_rsp[1],dataOut_rsp[2],dataOut_rsp[3],
	writeOut_rsp[0],writeOut_rsp[1],writeOut_rsp[2],writeOut_rsp[3],
	full_rsp[0],full_rsp[1],full_rsp[2],full_rsp[3],
	almost_full_rsp[0],almost_full_rsp[1],almost_full_rsp[2],almost_full_rsp[3]//output
 );

//request_id : id of requestd page
//query_id: id of page requested for
generate
	genvar i;
	for(i=0;i<4;i=i+1)begin
		requester req (clk, reset, 
		full_req[i], almost_full_req[i], i, request_id[i],
		dataIn_req[i], write_req[i]);

		responder rsp (clk, reset, 
		full_rsp[i], almost_full_rsp[i], i,dataOut_req[i],reply[i],
		dataIn_rsp[i], write_rsp[i],query_id[i]);
	end
endgenerate


//map dataOut_rsp[]>>response0,response1,response2,response3

always @(*)begin
	
		
end


endmodule