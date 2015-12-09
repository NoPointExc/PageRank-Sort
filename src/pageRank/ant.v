/*
TODO : 

--1) ajdust the ports to connect the new NOC
--2) updata from incomming response
--3) response for query 
--4)chekc index overflow
--5)send out request
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
output reg [WIDTH-1:0] node0Val //only for test
);
//1101100110011010000000000000000

//We will use a 16 bit fixed point representation throughout.
//All values are in the range [0,(2^16-1)/2^16]. 
// For example, the 16 bit value 2'h11 corresponds to (2^16-1)/2^16.

localparam base=17'h10000;  //2^17
localparam d = 16'h2666;   //d = 0.15, 9830  0.15=15/100=3/20
localparam dn = d/N; // d/N : NOTE --- please update based on N
localparam db = base-d; //1-d: NOTE: --- please update based on d 
localparam n_1=base/N;  // 1/n

reg [WIDTH-1:0] nodeVal [N-1:0]; //value of each node
//reg [WIDTH-1:0] nodeVal_next [N-1:0]; //next state node value
reg [WIDTH-1:0] nodeWeight_db [N-1:0]; //weight of each node
reg [M-1:0] adj [N-1:0]; //adjacency matrix



reg [N-1:0] i,j,k,p,q,r,x,s;
reg [N-1:0] count;

reg [2*WIDTH-1:0] temp; //16bit*16bit



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

reg[2*WIDTH-1:0] buffer;
always @ (*) begin
	for (r=0; r<N; r=r+1) begin
		buffer=db*weights[r*WIDTH+:WIDTH];
		nodeWeight_db[r] = buffer[2*WIDTH-1:WIDTH];
		//$display("nodeWeight_db[%d]=%d",r,nodeWeight_db[r]);
	end
end


always @ (*) begin
	node0Val = nodeVal[0];
end

reg [2*WIDTH-1:0] buffer2;
//reply to noc
reg [5:0] index;
always @(query)begin
	index=query-id*WIDTH;  //6 bits-id 2 bits* WIDTH 4 bits
	buffer2=nodeVal[index]*nodeWeight_db[index];
	reply=buffer2[2*WIDTH-1:WIDTH];
	//$display("%d = %d-%d*%d",index,query,id,WIDTH);
	//$display("buffer2=%b",buffer2);
	//$display("nodeVal[%d]=%d,nodeWeight_db=%d,reply=%b",index,nodeVal[index],nodeWeight_db[index],reply,);
end

reg [5:0] response_page;
reg [WIDTH-1:0] response_val;
//update with incomming response
always @(response) begin
	response_page=response[5:0];
	response_val=response[WIDTH+5:6];
	//scan whole row || and update pages relative to response_page
	for(x=0;x<N;x=x+1)begin
		//page x releative to response_page
		if(adj[x][response_page]==1'b1)begin
			nodeVal[x] = nodeVal[x] + response_val;
		end
	end
end

//send out requests
reg [6:0] request_page; //interation between N ~ M-1
always @(posedge clk or posedge reset) begin
	if (reset) begin
		request_page=M-1;
		//$display("%d=%d-1",request_page,M);		
	end
	else begin
		request_page=response_page+1;	
		if(response_page==M) request_page=0;	
	end
end
 
 always @(request_page)begin
 // $display("request_page=%d",request_page);
 	for(s=0;s<N;s=s+1)begin
 		if(adj[s][request_page]) begin
 			request=request_page;
 			// $display("request=%d",request);
 		end
 	end
 end


//generate the page number need to update
reg [5:0] page;

//update one page @ every clk
always @(posedge clk or posedge reset) begin	
	if (reset) 
		page=N-1;		
	else begin
		page=page+1;
		if(page==N) page=0;
	end

end





//generate nodeVal_next based on old value
always@(page,reset)begin
	if(reset)begin
		for (i=0; i<N; i=i+1) begin
		nodeVal[i] = n_1; // reset to (1/N) = 0.25. Note --- Please update based on N.
		end
	end
	else begin
		nodeVal[page]=dn;
		for (k=0; k<N; k=k+2) begin
			if(adj[page][k]==1'b1 && k!=page) begin  //can't update yourself with yourself
				temp =  nodeWeight_db[k] * nodeVal[k];
				nodeVal[page] = nodeVal[page] + temp[2*WIDTH-1:WIDTH];				
			end
		end
	end
end


endmodule

