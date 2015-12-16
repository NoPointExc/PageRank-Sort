/*
TODO : 

--1) ajdust the ports to connect the new NOC
--2) updata from incomming response
--3) response for query 
--4)chekc index overflow
--5)send out request

--6)add output of nodeVal
7)add iteration times
 */

//Read more details on the pagerank algorithm here.
//http://www.math.cornell.edu/~mec/Winter2009/RalucaRemus/Lecture3/lecture3.html
//The data in this example are based on the example in the link above.

module  ant #(parameter N=16, M=64, WIDTH=16)
(
input clk,
input reset,
input [N*M-1:0] adjacency,
input [N*WIDTH-1:0] weights,
input [1:0] id,
input [5:0] query,
input [WIDTH+5:0] response,  //{data,page_id},get response from noc

output reg [5:0] request,    //send request to noc
output reg [WIDTH-1:0] reply,  //send reply to noc
output reg [WIDTH-1:0] node0Val, //only for test
output wire [WIDTH*N-1:0] vals
);

//We will use a 16 bit fixed point representation throughout.
//All values are in the range [0,(2^16-1)/2^16]. 
// For example, the 16 bit value 2'h11 corresponds to (2^16-1)/2^16.

localparam base=17'h10000;  //2^17
localparam d = 16'h2666;   //d = 0.15, 9830  0.15=15/100=3/20
localparam dn = d/N; // d/N : NOTE --- please update based on N
localparam db = base-d; //1-d: NOTE: --- please update based on d 
localparam n_1=base/N;  // 1/n


reg [WIDTH-1:0] nodeVal_next [N-1:0]; //next state node value
reg [WIDTH-1:0] nodeVal [N-1:0]; //value of each node
reg [WIDTH-1:0] nodeWeight [N-1:0]; //weight of each node
reg [M-1:0] adj [N-1:0]; //adjacency matrix



reg [N-1:0] i,j,k,p,q,r,x,s,z;
reg [N-1:0] count;

reg [3*WIDTH-1:0] temp; //16bit*16bit*16bit


//output all the page vals 
generate
	genvar y;
	for(y=0;y<N;y=y+1) assign vals[y*WIDTH+:WIDTH] = nodeVal[y] ;
endgenerate





//Convert adj from 1D to 2D array
always @ (*) begin
	count = 0;
	for (p=0; p<N; p=p+1) begin
		for (q=0; q<M; q=q+1) begin
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


always @ (*) begin
	node0Val = nodeVal[0];
end

reg [5:0] page;
reg [6:0] ref_page;
reg block;

always @(posedge clk or posedge reset) begin
	if (reset) begin
		ref_page<=0;
		page<=0;
	end
	else if (!block) begin
		if(ref_page==M-1)begin
			ref_page<=0;
			if(page==N-1) page<=0;
			else page=page+1;
		end
		else ref_page=ref_page+1;
	end
end


always @(ref_page, page)begin
	if(adj[page][ref_page])begin
		if(ref_page<(id+1)*N && ref_page>=id*N)begin
			//inner
			
		end
		else begin
			//outer
			block=1'b1;
			request=ref_page;
		end
	end
end



//----------------------------I/O----------------------------
//reply to noc
reg [5:0] index;
reg [3*WIDTH-1:0] buffer2;
always @(query)begin
	index=query-id*N;  //6 bits-id 2 bits* WIDTH 4 bits
	buffer2=db*nodeVal[index]*nodeWeight[index];
	reply=buffer2[3*WIDTH-1:2*WIDTH];
end


reg [5:0] response_page;
reg [WIDTH-1:0] response_val;
//update with incomming response
always @(response) begin

	response_page=response[5:0];
	response_val=response[WIDTH+5:6];
	nodeVal[page] = nodeVal[page] + response_val;
	block=1'b0; //cancel block, process resume
end



endmodule

