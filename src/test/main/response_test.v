module response_test;
parameter DATA_W=16,RESP_W=DATA_W+9,REQ_W=12;
reg clk;
reg reset;
reg full;
reg almost_full;
reg[1:0] id;
reg [REQ_W-1:0] dataIn; //request ,12bits
reg [DATA_W-1:0] reply;
wire [RESP_W-1:0] dataOut;  //reply
wire write;
wire [5:0] reg_id;

always #2 clk=~clk;

initial begin
	clk=1'b0;
	reset=1'b0;
	id=2;
#10 full=0;almost_full=0;dataIn=17;reply=0;
#10 full=0;almost_full=0;dataIn=659;reply=0;
#10 full=0;almost_full=0;dataIn=979;reply=0;
#10 full=0;almost_full=1;dataIn=1301;reply=0;
#10 full=0;almost_full=0;dataIn=2039;reply=0;
#10 full=1;almost_full=0;dataIn=49; reply=0;
#10 full=0;almost_full=0;dataIn=1943;reply=0;
#10 full=0;almost_full=0;dataIn=941;reply=0;
#10 full=0;almost_full=0;dataIn=941;reply=0;
#10 full=0;almost_full=0;dataIn=941;reply=0;
end


responder rsp (clk, reset, 
full, almost_full, id,dataIn,reply,
dataOut, write,reg_id);


endmodule