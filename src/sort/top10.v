/*
TODO:
1) sort ID
 */
module top10
# (parameter  DATA_WIDTH= 16, NUM_WORDS = 16)
(input clk,input rst, input enable,input [DATA_WIDTH*NUM_WORDS-1:0] array_in,
output  [DATA_WIDTH*10-1:0] array_out, output  [6*10-1:0] id_out);


integer j,k,l,m;

// integer x;
// always @(*)begin
// 	if(enable)begin
// 		$display($time,"--------------");
// 		for(x=0;x<NUM_WORDS ;x=x+1)begin
// 			$display("in%d=%d id=%d",x,array[x],ID[x]);		
// 		end
// 	end
// end



reg [DATA_WIDTH-1:0] array [NUM_WORDS-1:0];

reg [5:0] ID [NUM_WORDS-1:0];

always@(*) begin
	if(enable)begin
	l=0;
		for (j=0; j<NUM_WORDS; j=j+1) begin
			for (k=0; k<DATA_WIDTH; k=k+1) begin
			      	array[j][k]=array_in[l];
			     	l=l+1;
			end
		end		
	end
end



reg [6:0] p, head, max,n;




always @(posedge clk or posedge rst) begin	
	if (rst) begin
		 p<=NUM_WORDS-1;
		 head<=0;
		 max<=NUM_WORDS-1;
		 for(n=0;n<NUM_WORDS;n=n+1)begin
		 	ID[n]<=n;
		 	//$display($time,"ID[n]=%d",ID[n]);
		 end
	end
	else if(enable) begin
		 
		 if(head<10)begin
			 if(p>head)begin
			 	if(array[p]>array[max])begin
			 		max<=p;
			 	end
			 	p<=p-1;
			 end
			 else begin
			 	if(array[head]<array[max])begin
			 		array[head]<=array[max];
					array[max]<=array[head];		
			 	end
			 	p<=NUM_WORDS-1;
			 	head<=head+1;
			 	max<=NUM_WORDS-1;
			 	array[head]<=array[max];
			 	array[max]<=array[head];
			 	ID[head]<=ID[max];
			 	ID[max]<=ID[head];
			 end
		 end

	end
	
end


generate
	genvar i;
	for(i=0;i<10;i=i+1)begin
		assign array_out[i*DATA_WIDTH+:DATA_WIDTH] = array[i];
		assign id_out[i*6+:6]=ID[i];
	end 
endgenerate


endmodule

