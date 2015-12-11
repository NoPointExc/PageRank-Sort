module top10Test;

localparam DATA_WIDTH = 4, NUM_WORDS = 16;
reg clk,reset;
reg [DATA_WIDTH*NUM_WORDS-1:0] array_in;
wire [DATA_WIDTH*10-1:0] array_out;
wire [6*10-1:0] id_out;


top10 #(DATA_WIDTH,NUM_WORDS) top10(clk,reset,array_in,array_out,id_out);

initial begin
	clk=1;reset=0;
	//$monitor($time,"      %b",array_out);
	#5 reset=1;
	#20 reset=0;array_in=64'h3B041F2C0015; 
	//0011 1011 0000 0100 0001 1111 0010 1100 0000 0000 0001 0101
	//sorted    0001 0000 0001 0010 0011 0100 0101 1011 1100 1111
	#200 reset=1;
	#210 reset=0; array_in=64'h7261030115544778;
	//‭0111 0010 0110 0001 0000 0011 0000 0001 0001 0101 0101 0100 0100 0111 0111 1000‬
	//sorted:                       0100 0100 0101 0001 0101 0110 0111 0111 1000 0111 

	#200 reset=1;
	#210 reset=0; array_in=64'h213213213123213;

	#200 reset=1;
	#10 reset=0; array_in=64'hAB3CA762318B99BC;
end


always
#1 clk=~clk;



endmodule