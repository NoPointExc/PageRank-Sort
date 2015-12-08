module responder 
#(parameter DATA_W=16,RESP_W=DATA_W+6+3)
(input clk, input reset, 
input full, input almost_full, 
input [1:0] id, 
input [11:0] dataIn, //From requestor NOC
input [DATA_W-1:0] reply,
output reg [WIDTH:0] dataOut, output reg write //To responder NoC
);

//Packet format:
//                      23-3                  2-1          0
//                     ID/Data              Dest Port       Valid
//                    23-9/ 8-3
//                    data/reg_id

//get value from ants
reg valid;
reg [1:0] dest;
reg [5:0] reg_id;



always @(dataIn)begin
	valid=dataIn[0];
	dest=dataIn[4:3]
	reg_id=dataIn[11:5];
	
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		dataOut<=0;
		write<=0;
		dest<=0;
		reg_id<=0;
	end
	else if(valid) begin
		if ((write & almost_full)|(~write & full)) begin
			write <=1'b0;
		end
		else begin
			write <=1'b1;
			dataOut<={data,reg_id,dest,valid};
			valid<=0; //send out, cancel request
		end
	end
	else begin  //not valid
		write <=1'b0;
	end
end

endmodule