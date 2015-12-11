
module sortvals
# (parameter DATA_WIDTH = 32, NUM_WORDS = 32)
( input [DATA_WIDTH*NUM_WORDS-1:0] array_in, input clk,input rst,
output  [DATA_WIDTH*NUM_WORDS-1:0] array_out, output  done );

//$display("-------------------------------");

integer j,k,l;

reg [DATA_WIDTH-1:0] array [NUM_WORDS-1:0];

always@(*) begin
	//Conversion from flat array to 2-D array. Just wiring.
	l=0;
	for (j=0; j<NUM_WORDS; j=j+1) begin
		for (k=0; k<DATA_WIDTH; k=k+1) begin
		      	array[j][k]=array_in[l];
		     	l=l+1;
		end
	end
end

reg [8:0] p=0, tail=NUM_WORDS-1, max=0;
reg sorted=0;
assign done = sorted;


always @(posedge clk or posedge rst) begin
	
// $display("-------------------------------");
// $display($time,"array%p",array);
// $display($time,"sorted=%d",sorted);
// $display($time,"max%d",max);
// $display($time,"p%d, tail=%d",p,tail);

	if (rst) begin
	//rst
	 p<=0;
	 tail<=NUM_WORDS-1;
	 max<=0;
	 sorted<=0;
	end

	else  if(!sorted) begin
		 if(p<=tail)begin
		 	if(array[p]>array[max]) begin
		 		max<=p;
		 	end
		 	p<=p+1;
		 end
		 else begin
		 	//p>tail
		 	//swap
		 	array[max]<=array[tail];
		 	array[tail]<=array[max];
		 	p<=0;max<=0;
		 	if(tail>0) tail<=tail-1;
		 	else begin
		 		sorted<=1;
		 	end
		 end
	end
	
end




//out 
generate
	genvar i;
	for(i=0;i<NUM_WORDS;i=i+1) assign array_out[i*DATA_WIDTH+:DATA_WIDTH] = array[i];
endgenerate


endmodule

