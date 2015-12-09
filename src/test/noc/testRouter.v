/*
TODO:
dataOutE,dataOutW,dataOutL, no signal.
lunch,lunch,lunch!!!
 */

module testRouter;
parameter WIDTH = 16;
parameter DEPTH = 32;


reg clk, reset;
reg readFullE,readFullW,readFullL;
reg read_almostfullE,read_almostfullW,read_almostfullL;
reg disableE,disableW,disableL;
reg[1:0] E_to,W_to,L_to;

wire writeE,writeW,writeL;
wire [WIDTH-1:0] dataInE,dataInW,dataInL;
//out put of noc router
wire [WIDTH-1:0] dataOutE,dataOutW,dataOutL;
wire writeOutE,writeOutW,writeOutL;
wire fullE, almost_fullE, fullW, almost_fullW, fullL, almost_fullL;


writer #(WIDTH) wE (clk, reset, fullE, almost_fullE, 2'b00, E_to,disableE, dataInE, writeE);
writer #(WIDTH) wW (clk, reset, fullW, almost_fullW, 2'b10, W_to,disableW, dataInW, writeW);
writer #(WIDTH) wL (clk, reset, fullL, almost_fullL, 2'b11, L_to,disableL, dataInL, writeL);

//always @(*)begin
	//$display($time,":dataOutE=%b,dataOutW=%b,dataOutL=%b",dataOutE,dataOutW,dataOutL);
	
//end

//router local ip=00
noc_router #(WIDTH,DEPTH,2'b00) router (clk, reset,  
          writeE, writeW, writeL, //write ports
          readFullE,readFullW,readFullL,  //destination port is full
          read_almostfullE,read_almostfullW,read_almostfullL, //destination port is almost full
          dataInE, dataInW, dataInL, //write data ports

          dataOutE, dataOutW, dataOutL, //output ports
          writeOutE, writeOutW, writeOutL,  //connect to write port of destination
          fullE, fullW,fullL, almost_fullE,  almost_fullW, almost_fullL //full outputs from FIFOs
);




initial begin
	
	clk <= 1'b0;
	reset <= 1'b0;
	disableE<=0;
	disableW<=0;
	disableL<=0;
	E_to<=4'b01;
	W_to<=4'b01;
	L_to<=4'b00;

	#1 reset <= 1'b1; 
	#3 reset <= 1'b0;
	//#300 disableE<=1;
	
	#100 disableE<=1;
	disableW<=1;
	disableL<=1;

end

always 
	#2 clk <= ~clk;

endmodule


module writer 
# (parameter  WIDTH=32)
(input clk,
input reset, 
input full,
input almost_full,
input [1:0] id,
input [1:0] to,
input disableme,
output reg [WIDTH-1:0] dataOut,
output reg write);
//dataOut from writer is dataIn for fifo
//[disableme] disable =1, do not write. 
reg [10:0] count;
reg [2:0] east;
reg [2:0] west;
reg [2:0] local;
always @ (posedge clk, posedge reset) begin
	if (reset) begin
		dataOut <=0;
		write <=0;
		count <=0;
		east=2'b00;
		west=2'b01;
		local=2'b10;

	end
	else begin
		if ((write & almost_full)|(~write & full)| disableme) // note that just checking for full should be fine
			write <=1'b0;
		else begin
			write <= 1'b1;
			//dataOut[0]=1, isValid
			//dataOut[2:1] 00 East, 01 West, 10 local  
			dataOut <= {count,id,to,1'b1}; //write to the [to] router
			//dataOut <= 16'b0000000000000101;
			count <= count + 1;
			//$display($time,"dataOut=%b",dataOut);
		end 
	end
end
endmodule

