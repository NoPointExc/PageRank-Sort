module request_test;
reg clk,reset;
reg [1:0]id;
reg  full_req;
reg almost_full_req;
reg [5:0] request_id;
wire [11:0] dataIn_req;
wire write_req;

always 
	#2 clk <= ~clk;

requester req (clk, reset, 
full_req, almost_full_req, id, request_id,
dataIn_req, write_req);

initial begin
	clk=1'b0;
	reset=1'b0;
	id=2;
	$monitor("%d",dataIn_req);

	#10 full_req=0;almost_full_req=0;request_id=0;
	#10 full_req=0;almost_full_req=0;request_id=20;
	#10 full_req=0;almost_full_req=0;request_id=30;
	#10 full_req=0;almost_full_req=0;request_id=40;
	#10 full_req=0;almost_full_req=0;request_id=63;
	#10 full_req=0;almost_full_req=0;request_id=0;
	#10 full_req=0;almost_full_req=1;request_id=1;
	#10 full_req=1;almost_full_req=0;request_id=2;
	#10 full_req=0;almost_full_req=0;request_id=60;
end

endmodule;