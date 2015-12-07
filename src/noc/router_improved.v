module noc_router 
# (parameter  WIDTH=16,DEPTH=32,LOCAL_IP=2'b01)
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




wire readE, readW, readL; //output from arbiter, input to FIFO
wire [WIDTH-1:0] dataOutFifoE, dataOutFifoW, dataOutFifoL; //output from FIFO, input to arbiter
wire emptyE, almost_emptyE, emptyW, almost_emptyW, emptyL, almost_emptyL; //output from FIFO, input to arbiter
wire [WIDTH-1:0] dataOutE_temp, dataOutW_temp, dataOutL_temp; //output from arbiter, input to outport 

fifo_improved #(WIDTH,DEPTH,ADDWIDTH) fifoE (clk,  reset,  writeE,  readE, dataInE, dataOutFifoE, fullE, almost_fullE, emptyE, almost_emptyE);

fifo_improved #(WIDTH,DEPTH,ADDWIDTH) fifoW (clk,  reset,  writeW,  readW, dataInW, dataOutFifoW, fullW, almost_fullW, emptyW, almost_emptyW);

fifo_improved #(WIDTH,DEPTH,ADDWIDTH) fifoL (clk,  reset,  writeL,  readL, dataInL, dataOutFifoL, fullL, almost_fullL, emptyL, almost_emptyL);

arbiter #(WIDTH,LOCAL_IP) a(clk, reset, emptyE, almost_emptyE, dataOutFifoE, 
                      emptyW, almost_emptyW, dataOutFifoW,  
                      emptyL, almost_emptyL, dataOutFifoL, 
                      readFullE,readFullW,readFullL,     //read full ports of destination
                      read_almostfullE,read_almostfullW,read_almostfullL, //read almost_full port of destination
                      writeOutE_temp, writeOutW_temp, writeOutL_temp,   //connect to write port of destination
                      readE,   readW, readL , 
		      dataOutE_temp, dataOutW_temp, dataOutL_temp); 

 
outport #(WIDTH,LOCAL_IP) o(clk, reset, 
		dataOutE_temp, dataOutW_temp, dataOutL_temp,
		writeOutE_temp,writeOutW_temp,writeOutL_temp,
		dataOutE, dataOutW, dataOutL,
		writeOutE,writeOutW,writeOutL
		);

endmodule

module outport # (parameter  WIDTH=16,LOCAL_IP=2'b00) (input clk, input reset, 
	       input [WIDTH-1:0] dataOutE_temp, input [WIDTH-1:0] dataOutW_temp, input [WIDTH-1:0] dataOutL_temp,
	       input writeOutE_temp, input writeOutW_temp,input writeOutL_temp,
	       output reg [WIDTH-1:0] dataOutE, output reg [WIDTH-1:0] dataOutW, output reg [WIDTH-1:0] dataOutL,
	       output reg writeOutE,output reg writeOutW,output reg writeOutL
	       );
	
	always @ (posedge clk, posedge reset)begin
		if (reset) begin
			dataOutE = 0;
			dataOutW = 0;
			dataOutL = 0;
			writeOutE=0;
			writeOutW=0;
			writeOutL=0;
		end
		else begin				
				dataOutE = dataOutE_temp;
		        dataOutW = dataOutW_temp;
	            dataOutL = dataOutL_temp;

	            dataOutE[LOCAL_IP+1]=1'b0;
				dataOutW[LOCAL_IP+1]=1'b0;
				dataOutL[LOCAL_IP+1]=1'b0;

	            writeOutE=writeOutE_temp;
				writeOutW=writeOutW_temp;
				writeOutL=writeOutL_temp;
		end		
	end

endmodule   


//this one does not dequeue items that are not transmitted
module arbiter  #(parameter WIDTH=16,LOCAL_IP=2'b00) (input clk, input reset, 
	    input emptyE, input almost_emptyE, input [WIDTH-1:0] dataInFifoE,
		input emptyW, input almost_emptyW, input [WIDTH-1:0] dataInFifoW,
		input emptyL, input almost_emptyL, input [WIDTH-1:0] dataInFifoL,
		input readFullE,input readFullW,input readFullL,     //read full ports of destination
       	input read_almostfullE,input read_almostfullW,input read_almostfullL, //read almost_full port of destination
       	output reg writeE,output reg writeW,output reg writeL,   //connect to write port of destination
		output reg readE, output reg readW, output reg readL,
		output reg [WIDTH-1:0] dataOutE_temp, output reg [WIDTH-1:0] dataOutW_temp, output reg [WIDTH-1:0] dataOutL_temp);

localparam East = 2'b00, West = 2'b01, Local = 2'b10;
localparam NextIP0=LOCAL_IP==3?0:(LOCAL_IP+1);
localparam NextIP1=NextIP0==3?0:(NextIP0+1);
localparam LastIP=LOCAL_IP==0?2'b11:(LOCAL_IP-1);

reg[WIDTH-1:0] dataIn[2:0];//reg [15:0] dataE, dataW, dataL; 

reg [WIDTH-1:0] dataInPrevE, dataInPrevW, dataInPrevL; //stores data that was not transmitted


reg retainPrevE, retainPrevW, retainPrevL;

reg readE_temp, readW_temp, readL_temp;

reg[2:0] retain; //reg retainE, retainW, retainL;

//write control signal--------------------------------
reg wrt_ableE,wrt_ableW,wrt_ableL; //write able signal
wire hasOutE, hasOutW, hasOutL;  //outport has value to output
reg [2:0] isBlock;                //port is block (outputing or cant' write to next router)

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
	readE = readE_temp & (~retain[0]);
	readW = readW_temp & (~retain[1]);
	readL = readL_temp & (~retain[2]);
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
		dataInPrevE <= dataIn[0];//dataInFifoE;
		retainPrevE <= retain[0];
		dataInPrevW <= dataIn[1];//dataInFifoW;
		retainPrevW <= retain[1];
		dataInPrevL <= dataIn[2];//dataInFifoL;
		retainPrevL <= retain[2];
	end
end 

always @ (*) begin
	dataIn[0] = retainPrevE? dataInPrevE: dataInFifoE;
	dataIn[1] = retainPrevW? dataInPrevW: dataInFifoW;
	dataIn[2] = retainPrevL? dataInPrevL: dataInFifoL;
end


//token generate
reg[2:0] token;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		token=0;
	end
	else begin
		if(token==2) token=0;
		else token=token+1;
	end
end




//reg portE, portW, portL;
reg[2:0] portBusy; //0-E, 1-W, 2-L

//reg grantedE, grantedW, grantedL;
reg[2:0] granted;

reg[2:0] pos;


//generate destination
reg[2:0] dst [2:0];



//localparam East = 2'b00, West = 2'b01, Local = 2'b10;
//         L
//      W -|- E    00- 01- 10- 11
//     xxx....XXXaaaav
//     a:address, v:valid 
//     address:3210
integer k;

always @(*)begin
	for(k=0;k<3;k=k+1)begin
		if(dataIn[k][0]==1)begin
			dst[k]=3'b0;
			if(dataIn[k][LOCAL_IP+1]==1)begin
				dst[k][Local]=1; //go Local
				//dataIn[k][LOCAL_IP+1]=0;
			end
			if(dataIn[k][NextIP0+1]==1 || dataIn[k][NextIP1+1])begin
				dst[k][East]=1;  //go East
			
			end
			if(dataIn[k][LastIP+1]==1)begin
				dst[k][West]=1;  //go West
			end
		end
		//$display(dst);
	end
end





//Looks at data at the dataInFifo* ports and pushes them to the output
//crossbar + outputreg
integer i;
always@(*)begin
	portBusy=isBlock;
	granted=3'b0;
	retain=3'b0;
	//genertate proprity
	for(i=0;i<3;i=i+1)begin
		pos=i+token;
		if(pos>2) pos=pos-3;
		if(dataIn[pos][0]==1)begin  //if is a valid value
			if ((dst[pos][East]==1)&(~portBusy[0])) begin  //one package may go to multi direction
				dataOutE_temp=dataIn[pos];
				//dataOutE_temp[LOCAL_IP+1]=0; //cancel back-repeat
				portBusy[0]=1;
				granted[pos]=1;

			end
			if ((dst[pos][West]==1)&(~portBusy[1])) begin 
				dataOutW_temp=dataIn[pos];
				//dataOutW_temp[LOCAL_IP+1]=0; //cancel back-repeat
				portBusy[1]=1;
				granted[pos]=1;
			end
			if ((dst[pos][Local]==1)&(~portBusy[2])) begin 
				dataOutL_temp=dataIn[pos];
				//dataOutL_temp[LOCAL_IP+1]=0;
				portBusy[2]=1;
				granted[pos]=1;
			end
			if(dst[pos]==3'b0)begin
				granted[pos]=1;
			end

			if(granted[pos]==0) retain[pos]=1; //drop no destionation package
		end
	end
end



//write control--------------------------------
//detect output has data or not
assign hasOutE= dataOutE_temp[0] ;
assign hasOutW= dataOutW_temp[0] ;
assign hasOutL= dataOutL_temp[0] ;

//control wrt_ables
always @(posedge clk or posedge reset) begin
	if (reset) begin
		wrt_ableE<=1'b0;
		wrt_ableW<=1'b0;
		wrt_ableL<=1'b0;
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
	end
end

always @ (*) begin
	if(wrt_ableE & hasOutE)writeE=1;
	else writeE=0;
	if(wrt_ableW & hasOutW) writeW=1;
	else writeW=0;
	if(wrt_ableL & hasOutL) writeL=1;
	else writeL=0;

end

//block a port is outputting or next router is full
always @(*) begin
	if (reset) begin
		isBlock=3'b0;	
	end
	else begin
		isBlock[0] = hasOutE & (!wrt_ableE);
		isBlock[1] = hasOutW & (!wrt_ableW);
		isBlock[2] = hasOutL & (!wrt_ableL);
		//isBlock=3'b0; 
	end
end

//wrt_control-------------------------------------------------
			
//always @(*)begin
	//$display("----------");
	//$display($time,"pos=%d",pos);
	//$display($time,"dataIn=%p",dataIn);
//end
			
endmodule







