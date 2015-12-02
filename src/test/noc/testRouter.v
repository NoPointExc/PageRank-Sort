/*
TODO:
dataOutE,dataOutW,dataOutL, no signal.
lunch,lunch,lunch!!!
 */

module testRouter;
reg clk, reset;
reg readFullE,readFullW,readFullL;
reg read_almostfullE,read_almostfullW,read_almostfullL;
reg disableE,disableW,disableL;
reg[1:0] toE,toW,toL;

wire writeE,writeW,writeL;
wire [15:0] dataInE,dataInW,dataInL;
//out put of noc router
wire [15:0] dataOutE,dataOutW,dataOutL;
wire writeOutE,writeOutW,writeOutL;
wire fullE, almost_fullE, fullW, almost_fullW, fullL, almost_fullL;


writer wE (clk, reset, fullE, almost_fullE, 2'b00, toE,disableE, dataInE, writeE);
writer wW (clk, reset, fullW, almost_fullW, 2'b01, toW,disableW, dataInW, writeW);
writer wL (clk, reset, fullL, almost_fullL, 2'b10, toL,disableL, dataInL, writeL);

always @(*)begin
	//$display($time,":dataOutE=%b,dataOutW=%b,dataOutL=%b",dataOutE,dataOutW,dataOutL);
	
end

//router local ip=00
noc_router #(16,32,2'b00) router (clk, reset,  
          writeE, writeW, writeL, //write ports
          readFullE,readFullW,readFullL,  //destination port is full
          read_almostfullE,read_almostfullW,read_almostfullL, //destination port is almost full
          dataInE, dataInW, dataInL, //write data ports

          dataOutE, dataOutW, dataOutL, //output ports
          writeOutE, writeOutW, writeOutL,  //connect to write port of destination
          fullE, almost_fullE, fullW, almost_fullW, fullL, almost_fullL //full outputs from FIFOs
);




initial begin

	clk <= 1'b0;
	reset <= 1'b0;
	disableE<=0;
	disableW<=0;
	disableL<=0;
	toE<=2'b00;
	toW<=2'b00;
	toL<=2'b00;

	#1 reset <= 1'b1; 
	#3 reset <= 1'b0;
	//#300 disableE<=1;
	
	#100 disableW<=0;

end

always 
	#2 clk <= ~clk;

endmodule

