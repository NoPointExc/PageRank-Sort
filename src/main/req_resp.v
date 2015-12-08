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
