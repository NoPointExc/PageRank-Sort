module noc_project;
parameter  WIDTH=32,DEPTH=32, ADDWIDTH=5;

reg clk, reset, disableE, disableW, disableL;

wire writeE, writeW, writeL;
wire [15:0] dataInE, dataInW, dataInL;

wire [15:0] dataOutE, dataOutW, dataOutL;
wire fullE, fullW, fullL;
wire almost_fullE, almost_fullW, almost_fullL;


wire writeE_resp, writeW_resp, writeL_resp;
wire [15:0] dataInE_resp, dataInW_resp, dataInL_resp;

wire [15:0] dataOutE_resp, dataOutW_resp, dataOutL_resp;
wire fullE_resp, fullW_resp, fullL_resp;
wire almost_fullE_resp, almost_fullW_resp, almost_fullL_resp;



noc_router_reference noc_req (clk, reset,  
          writeE, writeW, writeL, //input write ports
          dataInE, dataInW, dataInL, //input write data ports
          dataOutE, dataOutW, dataOutL, //output ports
          fullE, almost_fullE, fullW, almost_fullW, fullL, almost_fullL //full outputs from FIFOs
);

noc_router_reference noc1_resp (clk, reset,  
          writeE_resp, writeW_resp, writeL_resp, //input write ports
          dataInE_resp, dataInW_resp, dataInL_resp, //input write data ports
          dataOutE_resp, dataOutW_resp, dataOutL_resp, //output ports
          fullE_resp, almost_fullE_resp, fullW_resp, almost_fullW_reesp, fullL_resp, almost_fullL_resp //full outputs from FIFOs
);

//
//Three requestors
requester reqE (clk, reset, fullE, almost_fullE, 2'b00, 1'b0, dataInE, writeE);

requester reqW (clk, reset, fullW, almost_fullW, 2'b01, 1'b0, dataInW, writeW);

requester reqL (clk, reset, fullL, almost_fullL, 2'b10, 1'b0, dataInL, writeL);

//Three responders
responder respE (clk, reset, fullE_resp, almost_fullE_resp, 2'b00, 1'b0, dataOutE, dataInE_resp, writeE_resp);

responder respW (clk, reset, fullW_resp, almost_fullW_resp, 2'b01, 1'b0, dataOutW, dataInW_resp, writeW_resp);

responder respL (clk, reset, fullL_resp, almost_fullL_resp, 2'b10, 1'b0, dataOutL,dataInL_resp, writeL_resp);





always 
	#2 clk <= ~clk;


initial begin
	
	clk <= 1'b0;
	reset <= 1'b0;
	disableE<=0;
	disableL<=0;

	#1 reset <= 1'b1; 
	#3 reset <= 1'b0;
	#60 disableE<=1;
	    disableW<=1;
	    disableL<=1;	
	
 
end

endmodule


//send and receive response
module responder   (input clk, input reset, 
                      input full, input almost_full, 
                      input [1:0] id, input disableme,
		      input [15:0] dataIn, //From requestor NOC	 
                      output reg [15:0] dataOut, output reg write //To responder NoC
                      );

//Packet format:
//                      15-3                  2-1          0
//                     ID/Data              Dest Port       Valid


wire [10:0] myData [7:0]; //8 11-bit registers

wire [2:0] sel;

integer i;

assign myData[0] = 0;
assign myData[1] = 1;
assign myData[2] = 2;
assign myData[3] = 3;
assign myData[4] = 4;
assign myData[5] = 5;
assign myData[6] = 6;
assign myData[7] = 7;

/*
always @ (*) begin
	for (i=0; i<8;i=i+1) begin
		myData[i] = i;
	end
end
*/


assign sel = dataIn[7:5];

always @ (posedge clk, posedge reset) begin
	if (reset) begin
		dataOut <= 0;
		write <= 0;
	end
	else begin
		if (disableme) begin
			write<=1'b0;
		end
		if (dataIn[0]) begin //if valid data
			//Your Code Here.
		end
	end
end

endmodule

//send/receive request
module requester    (input clk, input reset, 
                      input full, input almost_full, 
                      input [1:0] id, input disableme,
                      output reg [15:0] dataOut, output reg write //To NoC
                      );

//Packet format:
//                      15-5         4-3                2-1          0
//                     ID/Data       Src port        Dest Port       Valid
//                     13 bits        2bit             2 bits     1 bit
//                    15-8   7-5
//                    xxxx  regid
//                      15 -  5
//                      regData
 

    

reg [1:0] port; //L,E,W
reg [1:0] count;
reg [2:0] dest; //3 bits of data address

always @ (*) begin
	if (id==2'b00)
		port = 2'b01;
	if (id==2'b01)
		port = 2'b10;
	if (id==2'b10)
		port = 2'b00;
end

//State machine to issue read requests
always @ (posedge clk, posedge reset) begin
	if (reset) begin
		dataOut <=0;
		write <=0;
		count <=0;
		dest <=0;
	end
	else begin
		if (disableme)
			write = 1'b0;
		if (count==2'b11) begin //every 4 cycles
			if ((write & almost_full)|(~write & full)| disableme) // note that just checking for full should be fine
				write <=1'b0;
			else begin //issue a new request
				write <= 1'b1;
				dataOut <= {dest,id,port,1'b1}; //Request new data from port
				count <= count + 1;
				dest <= dest + 1; //request every thing
			end
		end 
		else begin
			count <= count + 1;
			write <= 1'b0;
		end
	end
end

endmodule	
