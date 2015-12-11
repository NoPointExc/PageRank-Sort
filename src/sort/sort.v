module  sortvals
# (parameter DATA_WIDTH = 32, 
             NUM_WORDS = 32)
( input [DATA_WIDTH*NUM_WORDS-1:0] array_in_flattened , 
  input  clk,
  input reset,
  output reg [DATA_WIDTH*NUM_WORDS-1:0] array_out_flattened, output reg done );


reg [DATA_WIDTH-1:0] array_in [NUM_WORDS-1:0];
reg [DATA_WIDTH-1:0] array_out [NUM_WORDS-1:0];
integer j,k,l;
always@(posedge clk)
begin
	if (reset) begin
	l=0;
	for (j=0; j<NUM_WORDS; j=j+1)
	begin
		for (k=0; k<DATA_WIDTH; k=k+1)
		begin
			array_in[j][k]=array_in_flattened[l];
			//array_out_flattened[l]=array_out[j][k];
			l=l+1;
		end
	end
	end
end

always@(*)
begin
	l=0;
	for (j=0; j<NUM_WORDS; j=j+1)
	begin
		for (k=0; k<DATA_WIDTH; k=k+1)
		begin
			array_out_flattened[l]=array_out[j][k];
			l=l+1;
		end
	end
end

reg [DATA_WIDTH-1:0] local_max;
reg [NUM_WORDS-1:0] local_ind;
reg [NUM_WORDS-1:0] step;
reg [NUM_WORDS-1:0] phase;
reg [NUM_WORDS-1:0] selected ;
reg [NUM_WORDS-1:0] i;

// N clock steps
always @ (posedge clk, posedge reset) begin

	if (reset) begin
		local_max <=0 ;
		step <= 0;
		phase <= 0;
		done <= 0;
		local_ind <=0;
		for (i=0; i<NUM_WORDS; i=i+1)
			selected[i] <= 0;
	end
        else  begin
		if (phase < NUM_WORDS) begin
			if (step <  NUM_WORDS) begin
				step <= step + 1;
				if ((array_in[step] >= local_max) && (~selected[step])) begin
					local_max <= array_in[step];	
					local_ind <= step;			
				end	
			end
			else begin
				step <= 0;
				phase <= phase + 1;
				array_out[phase] <= local_max;		
				local_max <= 0;		
				selected[local_ind] <= 1;
			end
		
		end
		else begin
			done <= 1;
		end
		
	end	
end

endmodule 



		



 

