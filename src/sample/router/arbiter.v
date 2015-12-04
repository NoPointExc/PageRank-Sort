/*
 TODO:
 
 */

//selecter
module selecter #(parameter WIDTH=16) (input sel, input [WIDTH-1:0] fromFifo, input [WIDTH-1:0] fromPerious, output [WIDTH-1:0] selted);
	assign selted=sel?fromPerious:fromFifo;
endmodule

//
module ARC #(parameter WIDTH=16,LOCAL_IP=2'b00) (input clk, input reset,
	input [WIDTH-1:0] selectedE,input [WIDTH-1:0] selectedW,input [WIDTH-1:0] selectedL,
	input [2:0] isBlock,
	output  grantedE, output  grantedW,output  grantedL,
	output  [WIDTH-1:0] outE,output  [WIDTH-1:0] outW,output  [WIDTH-1:0] outL
	);
	

	always @(*)begin
		//$display($time,":outE=%b, outW=%b, outL=%b",outE, outW, outL);
		//$display($time,": out=%p",out);
		//$display($time," : grantedE=%d,grantedW=%d,grantedL=%d",grantedE,grantedW,grantedL);
		//$display($time," : granted%b",granted);
	end

	localparam East = 2'b00, West = 2'b01, Local = 2'b10;

	wire [WIDTH-1:0]in[2:0];
	assign in[0] = selectedE;
	assign in[1] = selectedW;
	assign in[2] = selectedL;
	reg[2:0] granted;
	assign grantedE= granted[0];
	assign grantedW = granted[1];
	assign grantedL = granted[2];

	reg[WIDTH-1:0] out[2:0];
	assign outE = out[0];
	assign outW = out[1];
	assign outL = out[2];
	
 	
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

 	integer i;
 	integer k;
 	reg[2:0] pos;
 	reg[2:0] busy;
 	//generate distination
 	reg[1:0] dst [2:0];
 	
 	//         L
 	//      W -|- E    00- 01- 10- 11
 	always @(*)begin
 		
 		//>LOCAL_IP , to East; <LOCAL_IP, to West
 		for(k=0;k<3;k=k+1)begin
 			//$display($time,"*",1);

 			if(in[k][2:1]==LOCAL_IP) dst[k]=2'b10;  //local
 			else if(in[k][2:1]>LOCAL_IP) dst[k]=2'b00;  //East
 			else dst[k]=2'b01;  //west

 			//$display($time,"dst=",dst[k]);
 		end
 		//$display($time,"in[][2:1]=%b %b %b",in[0][2:1],in[1][2:1],in[2][2:1]);
 		//$display($time,"dst=%b %b %b",dst[0],dst[1],dst[2]);
 	end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			// reset
			busy=3'b0;	
			out[0]=16'bx;
			out[1]=16'bx;
			out[2]=16'bx;
			granted=3'b1;		
		end
		else begin
			busy=isBlock;
			//$display($time,"busy=%b",busy);
			//$display("--------");
			//$display($time,"token=%d",token);
			for(i=0;i<3;i=i+1)begin
				pos=i+token;
				if(pos>2) pos=pos-3;
				//$display($time,"pos=%d",pos);
				
				//$display($time,"dst=%b",dst[0],dst[1],dst[2]);
				if(in[pos][0]==1)begin
					if(busy[dst[pos]]==0)begin
						granted[pos]=0;
						//$display($time,"release, busy[dst[pos]]=%d",pos,busy[dst[pos]]);
						busy[dst[pos]]=1; //set busy
							
					end
					else begin
						//busy, then granted =1, save			
						granted[pos]=1;
						//$display($time,"hold, busy[dst[pos]]=%d",pos,busy[dst[pos]]);
					end
				end
				else begin
					granted[pos]=0;
				end
			//$display($time,"busy=%b",busy);
			if(granted[pos]==0 && in[pos][0]) begin
				out[dst[pos]]=in[pos];
			end
			end 	
		end
	end
endmodule



module myreg #(parameter  W=16)(input [W-1:0] xin, input clear,  input clk, output reg [W-1:0] xout);

	always @ (posedge clk) begin
		if(clear) xout <= 0;
		else xout <= xin;
	end

endmodule



//Arbiter+crossbar
module arbiter #(parameter WIDTH=16,LOCAL_IP=2'b00) (input clk, input reset, 
	    input emptyE, input almost_emptyE, input [WIDTH-1:0] dataInFifoE,
		input emptyW, input almost_emptyW, input [WIDTH-1:0] dataInFifoW,
		input emptyL, input almost_emptyL, input [WIDTH-1:0] dataInFifoL,
		input readFullE,input readFullW,input readFullL,     //read full ports of destination
       input read_almostfullE,input read_almostfullW,input read_almostfullL, //read almost_full port of destination
       output reg writeE,output reg writeW,output reg writeL,   //connect to write port of destination
		output reg readE, output  reg  readW, output reg  readL,
		output  [WIDTH-1:0] dataOutE_temp, output  [WIDTH-1:0] dataOutW_temp, output  [WIDTH-1:0] dataOutL_temp);

localparam East = 2'b00, West = 2'b01, Local = 2'b10;

reg read_ableE,read_ableW,read_ableL;
reg wrt_ableE,wrt_ableW,wrt_ableL; //write able signal
wire grantedE_temp,grantedW_temp,grantedL_temp; 
wire [WIDTH-1:0] selectedE,selectedW,selectedL;
wire [WIDTH-1:0] periousE,periousW,periousL;
wire hasOutE, hasOutW, hasOutL;

reg [2:0] isBlock;


always @(*)begin
	//$display($time,":dataOutE_temp=%b, dataOutW_temp=%b, dataOutL_temp=%b",dataOutE_temp, dataOutW_temp, dataOutL_temp);
	//$display($time," : readE=%d,readW=%d,readL=%d",readE,readW,readL);
	//$display($time," :writeE=%d,writeW=%d,writeL=%d ",writeE,writeW,writeL);
	//$display($time," :hasOutE=%d,hasOutW=%d,hasOutL=%d",hasOutE,hasOutW,hasOutL);
end

//detect output has data or not
assign hasOutE= dataOutE_temp[0] ;
assign hasOutW= dataOutW_temp[0] ;
assign hasOutL= dataOutL_temp[0] ;

//selecter, select from perious and FiFo by granted
selecter #(WIDTH) selE(grantedE_temp,dataInFifoE,periousE,selectedE); 
selecter #(WIDTH) selW(grantedW_temp,dataInFifoW,periousW,selectedW); 
selecter #(WIDTH) selL(grantedL_temp,dataInFifoL,periousL,selectedL);

myreg #(WIDTH) perE(selectedE,clear,clk,periousE);
myreg #(WIDTH) perW(selectedW,clear,clk,periousW);
myreg #(WIDTH) perL(selectedL,clear,clk,periousL);

ARC #(WIDTH,LOCAL_IP) arc(clk, reset, selectedE,selectedW,selectedL,
	isBlock,   //input wether port have been blocked. blocked port will not give new gratuate for incoming packages.
	grantedE_temp,grantedW_temp,grantedL_temp,
	dataOutE_temp,dataOutW_temp,dataOutL_temp);  //give grante to packages in input port waitting list

//generate read_able signal
always @ (posedge clk, posedge reset) begin

	if (reset) begin
		read_ableE <=1'b0;
		read_ableW <=1'b0;
		read_ableL <=1'b0;
	end
	else begin

		if ((almost_emptyE & readE) | (emptyE) )
			read_ableE <= 1'b0;
		else 
			read_ableE <= 1'b1;

		if ((almost_emptyW & readW) | (emptyW) )
			read_ableW <= 1'b0;
		else 
			read_ableW <= 1'b1;

		if ((almost_emptyL & readL) | (emptyL))
			read_ableL <= 1'b0;
		else 
			read_ableL <= 1'b1;
	end
	//$display($time," : read_ableE=%d,read_ableW=%d,read_ableL=%d",read_ableE,read_ableW,read_ableL);
end

always @ (*) begin
	readE = read_ableE & (~grantedE_temp);
	readW = read_ableW & (~grantedW_temp);
	readL = read_ableL & (~grantedL_temp);
	//$display($time," : readE=%d,readW=%d,readL=%d",readE,readW,readL);
	//$display($time," : grantedE_temp=%d,grantedW_temp=%d,grantedL_temp=%d",grantedE_temp,grantedW_temp,grantedL_temp);
end


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
	writeE = wrt_ableE & (hasOutE);
	writeW = wrt_ableW & (hasOutW);
	writeL = wrt_ableL & (hasOutL);
end

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


endmodule

