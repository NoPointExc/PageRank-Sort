module pageRank #(parameter M=16, WIDTH=16)
(input clk,
input reset,
input [M*M-1:0]adj,
input [M*WIDTH-1:0]nodeWeight,
output reg [10*WIDTH-1:0]top10Vals,
output reg [10*6-1:0] top10IDs);



endmodule
