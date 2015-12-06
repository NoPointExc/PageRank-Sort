module multiplier #(parameter w=61) (input [w-1:0] a, input [w-1:0] b, input clk, input reset, output [(2*w)-1:0] c);
//we are doing 2**3-1 so m is 3


wire [((w+1)/2)-1:0] a1,a0,b1,b0;        // 2bits
reg [w:0] term1,term3; //4 bits because of multiplication 
reg [(2*w)-1:0] term2; //6 bits,because its multiplication of (a0+a1) and (b0+b1) which are 3 bits 
reg [(2*w)-1:0] term2_temp;//6 bits,because its multiplication of (a0+a1) and (b0+b1) which are 3 bits. From this we will subtarct term1 and term2
reg [(2*w)-1:0] temp_out;// this term has shifted term1 plus term3 

assign {a1,a0}=a;
assign {b1,b0}=b;

//term1 1st clk cycle
always @(posedge clk ,posedge reset) begin
	if (reset) begin
		term1<=0;	
	end
	else begin
		term1<=a1*b1;
	end
end

//term3 1st clk cycle
always @(posedge clk,posedge reset) begin
	if (reset) begin
		term3<=0;	
	end
	else begin
		term3<=a0*b0;
	end
end


//term2_temp 1st clk cycle
always @(posedge clk ,posedge reset) begin
	if (reset) begin
		term2_temp<=0;
	end
	else begin
		term2_temp<=(a0+a1)*(b0+b1);
	end
end

//temp_out 2nd clk cycle
always @(posedge clk,posedge reset) begin
	if (reset) begin
		temp_out<=0;
	end
	else begin
		temp_out<= (term1 << (w+1)) + term3;
	end
end

//term2 2nd clk cycle
always @(posedge clk,posedge reset) begin
	if (reset) begin
		term2<=0;
	end
	else begin
		term2<= (term2_temp - term1 - term3)<<((w+1)/2);
	end
end

assign c= temp_out+ term2;

endmodule