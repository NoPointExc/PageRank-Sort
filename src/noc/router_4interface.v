/*
TODO:
1)update to 4 interface
2)test
 */
module noc_router 
# (parameter  WIDTH=16,DEPTH=32,LOCAL_IP=2'b00)
(input clk, input reset, 
 input writeE, 
 input writeW, 
 input writeL,
 input write3, //write ports
 input readFullE,
 input readFullW,
 input readFullL, //read full ports of destination
  input readFull3,
 input read_almostfullE,
 input read_almostfullW,
 input read_almostfullL,
 input read_almostfull3, //read almost_full port of destination
 input [WIDTH-1:0] dataInE, 
 input [WIDTH-1:0] dataInW, 
 input [WIDTH-1:0] dataInL,
 input [WIDTH-1:0] dataIn3, //write data ports
 output  [WIDTH-1:0] dataOutE,
 output  [WIDTH-1:0] dataOutW,
  output  [WIDTH-1:0] dataOutL,
 output  [WIDTH-1:0] dataOut3, //output ports
 output writeOutE,
 output writeOutW,
 output writeOutL,
 output writeOut3, //connect to write port of destination
 output  fullE, 
 output  fullW, 
 output  fullL, 
  output  full3,
 output   almost_fullE, 
 output   almost_fullW, 
 output   almost_fullL,
 output   almost_full3 //full outputs from FIFOs
 );


parameter ADDWIDTH = $clog2(DEPTH);

wire readE, readW, readL,read3; //output from arbiter, input to FIFO
wire [15:0] dataOutFifoE, dataOutFifoW, dataOutFifoL,dataOutFifo3; //output from FIFO, input to arbiter
wire emptyE, almost_emptyE, emptyW, almost_emptyW, emptyL, almost_emptyL,empty3, almost_empty3; //output from FIFO, input to arbiter
wire [15:0] dataOutE_temp, dataOutW_temp, dataOutL_temp,dataOut3_temp; //output from arbiter, input to outport 

fifo_improved #(WIDTH,DEPTH,ADDWIDTH)  fifoE (clk,  reset,  writeE,  readE, dataInE, dataOutFifoE, fullE, almost_fullE, emptyE, almost_emptyE);

fifo_improved #(WIDTH,DEPTH,ADDWIDTH)  fifoW (clk,  reset,  writeW,  readW, dataInW, dataOutFifoW, fullW, almost_fullW, emptyW, almost_emptyW);
fifo_improved #(WIDTH,DEPTH,ADDWIDTH)  fifoL (clk,  reset,  writeL,  readL, dataInL, dataOutFifoL, fullL, almost_fullL, emptyL, almost_emptyL);

fifo_improved #(WIDTH,DEPTH,ADDWIDTH)  fifo3 (clk,  reset,  write3,  read3, dataIn3, dataOutFifo3, full3, almost_full3, empty3, almost_empty3);

arbiter #(WIDTH,LOCAL_IP) arb(clk, reset,
					  emptyE, almost_emptyE, dataOutFifoE, 
                      emptyW, almost_emptyW, dataOutFifoW,  
                      emptyL, almost_emptyL, dataOutFifoL,
                      empty3, almost_empty3, dataOutFifo3, 
                      readFullE,readFullW,readFullL, readFull3,    //read full ports of destination
                      read_almostfullE,read_almostfullW,read_almostfullL,read_almostfull3, //read almost_full port of destination
                      writeOutE_temp, writeOutW_temp, writeOutL_temp, writeOut3_temp,  //connect to write port of destination
                      readE,   readW, readL , read3,
		      		  dataOutE_temp, dataOutW_temp, dataOutL_temp,dataOut3_temp); 

 
outport out(clk, reset, 
		dataOutE_temp, dataOutW_temp, dataOutL_temp,dataOut3_temp,
		writeOutE_temp,writeOutW_temp,writeOutL_temp,writeOut3_temp,
		dataOutE, dataOutW, dataOutL,dataOut3,
		writeOutE,writeOutW,writeOutL,writeOut3
		);

endmodule


module outport # (parameter  WIDTH=16) (input clk, input reset, 
	       input [WIDTH-1:0] dataOutE_temp, input [WIDTH-1:0] dataOutW_temp, input [WIDTH-1:0] dataOutL_temp,input [WIDTH-1:0] dataOut3_temp,
	       input writeOutE_temp, input writeOutW_temp,input writeOutL_temp,input writeOut3_temp,
	       output reg [WIDTH-1:0] dataOutE, output reg [WIDTH-1:0] dataOutW, output reg [WIDTH-1:0] dataOutL,output reg [WIDTH-1:0] dataOut3,
	       output reg writeOutE,output reg writeOutW,output reg writeOutL,output reg writeOut3
	       );

	always @ (posedge clk, posedge reset)begin
		if (reset) begin
			dataOutE <= 0;
			dataOutW <= 0;
			dataOutL <= 0;
			dataOut3 <= 0;
			writeOutE<=0;
			writeOutW<=0;
			writeOutL<=0;
			writeOut3<=0;
		end
		else begin
				dataOutE <= dataOutE_temp;
		        dataOutW <= dataOutW_temp;
	            dataOutL <= dataOutL_temp;
	            dataOut3 <= dataOut3_temp;
	            writeOutE<=writeOutE_temp;
				writeOutW<=writeOutW_temp;
				writeOutL<=writeOutL_temp;
				writeOut3<=writeOut3_temp;
		end		
	end

endmodule   


//this one does not dequeue items that are not transmitted
module arbiter  #(parameter WIDTH=16,LOCAL_IP=2'b00) (input clk, input reset, 
	    input emptyE, input almost_emptyE, input [15:0] dataInFifoE,
		input emptyW, input almost_emptyW, input [15:0] dataInFifoW,
		input emptyL, input almost_emptyL, input [15:0] dataInFifoL,
		input empty3, input almost_empty3, input [15:0] dataInFifo3,
		input readFullE,input readFullW,input readFullL,input readFull3,     //read full ports of destination
       	input read_almostfullE,input read_almostfullW,input read_almostfullL, input read_almostfull3,//read almost_full port of destination
       	output reg writeE,output reg writeW,output reg writeL,output reg write3,   //connect to write port of destination
		output reg readE, output reg readW, output reg readL,output reg read3,
		output reg [15:0] dataOutE_temp, output reg [15:0] dataOutW_temp, output reg [15:0] dataOutL_temp, output reg [15:0] dataOut3_temp);

localparam East = 2'b00, West = 2'b01, Local = 2'b10,PORT3=2'b11;

reg[15:0] dataIn[3:0];//reg [15:0] dataE, dataW, dataL; 

reg [15:0] dataInPrevE, dataInPrevW, dataInPrevL,dataInPrev3; //stores data that was not transmitted


reg retainPrevE, retainPrevW, retainPrevL,retainPrev3;

reg readE_temp, readW_temp, readL_temp,read3_temp;

reg[3:0] retain; //reg retainE, retainW, retainL,retain3;

//write control signal--------------------------------
reg wrt_ableE,wrt_ableW,wrt_ableL,wrt_able3; //write able signal
wire hasOutE, hasOutW, hasOutL,hasOut3;  //outport has value to output
reg [3:0] isBlock;                //port is block (outputing or cant' write to next router)



//generates data at the dataInFifo* ports
always @ (posedge clk, posedge reset) begin

	if (reset) begin
		readE_temp <=1'b0;
		readW_temp <=1'b0;
		readL_temp <=1'b0;
		read3_temp <=1'b0;
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

		if ((almost_empty3 & read3) | (empty3) )
			read3_temp <= 1'b0;
		else 
			read3_temp <= 1'b1;

	end

end






always @ (*) begin
	readE = readE_temp & (~retain[0]);
	readW = readW_temp & (~retain[1]);
	readL = readL_temp & (~retain[2]);
	read3 = read3_temp & (~retain[3]);
end



always @ (posedge clk, posedge reset) begin
	if (reset) begin
		dataInPrevE <= 0;
		retainPrevE <= 0;
		dataInPrevW <= 0;
		retainPrevW <= 0;
		dataInPrevL <= 0;
		retainPrevL <= 0;
		dataInPrev3 <= 0;
		retainPrev3 <= 0;
	end
	else begin
		dataInPrevE <= dataIn[0];//dataInFifoE;
		retainPrevE <= retain[0];
		dataInPrevW <= dataIn[1];//dataInFifoW;
		retainPrevW <= retain[1];
		dataInPrevL <= dataIn[2];//dataInFifoL;
		retainPrevL <= retain[2];
		dataInPrev3 <= dataIn[3];//dataInFifo3;
		retainPrev3 <= retain[3];
	end
end 

always @ (*) begin
	dataIn[0] = retainPrevE? dataInPrevE: dataInFifoE;
	dataIn[1] = retainPrevW? dataInPrevW: dataInFifoW;
	dataIn[2] = retainPrevL? dataInPrevL: dataInFifoL;
	dataIn[3] = retainPrev3? dataInPrev3: dataInFifo3;
end


//token generate
reg[2:0] token;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		token=0;
	end
	else begin
		if(token==3) token=0;
		else token=token+1;
	end
end




//reg portE, portW, portL;
reg[3:0] portBusy; //0-E, 1-W, 2-L, 3-3

//reg grantedE, grantedW, grantedL,granted3;
reg[3:0] granted;

reg[3:0] pos;


//generate destination
reg[2:0] dst [3:0];


//localparam East = 2'b00, West = 2'b01, Local = 2'b10;
//         L
//      W -|- E    00- 01- 10- 11
integer k;
always @(dataIn[0],dataIn[1],dataIn[2],dataIn[3])begin		
	for(k=0;k<4;k=k+1)begin
		if(dataIn[k][0]!=0)begin
			dst[k]=dataIn[k][2:1];	
		end
	end
end





//Looks at data at the dataInFifo* ports and pushes them to the output
//crossbar + outputreg
integer i;
always@(*)begin
	portBusy=isBlock;
	granted=4'b0;
	retain=3'b0;
	//genertate proprity,output dataout_temp
	dataOutE_temp=16'bx;
	dataOutW_temp=16'bx;
	dataOutL_temp=16'bx;
	dataOut3_temp=16'bx;
	for(i=0;i<4;i=i+1)begin
		pos=i+token;
		if(pos>3) pos=pos-4;
		if(dataIn[pos][0]==1)begin  //if is a valid value
			if ((dst[pos]==East)&(~portBusy[0])) begin 
				dataOutE_temp=dataIn[pos];
				portBusy[0]=1;
				granted[pos]=1;
			end
			if ((dst[pos]==West)&(~portBusy[1])) begin 
				dataOutW_temp=dataIn[pos];
				portBusy[1]=1;
				granted[pos]=1;
			end
			if ((dst[pos]==Local)&(~portBusy[2])) begin 
				dataOutL_temp=dataIn[pos];
				portBusy[2]=1;
				granted[pos]=1;
			end

			if ((dst[pos]==PORT3)&(~portBusy[3])) begin 
				dataOut3_temp=dataIn[pos];
				portBusy[3]=1;
				granted[pos]=1;
			end

			if(granted[pos]==0) begin
				retain[pos]=1;
			end 

		end
	end
end



//write control--------------------------------
//detect output has data or not
assign hasOutE= dataOutE_temp[0] ;
assign hasOutW= dataOutW_temp[0] ;
assign hasOutL= dataOutL_temp[0] ;
assign hasOut3= dataOut3_temp[0] ;
//control wrt_ables
always @(posedge clk or posedge reset) begin
	if (reset) begin
		wrt_ableE<=1'b0;
		wrt_ableW<=1'b0;
		wrt_ableL<=1'b0;
		wrt_able3<=1'b0;
	end
	else begin
		if((read_almostfullE & writeE)|readFullE)
			wrt_ableE<=1'b0;  //do not write when net router is full/almost full
		else
			wrt_ableE<=1'b1;

		if((read_almostfullW & writeW)|readFullW)
			wrt_ableW<=1'b0;
		else
			wrt_ableW<=1'b1;

		if((read_almostfullL & writeL)|readFullL)
			wrt_ableL<=1'b0;
		else
			wrt_ableL<=1'b1;

		if((read_almostfull3 & write3)|readFull3)
			wrt_able3<=1'b0;
		else
			wrt_able3<=1'b1;
	end
end

always @ (*) begin
	if(wrt_ableE & hasOutE)writeE=1;
	else writeE=0;
	if(wrt_ableW & hasOutW) writeW=1;
	else writeW=0;
	if(wrt_ableL & hasOutL) writeL=1;
	else writeL=0;
	if(wrt_able3 & hasOut3) write3=1;
	else write3=0;
end


//block a port is outputting or next router is full
always @(*) begin
	if (reset) begin
		isBlock=4'b0;	
	end
	else begin
		isBlock[0] = hasOutE & (!wrt_ableE);
		isBlock[1] = hasOutW & (!wrt_ableW);
		isBlock[2] = hasOutL & (!wrt_ableL);
		isBlock[3] = hasOut3 & (!wrt_able3);
		//isBlock=3'b0; 
	end
end
			
endmodule







