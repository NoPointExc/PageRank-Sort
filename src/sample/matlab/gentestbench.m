%Input: an adjaceny matrix, adj
load adjmat;

adj = A;


WIDTH = 16; %PLEASE CHANGE THE WIDTH AS PER YOUR REQUIREMENTD

N  = size(adj,1);
W = 1./sum(adj);

fileID = fopen('pagerank_tb.v','w');

fprintf(fileID,'module pagerank_tb;\n\n');

fprintf(fileID,'localparam N=%d;\n', N);
fprintf(fileID,'localparam WIDTH=%d; //PLEASE UPDATE AS REQUIRED\n\n', WIDTH);

fprintf(fileID,'reg clk; \nreg reset; \nalways begin \n  #1 clk  = 1; \n  #1 clk = 0; \nend \n\n');

fprintf(fileID,'reg [N*N-1:0] adj; \nreg [N*WIDTH-1:0] nodeWeight; \n\n');

fprintf(fileID,'wire [10*WIDTH-1:0] top10Vals; \nwire [10*6-1:0] top10IDs; //N = 64, so at most 6 bits required\n\n');

fprintf(fileID,'pageRank #(N,WIDTH) pr(clk,reset,adj,nodeWeight,top10Vals,top10IDs);//PLEASE UPDATE AS PER YOUR MODULE DEFN\n\n');

fprintf(fileID,'initial begin \n  reset = 0; \n  #1 reset = 1; \n\n');

for i=1:1:N
    for j=1:1:N
        fprintf(fileID, '  adj[%d] = %d; \n', (i-1)*N + j-1, adj(i,j));
    end
end

for i=1:1:N
    i
    if(W(i)<1)
        hexval = (round(W(i)*2^WIDTH))
    else
        hexval = ((2^WIDTH) - 1)
    end 
    fprintf(fileID, '  nodeWeight[%d*WIDTH-1:%d*WIDTH] =  %d''h%x; \n', i, i-1, WIDTH, hexval);
end

fprintf(fileID,'  #2 reset = 0;\n end \n endmodule \n');

fclose(fileID);