
module noc_router 
# (parameter  WIDTH=16,DEPTH=32,LOCAL_IP=2'b00)
(input clk, input reset, 
 input writeE, 
 input writeW, 
 input writeL, //write ports
 input readFullE,
 input readFullW,
 input readFullL, //read full ports of destination
 input read_almostfullE,
 input read_almostfullW,
 input read_almostfullL, //read almost_full port of destination
 input [WIDTH-1:0] dataInE, 
 input [WIDTH-1:0] dataInW, 
 input [WIDTH-1:0] dataInL, //write data ports
 output  [WIDTH-1:0] dataOutE,
 output  [WIDTH-1:0] dataOutW,
 output  [WIDTH-1:0] dataOutL, //output ports
 output writeOutE,
 output writeOutW,
 output writeOutL, //connect to write port of destination
 output  fullE, 
 output   almost_fullE, 
 output   fullW, 
 output   almost_fullW, 
 output   fullL, 
 output   almost_fullL //full outputs from FIFOs
 );
parameter ADDWIDTH = $clog2(DEPTH);

always @(*) begin
	$display($time,":Router: writeE=%d,writeW=%d,writeL=%d",writeE,writeW,writeL);
	//$display($time,": dataInE=%d,dataInW=%d,dataInL=%d",dataInE,dataInW,dataInL);
	//$display($time,":dataOutE=%b,dataOutW=%b,dataOutL=%b",dataOutE,dataOutW,dataOutL);
	//$display($time," :dataOutE_temp=%d, dataOutW_temp=%d, dataOutL_temp=%d",dataOutE_temp, dataOutW_temp, dataOutL_temp);
	//$display($time," readW=%d",readW);
	//$display($time," :readE=%d,readW=%d,readL=%d",readE,readW,readL);
	//$display($time,": writeOutE=%d,writeOutW=%d,writeOutL=%d",writeOutE,writeOutW,writeOutL);
end


wire readE, readW, readL; //output from arbiter, input to FIFO
wire [WIDTH-1:0] dataOutFifoE, dataOutFifoW, dataOutFifoL; //output from FIFO, input to arbiter
wire emptyE, almost_emptyE, emptyW, almost_emptyW, emptyL, almost_emptyL; //output from FIFO, input to arbiter
wire [WIDTH-1:0] dataOutE_temp, dataOutW_temp, dataOutL_temp; //output from arbiter, input to outport 
wire writeOutE_temp, writeOutW_temp, writeOutL_temp;
fifo_improved #(WIDTH,DEPTH,ADDWIDTH) fifoE (clk,  reset,  writeE,  readE, dataInE, dataOutFifoE, fullE, almost_fullE, emptyE, almost_emptyE);

fifo_improved #(WIDTH,DEPTH,ADDWIDTH) fifoW (clk,  reset,  writeW,  readW, dataInW, dataOutFifoW, fullW, almost_fullW, emptyW, almost_emptyW);

fifo_improved #(WIDTH,DEPTH,ADDWIDTH) fifoL (clk,  reset,  writeL,  readL, dataInL, dataOutFifoL, fullL, almost_fullL, emptyL, almost_emptyL);


arbiter #(WIDTH,LOCAL_IP) arb(clk, reset, 
					  emptyE, almost_emptyE, dataOutFifoE, 
                      emptyW, almost_emptyW, dataOutFifoW,  
                      emptyL, almost_emptyL, dataOutFifoL, 
                      readFullE,readFullW,readFullL,     //read full ports of destination
                      read_almostfullE,read_almostfullW,read_almostfullL, //read almost_full port of destination
                       writeOutE_temp, writeOutW_temp, writeOutL_temp,   //connect to write port of destination
                      readE,   readW, readL , 
		      dataOutE_temp, dataOutW_temp, dataOutL_temp); 

outport out (clk,reset,
		dataOutE_temp,dataOutW_temp,dataOutL_temp,
		writeOutE_temp,writeOutW_temp,writeOutL_temp,
		dataOutE,dataOutW,dataOutL,
		writeOutE,writeOutW,writeOutL
		);


endmodule

module outport # (parameter  WIDTH=16) (input clk, input reset, 
	       input [WIDTH-1:0] dataOutE_temp, input [WIDTH-1:0] dataOutW_temp, input [WIDTH-1:0] dataOutL_temp,
	       input writeOutE_temp, input writeOutW_temp,input writeOutL_temp,
	       output reg [WIDTH-1:0] dataOutE, output reg [WIDTH-1:0] dataOutW, output reg [WIDTH-1:0] dataOutL,
	       output reg writeOutE,output reg writeOutW,output reg writeOutL
	       );

	always @ (posedge clk, posedge reset)begin
		if (reset) begin
			dataOutE <= 0;
			dataOutW <= 0;
			dataOutL <= 0;
			writeOutE<=0;
			writeOutW<=0;
			writeOutL<=0;
		end
		else begin
				dataOutE <= dataOutE_temp;
		        dataOutW <= dataOutW_temp;
	            dataOutL <= dataOutL_temp;
	            writeOutE<=writeOutE_temp;
				writeOutW<=writeOutW_temp;
				writeOutL<=writeOutL_temp;
		end		
	end




endmodule 