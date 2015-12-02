/*
TODO:
no myTest module for sym
XX is unhappy. I am hugry.
 */

module myTest;
reg clk, reset;
wire write0,write1,write2,write3;
reg disable0,disable1,disable2,disable3;

reg[1:0] to0,to1,to2,to3;
wire almost_full0,almost_full1,almost_full2,almost_full3;
wire full0,full1,full2,full3;

wire [15:0] dataIn0,dataIn1,dataIn2,dataIn3; 
wire [15:0] dataOut0,dataOut1,dataOut2,dataOut3;
noc #(16,32,5)net
(clk, reset, 
  write0, write1, write2,write3, //write ports
 dataIn0, dataIn1,  dataIn2,dataIn3, //write data ports
  dataOut0,dataOut1, dataOut2, dataOut3, //output ports
 full0, almost_full0, 
 full1, almost_full1, 
 full2, almost_full2,
 full3, almost_full3 //full outputs from FIFOs
 );

//dataIn, write data in net and is the output of writer
writer w0 (clk, reset, full0, almost_full0, 2'b00, to0,disable0, dataIn0, write0);
writer w1 (clk, reset, full1, almost_full1, 2'b01, to1,disable1, dataIn1, write1);
writer w2 (clk, reset, full2, almost_full2, 2'b10, to2,disable2, dataIn2, write2);
writer w3 (clk, reset, full3, almost_full3, 2'b11, to3,disable3, dataIn3, write3);

always 
	#2 clk <= ~clk;


initial begin
	clk <= 1'b0;
	reset <= 1'b0;
	disable0<=0;
	disable1<=0;
	disable2<=0;
	disable3<=0;
	to0<=2'b10;
	to1<=2'b10;
	to2<=2'b10;
	to3<=2'b10;

	#1 reset <= 1'b1; 
	#3 reset <= 1'b0;
	//#300 disableE<=1;	

end



endmodule


module writer (input clk, input reset, input full, input almost_full, input [1:0] id, input [1:0] to, input disableme, output reg [15:0] dataOut, output reg write);
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