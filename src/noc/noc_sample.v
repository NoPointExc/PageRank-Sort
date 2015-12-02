module noc_router 
(input clk, input reset, 
 input writeE, 
 input writeW, 
 input writeL, //write ports
 input [15:0] dataInE, 
 input [15:0] dataInW, 
 input [15:0] dataInL, //write data ports
 output  [15:0] dataOutE,
 output  [15:0] dataOutW,
 output  [15:0] dataOutL, //output ports
 output  fullE, 
 output   almost_fullE, 
 output   fullW, 
 output   almost_fullW, 
 output   fullL, 
 output   almost_fullL //full outputs from FIFOs
 );


wire readE, readW, readL; //output from arbiter, input to FIFO
wire [15:0] dataOutFifoE, dataOutFifoW, dataOutFifoL; //output from FIFO, input to arbiter
wire emptyE, almost_emptyE, emptyW, almost_emptyW, emptyL, almost_emptyL; //output from FIFO, input to arbiter
wire [15:0] dataOutE_temp, dataOutW_temp, dataOutL_temp; //output from arbiter, input to outport 

fifo_improved fifoE (clk,  reset,  writeE,  readE, dataInE, dataOutFifoE, fullE, almost_fullE, emptyE, almost_emptyE);

fifo_improved fifoW (clk,  reset,  writeW,  readW, dataInW, dataOutFifoW, fullW, almost_fullW, emptyW, almost_emptyW);

fifo_improved fifoL (clk,  reset,  writeL,  readL, dataInL, dataOutFifoL, fullL, almost_fullL, emptyL, almost_emptyL);

arbiter a(clk, reset, emptyE, almost_emptyE, dataOutFifoE, 
                      emptyW, almost_emptyW, dataOutFifoW,  
                      emptyL, almost_emptyL, dataOutFifoL, 
                      readE,   readW, readL , 
		      dataOutE_temp, dataOutW_temp, dataOutL_temp); 

 
outport o(clk, reset, dataOutE_temp, dataOutW_temp, dataOutL_temp, dataOutE, dataOutW, dataOutL);

endmodule

module outport (input clk, input reset, 
	       input [15:0] dataOutE_temp, input [15:0] dataOutW_temp, input [15:0] dataOutL_temp,
	       output reg [15:0] dataOutE, output reg [15:0] dataOutW, output reg [15:0] dataOutL);


always @ (posedge clk, posedge reset)begin

	if (reset) begin
		dataOutE <= 0;
		dataOutW <= 0;
		dataOutL <= 0;
	end
	else begin
		dataOutE <= dataOutE_temp;
	        dataOutW <= dataOutW_temp;
                dataOutL <= dataOutL_temp;
	end	
	
end

endmodule 	  



//Arbiter+crossbar
module arbiter (input clk, input reset, 
	        input emptyE, input almost_emptyE, input [15:0] dataInFifoE,
		input emptyW, input almost_emptyW, input [15:0] dataInFifoW,
		input emptyL, input almost_emptyL, input [15:0] dataInFifoL,
		output reg readE, output reg readW, output reg readL,
		output reg [15:0] dataOutE_temp, output reg [15:0] dataOutW_temp, output reg [15:0] dataOutL_temp);

localparam East = 2'b00, West = 2'b01, Local = 2'b10;

//generates data at the dataInFifo* ports
always @ (posedge clk, posedge reset) begin

	if (reset) begin
		readE <=1'b0;
		readW <=1'b0;
		readL <=1'b0;
	end
	else begin
		if ((almost_emptyE & readE) | (emptyE))
			readE <= 1'b0;
		else 
			readE <= 1'b1;

		if ((almost_emptyW & readW) | (emptyW))
			readW <= 1'b0;
		else 
			readW <= 1'b1;

		if ((almost_emptyL & readL) | (emptyL))
			readL <= 1'b0;
		else 
			readL <= 1'b1;

	end

end

//Looks at data at the dataInFifo* ports and pushes them to the output
//crossbar + outputreg

always @ (*) begin
	
	if (dataInFifoL[0]==1) begin
		if (dataInFifoL[2:1]==East)
			dataOutE_temp = dataInFifoL;
		if (dataInFifoL[2:1]==West)
			dataOutW_temp = dataInFifoL;
		if (dataInFifoL[2:1]==Local)
			dataOutL_temp = dataInFifoL;
	end

	if (dataInFifoW[0]==1) begin
		if (dataInFifoW[2:1]==East)
			dataOutE_temp = dataInFifoW;
		if (dataInFifoW[2:1]==West)
			dataOutW_temp = dataInFifoW;
		if (dataInFifoW[2:1]==Local)
			dataOutL_temp = dataInFifoW;
	end

	if (dataInFifoE[0]==1) begin
		if (dataInFifoE[2:1]==East)
			dataOutE_temp = dataInFifoE;
		if (dataInFifoE[2:1]==West)
			dataOutW_temp = dataInFifoE;
		if (dataInFifoE[2:1]==Local)
			dataOutL_temp = dataInFifoE;
	end
end

			
endmodule




