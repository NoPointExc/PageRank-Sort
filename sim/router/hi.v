module hi;
localparam i=4'b0010;

initial begin

integer i;
	for(i=0;i<4;i=i+1)begin
		$display(LOCAL_IP[i]);
	end
end


endmodule;
