module noc
# (parameter  WIDTH=16,DEPTH=32, ADDWIDTH=5)
(input clk, input reset, 
 input write0, 
 input write1, 
 input write2,
 input write3, //write ports
 input [WIDTH-1:0] dataIn0, 
 input [WIDTH-1:0] dataIn1, 
 input [WIDTH-1:0] dataIn2,
 input [WIDTH-1:0] dataIn3, //write data ports
 output  [WIDTH-1:0] dataOut0,
 output  [WIDTH-1:0] dataOut1,
 output  [WIDTH-1:0] dataOut2, 
 output  [WIDTH-1:0] dataOut3, //output ports
 output   full0, 
 output   full1, 
 output   full2, 
 output   full3,        
 output   almost_full0, 
 output   almost_full1, 
 output   almost_full2,
 output   almost_full3 //full & almost_full outputs from FIFOs
 );

wire [3:0] write;
reg [WIDTH-1:0] dataOut [3:0];


//write inputs to noc_router
reg [3:0] writeE;
reg [3:0] writeW;
reg [3:0] writeL;

//write readFull to noc_router 
reg [3:0] read_FullE;
reg [3:0] read_FullW;
reg [3:0] read_FullL;

//write read_almostFull to noc_router
reg [3:0] read_almostFullE;
reg [3:0] read_almostFullW;
reg [3:0] read_almostFullL;

//input data for router
reg [WIDTH-1:0] dataInE [3:0];
reg [WIDTH-1:0] dataInW [3:0];
reg [WIDTH-1:0] datainL [3:0];

//connect output data
wire [WIDTH-1:0] dataOutE [3:0];
wire [WIDTH-1:0] dataOutW [3:0];
wire [WIDTH-1:0] dataOutL [3:0];

//connect output writeEnable
wire [3:0] writeOutE;
wire [3:0] writeOutW;
wire [3:0] writeOutL;

//connect output full and almost_full
wire[3:0] fullE;
wire[3:0] fullW;
wire[3:0] fullL;

wire[3:0] almost_fullE;
wire[3:0] almost_fullW;
wire[3:0] almost_fullL;
//coverage input form 1D -> 2D

always @(*)begin
	datainL[0] = dataIn0;
	datainL[1] = dataIn1;
	datainL[2] = dataIn2;
	datainL[3] = dataIn3;	

	writeL[0] = write0;
	writeL[1] = write1;
	writeL[2] = write2;
	writeL[3] = write3;

end



assign full0 = fullL[0];
assign full1 = fullL[1];
assign full2 = fullL[2];
assign full3 = fullL[3];

assign almost_full0 = almost_fullL[0];
assign almost_full1 = almost_fullL[1];
assign almost_full2 = almost_fullL[2];
assign almost_full3 = almost_fullL[3];

assign dataOut0=dataOutL[0];
assign dataOut1=dataOutL[1];
assign dataOut2=dataOutL[2];
assign dataOut3=dataOutL[3];
//topology
/**
 * router 0 ------2+1------router 1
 * |                         |
 * |2                        |2
 * |+                        |+
 * |1                        |1
 * |                         |
 * router 3-------2+1-------router 2
 */



generate
	genvar i;

	for(i=2'b00;i<4;i=i+1)begin
		noc_router  #(WIDTH,DEPTH,i) router (clk,reset,
			writeE[i],writeW[i],writeL[i],//write ports
			read_FullE[i],read_FullW[i],read_FullL[i],//destination port is full
			read_almostFullE[i],read_almostFullW[i],read_almostFullL[i],//destination port is almost full
			dataInE[i],dataInW[i],datainL[i],//write data ports

			dataOutE[i],dataOutW[i],dataOutL[i],//output ports
			writeOutE[i],writeOutW[i],writeOutL[i],//connect to write port of destination
			fullE[i],fullW[i],fullL[i],
			almost_fullE[i],almost_fullW[i],almost_fullL[i]//full outputs from FIFOs
			);
	end

endgenerate


//         L
//      W -|- E    00- 01- 10- 11
integer j,next,last;

always @(*)begin
	for(j=0;j<4;j=j+1)begin
		next=j+1;
		if(j==3) next=0;
		last=j-1;
		if(j==0) last=3;
		writeE[j]=writeOutW[next];
		read_FullE[j]=fullW[next];
		read_almostFullE[j]=almost_fullW[next];
		dataInE[j]=dataOutW[next];

		writeW[j]=writeOutE[last];	
		read_FullW[j]=fullE[last];
		read_almostFullW[j]=almost_fullE[last];
		dataInW[j]=dataOutE[last];
	end
end

integer k,h;
always @(posedge clk)begin
	$display($time,"--------------------");
	for(k=0;k<4;k=k+1)begin
	//$display("datainL[%d]=%d,dataInE[%d]=%d,dataInW[%d]=%d",k,datainL[k],k,dataInE[k],k,dataInW[k]);
	$display("writeE[%d]=%d,writeW[%d]=%d,writeOutE[%d]=%d,writeOutW[%d]=%d",k,writeE[k],k,writeW[k],k,writeOutE[k],k,writeOutW[k]);		
	end

	// for(h=0;h<4;h=h+1)begin
	// $display("dataOutE[%d]=%d,dataOutW[%d]=%d,dataOutL[%d]=%d",h,dataOutE[h],h,dataOutW[h],h,dataOutL[h]);	
	// end

end

endmodule