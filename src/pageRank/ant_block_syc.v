
module  ant #(parameter N=16, M=64, WIDTH=32)
(
input clk,
input reset,
input [N*M-1:0] adjacency,
input [N*WIDTH-1:0] weights,
input [1:0] id,
input [5:0] query,
input [WIDTH+6:0] response,  //{data,page_id,valid},get response from noc
input syc_in,

output reg [6:0] request,    //send request to noc
output reg [WIDTH-1:0] reply,  //send reply to noc
//output reg [WIDTH-1:0] node0Val, //only for test
output wire [WIDTH*N-1:0] vals,
output reg syc_out
);

//WIDTH=16;
// localparam base=17'h10000;  //2^16
// localparam d = 16'h2666;   //d = 0.15, 
// localparam dn = d/M; // d/M : NOTE --- please update based on N
// localparam db = base-d; //1-d: NOTE: --- please update based on d99A, 55706 
// localparam n_1=base/M;  // 1/M

//WIDTH=32;
localparam base=33'hFFFFFFFF;  //2^32=4294967296
localparam d = 32'h26666666;   //d = 0.015, 644245094 
localparam dn = 32'h2666666; // d/N 40265318
localparam db = 32'hD9999999; //1-d: 3650722202
localparam n_1=base/M;  // 1/M  268435456

reg [WIDTH-1:0] nodeVal_next [N-1:0]; //next state node value
reg [WIDTH-1:0] nodeVal [N-1:0]; //value of each node
reg [WIDTH-1:0] nodeWeight [N-1:0]; //weight of each node
reg [M-1:0] adj [N-1:0]; //adjacency matrix



reg [N-1:0] i,j,p,q,r,x,s,z;
reg [N-1:0] count;

reg [3*WIDTH-1:0] temp; //16bit*16bit*16bit

//---------------------input/output combine--------------
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
		//$display("%b",adj[p]);
	end
end



//Convert nodeWeights from 1D to 2D array
always @ (*) begin
	for (r=0; r<N; r=r+1) begin
		nodeWeight[r] = weights[r*WIDTH+:WIDTH];
	end
end




//-------------page update---------------

//generate the page number need to update
reg [6:0] page;
reg [6:0] ref_page;
reg block;

//no syc_in
always @(posedge clk or posedge reset) begin
	if (reset) begin
		page=N-1;
		ref_page=M-1;
		block=1'b0;
		for (i=0; i<N; i=i+1) begin
			nodeVal[i]=n_1; 
		end
		
	end
	else if (!block) begin
		if(ref_page==M-1)begin
			if(page==N-1)begin
				if(syc_in)begin
					page=0;
					ref_page=0;
					syc_out=1'b0;
				end 	
				else syc_out=1'b1;
			end
			else begin
				page=page+1;
				ref_page=0;
			end
		end 
		else begin
			ref_page=ref_page+1;
		end
	end
end

integer k;
always @(page,ref_page,reset)begin
	if(reset)begin
		for(k=0;k<N;k=k+1)begin
			nodeVal_next[k]=dn;
		end
	end
	if(adj[page][ref_page]==1'b1)begin
		if(ref_page>=(id*N) && ref_page<((id+1)*N))begin   //??
			//inner			
			temp=db*nodeWeight[ref_page-id*N]*nodeVal[ref_page-id*N];
			nodeVal_next[page] = nodeVal_next[page] + temp[3*WIDTH-1:2*WIDTH];
		end
		else begin
			//outer		
			request={ref_page,1'b1};
			block=1'b1;
		end
	end
end

//next state =current state
always @(syc_in)begin
	if(page==N-1 && syc_in)begin
		for (j=0;j<N;j=j+1) begin
			nodeVal[j]<=nodeVal_next[j];
			nodeVal_next[j]<=dn;
		end
	end 
end



//----------------------------I/O----------------------------

reg [10:0] index;
reg [3*WIDTH-1:0] buffer2;

reg[4:0] MAX_WAIT;
reg [5:0] response_page;
reg [WIDTH-1:0] response_val;

always @(query)begin
	index=query-id*N;  //6 bits-id 2 bits* WIDTH 4 bits,db=55706
	buffer2=db*nodeWeight[index]*nodeVal[index];
	reply=buffer2[3*WIDTH-1:2*WIDTH];
end

//update with incomming response
always @(posedge clk) begin
	if(response[0] && block)begin
		request[0]=1'b0;	
		response_page=response[6:1];
		response_val=response[WIDTH+6:7];	
		nodeVal_next[page] = nodeVal_next[page] +response_val;
		block=1'b0;
		MAX_WAIT=25;		
	end
	
end


//in case of lost package (FIFO full/waitting too long)
always @(posedge clk or posedge reset) begin
	if (reset) begin
		MAX_WAIT<=25;		
	end
	else begin
		if(block)begin
			if(MAX_WAIT==0) begin
				block<=1'b0;
				MAX_WAIT<=25;
			end 
			else MAX_WAIT<=MAX_WAIT-1;
		end 
	end
end

endmodule




