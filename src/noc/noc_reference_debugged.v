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


//this one does not dequeue items that are not transmitted
module arbiter (input clk, input reset, 
	        input emptyE, input almost_emptyE, input [15:0] dataInFifoE,
		input emptyW, input almost_emptyW, input [15:0] dataInFifoW,
		input emptyL, input almost_emptyL, input [15:0] dataInFifoL,
		output reg readE, output reg readW, output reg readL,
		output reg [15:0] dataOutE_temp, output reg [15:0] dataOutW_temp, output reg [15:0] dataOutL_temp);

localparam East = 2'b00, West = 2'b01, Local = 2'b10;


reg [15:0] dataE, dataW, dataL; 
reg [15:0] dataInPrevE, dataInPrevW, dataInPrevL; //stores data that was not transmitted

reg retainE, retainW, retainL;
reg retainPrevE, retainPrevW, retainPrevL;

reg readE_temp, readW_temp, readL_temp;

reg portE, portW, portL;
reg grantedE, grantedW, grantedL;

//generates data at the dataInFifo* ports
always @ (posedge clk, posedge reset) begin

	if (reset) begin
		readE_temp <=1'b0;
		readW_temp <=1'b0;
		readL_temp <=1'b0;
	end
	else begin
		if ((almost_emptyE & readE) | (emptyE) )
			readE_temp <= 1'b0;
		else 
			readE_temp <= 1'b1;

		if ((almost_emptyW & readW) | (emptyW) )
			readW_temp <= 1'b0;
		else 
			readW_temp <= 1'b1;

		if ((almost_emptyL & readL) | (emptyL) )
			readL_temp <= 1'b0;
		else 
			readL_temp <= 1'b1;

	end

end

always @ (*) begin
	readE = readE_temp & (~retainE);
	readW = readW_temp & (~retainW);
	readL = readL_temp & (~retainL);
end



always @ (posedge clk, posedge reset) begin
	if (reset) begin
		dataInPrevE <= 0;
		retainPrevE <= 0;
		dataInPrevW <= 0;
		retainPrevW <= 0;
		dataInPrevL <= 0;
		retainPrevL <= 0;
	end
	else begin
		dataInPrevE <= dataE;//dataInFifoE;
		retainPrevE <= retainE;
		dataInPrevW <= dataW;//dataInFifoW;
		retainPrevW <= retainW;
		dataInPrevL <= dataL;//dataInFifoL;
		retainPrevL <= retainL;
	end
end 

always @ (*) begin

	dataE = retainPrevE? dataInPrevE: dataInFifoE;
	dataW = retainPrevW? dataInPrevW: dataInFifoW;
	dataL = retainPrevL? dataInPrevL: dataInFifoL;

end

//Looks at data at the dataInFifo* ports and pushes them to the output
//crossbar + outputreg
always @ (*) begin
	portE=0;
	portW=0;
	portL=0;

	grantedE=0; //Updated, but note that the original code was fine for static priority.
	retainE=0;

	grantedW=0;
	retainW=0;

	grantedL=0;
	retainL=0;

	//Highest priority
	//Always granted if it needs a port
	if (dataE[0]==1) begin
		if (dataE[2:1]==East) begin
			dataOutE_temp = dataE;
			portE = 1;
		end
		if (dataE[2:1]==West) begin
			dataOutW_temp = dataE;
			portW = 1;
		end
		if (dataE[2:1]==Local) begin
			dataOutL_temp = dataE;
			portL=1;
		end
	end

	if (dataW[0]==1) begin
		if ((dataW[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataW;
			portE = 1;
			grantedW=1;
		end
		if ((dataW[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataW;
			portW = 1;
			grantedW=1;
		end
		if ((dataW[2:1]==Local)&(~portL)) begin
			dataOutL_temp = dataW;
			portL=1;
			grantedW=1;
		end
		if(grantedW==0)
			retainW=1;
	end

	if (dataL[0]==1) begin
		if ((dataL[2:1]==East) & (~portE)) begin
			dataOutE_temp = dataL; //Updated. Thanks to Daniel Chang and Minda Fang.
			portE = 1;
			grantedL=1;
		end
		if ((dataL[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataL;
			portW = 1;
			grantedL=1;
		end
		if ((dataL[2:1]==Local)&(~portL)) begin
			dataOutL_temp = dataL;
			portL=1;
			grantedL=1;
		end

		if(grantedL==0)
			retainL=1;
	end
	
	
end

			
endmodule







