/*
TODO : 
1) check page @ time 0
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
input syc_in,

output reg [5:0] request,    //send request to noc
output reg [WIDTH-1:0] reply,  //send reply to noc
output reg [WIDTH-1:0] node0Val, //only for test
output wire [WIDTH*N-1:0] vals,
output reg syc_out
);

//We will use a 16 bit fixed point representation throughout.
//All values are in the range [0,(2^16-1)/2^16]. 
// For example, the 16 bit value 2'h11 corresponds to (2^16-1)/2^16.

localparam base=17'h10000;  //2^17
localparam d = 16'h2666;   //d = 0.15, 9830  0.15=15/100=3/20
localparam dn = d/N; // d/N : NOTE --- please update based on N
localparam db = base-d; //1-d: NOTE: --- please update based on d 
localparam n_1=base/N;  // 1/n

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



//--------------------inner page update-------------

//generate the page number need to update
reg [5:0] page;
reg block;
//update one page @ every clk
always @(posedge clk or posedge reset) begin
	
	if (reset) 
		page=N-1;		
	else if(!block)begin	
		if(page==N ) begin
			if(syc_in) begin
				page=0;
				syc_out=0;
			end 
			else syc_out=1'b1;
		end
		else begin
			page=page+1; 	
		end 
	end
end

// always@(*)begin
// 	if(page==0)begin
// 		$display($time,"id=%d,page=%d,syc_in=%d,syc_out=%d",id,page,syc_in,syc_out);
// 	end
// end


//generate nodeVal_next based on old value
always@(page,reset)begin
	if(reset)begin
		for (i=0; i<N; i=i+1) begin
		nodeVal[i] = n_1; // reset to (1/N) = 0.25. Note --- Please update based on N.
		end
		block=1'b0;
	end
	else begin
		nodeVal[page]=dn;
		//$display($time," id=%d, nodeVal[%d]=%d",id,page,dn);
		for (k=0; k<M; k=k+1) begin
			if(adj[page][k]==1'b1) begin
				
				if((k-id*N)>=0 && (k-id*N)<16)begin  //inner page
					temp = db * nodeWeight[k-id*N] * nodeVal[k-id*N];
					nodeVal[page] = nodeVal[page] + temp[3*WIDTH-1:2*WIDTH];
					//$display($time,"id=%d, local update,nodeVal[%d]=%d, page=%d,(k-id*N)=%d,nodeVal[%d]=%d",id,k,nodeVal[k-id*N],page,(k-id*N),page,nodeVal[page]); 
				end
				else begin  //outside
					request=k;
					block=1'b1;
					//$display($time,"id=%d, request=%d,nodeVal[%d]=%d",id,request,page,nodeVal[page]);
				end			
			end		
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
	//$display($time,"reply=%d,nodeVal[%d]=%d",reply,index,nodeVal[index]);
end


reg [5:0] response_page;
reg [WIDTH-1:0] response_val;
//update with incomming response
always @(response) begin

	response_page=response[5:0];
	response_val=response[WIDTH+5:6];
	nodeVal[page] = nodeVal[page] + response_val;
	block=1'b0; //cancel block, process resume
	//$display($time,"  response[%d]",response_page);
end



endmodule

