/*
TODO:may lose requests
 */


module requester   #(parameter WIDTH=12)
 (input clk, input reset, 
input full, input almost_full, 
input [1:0] id,
input [5:0] request,
output reg [WIDTH-1:0] dataOut, output reg write //To NoC
);

//Packet format:
//                      11-5         4-3                2-1          0
//                     Data       Src port        Dest Port       Valid
//                     6 bits        2bit             2 bits     1 bit
//                      regid
//                 
 

reg [1:0] dest; //0,1,2,3
reg [2:0] count;
reg valid;
//request 0~15, dest=0, 16~31, dest=1, 32~47, dest=2, 48~63 dest=3
//dest=request/16;
always@(*)begin
	valid=1; //new request
	if(request<16)begin
		dest=0;
	end
	else if(request<32)begin
		dest=1;
	end
	else if(request<48)begin
		dest=2;
	end
	else begin
		dest=3;
	end
end

always @(*)begin
	
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		dataOut <=0;
		write <=0;
		dest <=0;
		valid<=0;	
	end
	else if(valid) begin  
		if ((write & almost_full)|(~write & full)) begin
			write <=1'b0;
		end
		else begin //issue a request
			write <=1'b1;
			dataOut<={request,id,dest,valid};
			valid<=0; //send out, cancel request
		end
	end
	else begin  //not valid
		write <=1'b0;
	end
end

endmodule