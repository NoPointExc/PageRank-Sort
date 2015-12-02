//Read more details on the pagerank algorithm here.
//http://www.math.cornell.edu/~mec/Winter2009/RalucaRemus/Lecture3/lecture3.html
//The data in this example are based on the example in the link above.

module pageRank #(parameter N=4, WIDTH=16)
(
input clk,
input reset,
input [N*N-1:0] adjacency,
input [N*WIDTH-1:0] weights,
output reg [WIDTH-1:0] node0Val);


//We will use a 16 bit fixed point representation throughout.
//All values are in the range [0,(2^16-1)/2^16]. 
// For example, the 16 bit value 2'h11 corresponds to (2^16-1)/2^16.

localparam d = 16'h2666;   //d = 0.15
localparam dn = 16'h099a; // d/N : NOTE --- please update based on N
localparam db = 16'hd99a; //1-d: NOTE: --- please update based on d 

reg [WIDTH-1:0] nodeVal [N-1:0]; //value of each node
reg [WIDTH-1:0] nodeVal_next [N-1:0]; //next state node value
reg [WIDTH-1:0] nodeWeight [N-1:0]; //weight of each node
reg adj [N-1:0] [N-1:0]; //adjacency matrix



reg [N-1:0] i,j,k,p,q,r;
reg [N-1:0] count;

reg [3*WIDTH-1:0] temp; //16bit*16bit*16bit

//Convert adj from 1D to 2D array
always @ (*) begin
	count = 0;
	for (p=0; p<N; p=p+1) begin
		for (q=0; q<N; q=q+1) begin
			adj[p][q] = adjacency[count];
			count = count+1;
		end
	end
end

//Convert nodeWeights from 1D to 2D array
always @ (*) begin
	for (r=0; r<N; r=r+1) begin
		nodeWeight[r] = weights[r*WIDTH+:WIDTH];
	end
end


//reg [WIDTH-1:0] node0Val;
reg [WIDTH-1:0] node1Val;
reg [WIDTH-1:0] node2Val;
reg [WIDTH-1:0] node3Val;

always @ (*) begin
	node0Val = nodeVal[0];
	node1Val = nodeVal[1];
	node2Val = nodeVal[2];
	node3Val = nodeVal[3];
end




//Combinational logic
always @ (*) begin
	//For each node
	for (j=0; j<N; j=j+1) begin
		//initialize next state node val
		nodeVal_next[j] = dn;
		//Go through adjacency matrix to find node's neighbours
		for (k=0; k<N; k=k+1) begin
			if(adj[j][k]==1'b1) begin
				//Add db*nodeval[k]*nodeWeight[k]
				temp = db * nodeWeight[k] * nodeVal[k];
				nodeVal_next[j] = nodeVal_next[j] + temp[47:32]; 
			end
		end
	end
end

//Next state = current state
always @ (posedge clk, posedge reset) begin
  if (reset) begin
	for (i=0; i<N; i=i+1) begin
		nodeVal[i] <= 16'h4000; // reset to (1/N) = 0.25. Note --- Please update based on N.
	end
   end
   else begin
	for (i=0; i<N;i=i+1) begin	
		nodeVal[i] <= nodeVal_next[i]; 
	end
   end

end	

endmodule

