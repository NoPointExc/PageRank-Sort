module noc_tb;


reg clk, reset;
wire write_00,write_01,write_10,write_11;
localparam clk_prd = 10;
wire [15:0] dataOut_00_tb,dataOut_01_tb,dataOut_10_tb,dataOut_11_tb;
wire [15:0] dataIn_00_tb,dataIn_01_tb,dataIn_10_tb,dataIn_11_tb;
reg enable_00,enable_01,enable_10,enable_11;
wire full_00,almost_full_00,full_01,almost_full_01,full_10,almost_full_10,full_11,almost_full_11;


				
noc #(16,32,5)noc1 (.clk(clk),.reset(reset),.write0(write_00),.write1(write_01),.write2(write_10),.write3(write_11),
				.dataIn0(dataIn_00_tb),.dataIn1(dataIn_01_tb),.dataIn2(dataIn_10_tb),.dataIn3(dataIn_11_tb),
				.dataOut0(dataOut_00_tb),.dataOut1(dataOut_01_tb),.dataOut2(dataOut_10_tb),.dataOut3(dataOut_11_tb),
				.full0(full_00),.full1(full_01),.full2(full_10),.full3(full_11),
				.almost_full0(almost_full_00),.almost_full1(almost_full_01),.almost_full2(almost_full_10),.almost_full3(almost_full_11));



			
cpu #(0) CPU0 (.clk(clk),.reset(reset),.full(full_00),.almost_full(almost_full_00),.enable(enable_00),.dataOut(dataIn_00_tb),.write(write_00));
cpu #(1) CPU1 (.clk(clk),.reset(reset),.full(full_01),.almost_full(almost_full_01),.enable(enable_01),.dataOut(dataIn_01_tb),.write(write_01));
cpu #(2) CPU2 (.clk(clk),.reset(reset),.full(full_10),.almost_full(almost_full_10),.enable(enable_10),.dataOut(dataIn_10_tb),.write(write_10));
cpu #(3) CPU3 (.clk(clk),.reset(reset),.full(full_11),.almost_full(almost_full_11),.enable(enable_11),.dataOut(dataIn_11_tb),.write(write_11));

always 
	#(clk_prd/2) clk <= ~clk;

always begin
	#clk_prd enable_00 <= 1; enable_01 <= 0; enable_10 <= 0; enable_11 <= 0;
	#clk_prd enable_00 <= 0; enable_01 <= 1; enable_10 <= 0; enable_11 <= 0;
	#clk_prd enable_00 <= 0; enable_01 <= 0; enable_10 <= 1; enable_11 <= 0;
	#clk_prd enable_00 <= 0; enable_01 <= 0; enable_10 <= 0; enable_11 <= 1;
end
	


initial begin
	//enable_00 <= 1; enable_01 <= 0; enable_10 <= 0; enable_11 <= 0;
	clk <= 1'b1;
	reset <= 1'b0;	
	#3 reset <= 1'b1; 
	#6 reset <= 1'b0;
	
	//$monitor("CPU0 received %d, CPU1 received %d, CPU2 received %d, CPU3 received %d",dataOut_00_tb,dataOut_01_tb,dataOut_10_tb,dataOut_11_tb);

end

endmodule
				
				

module cpu #(parameter ID)(input clk, input reset, input full, input almost_full,input enable, output reg [15:0] dataOut, output reg write);

reg [10:0] count;
reg [3:0] dest;
reg [1:0] myID = ID;


always @ (posedge clk, posedge reset) begin
	if (reset) begin
		dataOut <=0;
		write <=0;
		count <=0;
		//dest <= myID+1 ;
		dest=4'b0001;
	end
	else begin
		if(enable) begin
			if ((write & almost_full)|(~write & full)) 
				write <=1'b0;
			else begin

				write <= 1'b1;
				dataOut <= {count,myID,dest,1'b1}; 
				count <= count + 1;
				dest=4'b0001;
				// if (dest == myID-1) dest <= myID + 1;
				// else dest <= dest + 1;
			end
		end
		else
			write <= 1'b0;
	end
end

endmodule	






