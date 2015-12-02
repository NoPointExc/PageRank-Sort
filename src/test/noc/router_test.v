module noc_tb;


reg clk, reset, disableE, disableW, disableL;
wire writeE, writeW, writeL;
wire [15:0] dataInE, dataInW, dataInL;

wire [15:0] dataOutE, dataOutW, dataOutL;
wire fullE, fullW, fullL;
wire almost_fullE, almost_fullW, almost_fullL;


noc_router noc1 (clk, reset,  
          writeE, writeW, writeL, //write ports
          dataInE, dataInW, dataInL, //write data ports
          dataOutE, dataOutW, dataOutL, //output ports
          fullE, almost_fullE, fullW, almost_fullW, fullL, almost_fullL //full outputs from FIFOs
);


//Two writers contending for the west port.
writer wE (clk, reset, fullE, almost_fullE, 2'b00, disableE, dataInE, writeE);

writer wL (clk, reset, fullL, almost_fullL, 2'b10, disableL, dataInL, writeL);

assign writeW = 0;
assign dataInW = 0;

//assign writeL = 0;
//assign dataInL = 0;



always 
	#2 clk <= ~clk;


initial begin
	
	clk <= 1'b0;
	reset <= 1'b0;
	disableE<=0;
	disableL<=0;

	#1 reset <= 1'b1; 
	#3 reset <= 1'b0;
	#300 disableE<=1;
	
 
end

endmodule


module writer (input clk, input reset, input full, input almost_full, input [1:0] id, input disableme, output reg [15:0] dataOut, output reg write);
//dataOut from writer is dataIn for fifo

reg [9:0] count;

always @ (posedge clk, posedge reset) begin
	if (reset) begin
		dataOut <=0;
		write <=0;
		count <=0;
	end
	else begin
		if ((write & almost_full)|(~write & full)| disableme) // note that just checking for full should be fine
			write <=1'b0;
		else begin
			write <= 1'b1;
			dataOut <= {count,id,2'b01,1'b1}; //write to the WEST port
			count <= count + 1;
		end 
	end
end

endmodule	
