/*
TODO : combin logic --> sequential logic
 */

//Read more details on the pagerank algorithm here.
//http://www.math.cornell.edu/~mec/Winter2009/RalucaRemus/Lecture3/lecture3.html
//The data in this example are based on the example in the link above.

module  pageRank16 #(parameter N=16,M=64,WIDTH=16)
(
input clk,
input reset,
input [N*N-1:0] adjacency,
input [N*WIDTH-1:0] weights,
input [N*4-1:0] relatives,
output reg [WIDTH-1:0] node0Val
);


//We will use a 16 bit fixed point representation throughout.
//All values are in the range [0,(2^16-1)/2^16]. 
// For example, the 16 bit value 2'h11 corresponds to (2^16-1)/2^16.

localparam base=17'h10000;
localparam d = 16'h2666;   //d = 0.15, 9830  0.15=15/100=3/20
localparam dn = d/N; // d/N : NOTE --- please update based on N
localparam db = base-d; //1-d: NOTE: --- please update based on d 
localparam n_1=base/N;  // 1/n

reg [WIDTH-1:0] nodeVal [N-1:0]; //value of each node
//reg [WIDTH-1:0] nodeVal_next [N-1:0]; //next state node value
reg [WIDTH-1:0] nodeWeight_db [N-1:0]; //weight of each node
reg [M-1:0] adj [N-1:0]; //adjacency matrix
reg [N-1:0] rel [3:0];


reg [N-1:0] i,j,k,p,q,r,u,w;
reg [N-1:0] count;

reg [3*WIDTH-1:0] temp; //16bit*16bit*16bit



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


reg [5:0] updated_num[N-1:0]; //out section update needed
//count updated_num
always @(*)begin
	//updated_num=0;
	for (u=0; u<N; u=u+1) begin
	updated_num[u]=5'b0;
		for (w=N; w<M; w=w+1) begin
			if(adj[u][w] == 1) updated_num[u]=updated_num+1;	
		end
	end
end

//Convert nodeWeights from 1D to 2D array
always @ (*) begin
	for (r=0; r<N; r=r+1) begin
		nodeWeight_db[r] = db*weights[r*WIDTH+:WIDTH];
	end
end

integer x;
//Covert rel_adj from 1D to 2D array
always @(*)begin
	for(x=0;x<4;x=x+1)begin
		rel[x]=relatives[x*N+:N];
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


//generate the page number need to update
reg [5:0] page;
reg [5:0] updated_ct[N-1:0];
reg [10:0] updated_page;
//update one page @ every clk
always @(posedge clk or posedge reset) begin	
	if (reset) 
		page=N-1;
		updated_page=0;		
	else begin
		if(page==N&&updated_page==N)begin 
 			//both insection update and out-section update completed
			page=0;
			updated_page;
		end
		else begin
			page=page+1;
		end 
	end

end

reg [WIDTH-1:0] a0,b0,a1,b1;
wire [3*WIDTH-1:0] c0,c1;



//generate nodeVal_next based on old value
//update two value each time
always@(page,reset)begin
	if(reset)begin
		for (i=0; i<N; i=i+1) begin
		nodeVal[i] = n_1; // reset to (1/N) = 0.25. Note --- Please update based on N.
		end
	end
	else begin
		nodeVal[page]=dn;
		for (k=0; k<N; k=k+1) begin
			if(adj[page][k]==1'b1 && k!=page) begin  //can't update yourself with yourself
				temp =  nodeWeight_db[k] * nodeVal[k];
				nodeVal[page] = nodeVal[page] + temp[3*WIDTH-1:2*WIDTH];

			end
		end
	end
end

integer s;
reg [3:0]rel_to;
reg [WIDTH-1:0] rel_val;


//reg [3*WIDTH-1:0] tmp;
always@(*)begin
for(s=0;s<N;s=s+1)begin
	if(adj[s][rel_to])begin
		//rel_val =nodeWeight_db[rel_to]*nodeVal[rel_to];
		nodeVal[s]=nodeVal[s]+rel_val;
		updated_ct=updated_ct+1;
	end
end


endmodule

