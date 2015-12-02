module noc
# (parameter  WIDTH=16,DEPTH=32, ADDWIDTH=5)
(input clk, input reset, 
 input write0, 
 input write1, 
 input write2,
 input write3, //write ports
 input [WIDTH-1:0] dataIn0, 
 input [WIDTH-1:0] dataIn1, 
 input [WIDTH-1:0] dataIn2,
 input [WIDTH-1:0] dataIn3, //write data ports
 output  [WIDTH-1:0] dataOut0,
 output  [WIDTH-1:0] dataOut1,
 output  [WIDTH-1:0] dataOut2, 
 output  [WIDTH-1:0] dataOut3, //output ports
 output   full0, 
 output   almost_full0, 
 output   full1, 
 output   almost_full1, 
 output   full2, 
 output   almost_full2,
 output   full3, 
 output   almost_full3 //full outputs from FIFOs
 );
//input

wire writeE0, writeW0, writeL0;
wire writeE1, writeW1, writeL1;
wire writeE2, writeW2, writeL2;
wire writeE3, writeW3, writeL3;

wire [WIDTH-1:0] dataInE0, dataInW0, dataInL0;
wire [WIDTH-1:0] dataInE1, dataInW1, dataInL1;
wire [WIDTH-1:0] dataInE2, dataInW2, dataInL2;
wire [WIDTH-1:0] dataInE3, dataInW3, dataInL3;

wire readFullE0,readFullW0,readFullL0;
wire readFullE1,readFullW1,readFullL1;
wire readFullE2,readFullW2,readFullL2;
wire readFullE3,readFullW3,readFullL3;

wire read_almostfullE0,read_almostfullW0,read_almostfullL0;
wire read_almostfullE1,read_almostfullW1,read_almostfullL1;
wire read_almostfullE2,read_almostfullW2,read_almostfullL2;
wire read_almostfullE3,read_almostfullW3,read_almostfullL3;

//output
wire writeOutE0, writeOutW0, writeOutL0;
wire writeOutE1, writeOutW1, writeOutL1;
wire writeOutE2, writeOutW2, writeOutL2;
wire writeOutE3, writeOutW3, writeOutL3;

wire [WIDTH-1:0] dataOutE0, dataOutW0, dataOutL0;
wire [WIDTH-1:0] dataOutE1, dataOutW1, dataOutL1;
wire [WIDTH-1:0] dataOutE2, dataOutW2, dataOutL2;
wire [WIDTH-1:0] dataOutE3, dataOutW3, dataOutL3;

wire fullE0, fullW0, fullL0;
wire fullE1, fullW1, fullL1;
wire fullE2, fullW2, fullL2;
wire fullE3, fullW3, fullL3;

wire almost_fullE0, almost_fullW0, almost_fullL0;
wire almost_fullE1, almost_fullW1, almost_fullL1;
wire almost_fullE2, almost_fullW2, almost_fullL2;
wire almost_fullE3, almost_fullW3, almost_fullL3;

always @(*) begin
     //$display($time,": writeL0=%d",writeL0);
     //$display($time,": writeE0=%d,writeW0=%d,writeL0=%d ",writeE0,writeW0,writeL0);
     //$display($time,": dataIn0=%b,dataIn1=%d,dataIn2=%d,dataIn3=%d",dataIn0,dataIn1,dataIn2,dataIn3);
     //$display($time,": dataInE0=%b,dataInW0=%d,dataInL0=%d",dataInE0,dataInW0,dataInL0);
     //$display($time,": dataOutE1=%d,dataOutW1=%d,dataOutL1=%d",dataOutE1,dataOutW1,dataOutL1);
     //$display($time,": dataInW0=%d,dataInW1=%d,dataInW2=%d,dataInW3=%d",dataInW0,dataInW1,dataInW2,dataInW3);
     //$display($time,": writeW2=%d", writeW2);
     $display($time," writeOutE0=%d, writeOutW0=%d, writeOutL0=%d", writeOutE0, writeOutW0, writeOutL0);
     $display($time," writeE1=%d, writeW1=%d, writeL1=%d", writeE1, writeW1, writeL1);
end


noc_router #(WIDTH,DEPTH,2'b00) router0 (clk, reset,  
          writeE0, writeW0, writeL0, //write ports
          readFullE0,readFullW0,readFullL0,  //destination port is full
          read_almostfullE0,read_almostfullW0,read_almostfullL0, //destination port is almost full
          dataInE0, dataInW0, dataInL0, //write data ports

          dataOutE0, dataOutW0, dataOutL0, //output ports
           writeOutE0, writeOutW0, writeOutL0,  //connect to write port of destination
          fullE0, almost_fullE0, fullW0, almost_fullW0, fullL0, almost_fullL0 //full outputs from FIFOs
);

noc_router #(WIDTH,DEPTH,2'b01) router1 (clk, reset,  
          writeE1, writeW1, writeL1, //write ports
          readFullE1,readFullW1,readFullL1, //
          read_almostfullE1,read_almostfullW1,read_almostfullL1,
          dataInE1, dataInW1, dataInL1, //write data ports

          dataOutE1, dataOutW1, dataOutL1, //output ports
          writeOutE1, writeOutW1, writeOutL1,
          fullE1, almost_fullE1, fullW1, almost_fullW1, fullL1, almost_fullL1 //full outputs from FIFOs
);

noc_router #(WIDTH,DEPTH,2'b10) router2 (clk, reset,  
          writeE2, writeW2, writeL2, //write ports
          readFullE2,readFullW2,readFullL2,
          read_almostfullE2,read_almostfullW2,read_almostfullL2,
          dataInE2, dataInW2, dataInL2, //write data ports

          dataOutE2, dataOutW2, dataOutL2, //output ports
          writeOutE2, writeOutW2, writeOutL2,
          fullE2, almost_fullE2, fullW2, almost_fullW2, fullL2, almost_fullL2 //full outputs from FIFOs
);

noc_router #(WIDTH,DEPTH,2'b11) router3 (clk, reset,  
          writeE3, writeW3, writeL3, //write ports
          readFullE3,readFullW3,readFullL3, //destination port is full
          read_almostfullE3,read_almostfullW3,read_almostfullL3, //destination port is almost full
          dataInE3, dataInW3, dataInL3, //write data ports

          dataOutE3, dataOutW3, dataOutL3, //output ports
           writeOutE3, writeOutW3, writeOutL3,
          fullE3, almost_fullE3, fullW3, almost_fullW3, fullL3, almost_fullL3  //full outputs from FIFOs
);



//=========noc0-local0=========
assign writeL0=write0;
assign dataInL0=dataIn0;
assign dataOut0=dataOutL0;
assign full0= fullL0;
assign almost_full0 =almost_fullL0;
//=========noc1-local1=========
assign writeL1=write1;
assign dataInL1=dataIn1;
assign dataOut1=dataOutL1;
assign full1= fullL1;
assign almost_full1 =almost_fullL1;
//=========noc2-local2=========
assign writeL2=write2;
assign dataInL2=dataIn2;
assign dataOut2=dataOutL2;
assign full2= fullL2;
assign almost_full2 =almost_fullL2;
//=========noc3-local3=========
assign writeL3=write3;
assign dataInL3=dataIn3;
assign dataOut3=dataOutL3;
assign full3= fullL3;
assign almost_full3 =almost_fullL3;

//connectation of noc0 ,noc 1, noc 2, noc3
//      local0  local1  local2   local3
//        |       |        |       |
//xxxx--noc0-----noc1----noc2-----noc3----xxxx
//=====================================
//          L
//          |
//W-------------------E

//=========noc0-noc1=========
//-----noc0->-write--to->noc1
//dataOutE0(out)              |--->---| dataInW1
//writeOutE0(out)             |--->---| writeW1
//readFullE0(in)              |---<---| fullW1
//read_almostfullE0(in)       |---<---| almost_fullW1
assign dataInW1 = dataOutE0;
assign writeW1 =writeOutE0 ;
assign readFullE0= fullW1;
assign read_almostfullE0=almost_fullW1;
//-----noc1->-write--to->noc0
//dataOutW1(out)              |--->---| dataInE0
//writeOutW1(out)             |--->---| writeE0
//readFullW1(in)              |---<---| fullE0
//read_almostfullW1(in)       |---<---| almost_fullE0
assign  dataInE0=dataOutW1 ;
assign  writeE0= writeOutW1;
assign readFullW1= fullE0;
assign  read_almostfullW1=almost_fullE0 ;



//=========noc1-noc2=========
//-----noc1->-write--to->noc2
//dataOutE1(out)              |--->---| dataInW2
//writeOutE1(out)             |--->---| writeW2
//readFullE1(in)              |---<---| fullW2
//read_almostfullE1(in)       |---<---| almost_fullW2
assign dataInW2 = dataOutE1;
assign writeW2 =writeOutE1 ;
assign readFullE1= fullW2;
assign read_almostfullE1=almost_fullW2;
//-----noc2->-write--to->noc1
//dataOutW2(out)              |--->---| dataInE1
//writeOutW2(out)             |--->---| writeE1
//readFullW2(in)              |---<---| fullE1
//read_almostfullW2(in)       |---<---| almost_fullE1
assign  dataInE1=dataOutW2 ;
assign  writeE1= writeOutW2;
assign readFullW2= fullE1;
assign  read_almostfullW2=almost_fullE1 ;


//=========noc2-noc3=========
//-----noc2->-write--to->noc3
//dataOutE2(out)              |--->---| dataInW2
//writeOutE2(out)             |--->---| writeW2
//readFullE2(in)              |---<---| fullW2
//read_almostfullE2(in)       |---<---| almost_fullW2
assign dataInW3 = dataOutE2;
assign writeW3 =writeOutE2 ;
assign readFullE2= fullW3;
assign read_almostfullE2=almost_fullW3;

//-----noc3->-write--to->noc2
//dataOutW3(out)              |--->---| dataInE2
//writeOutW3(out)             |--->---| writeE2
//readFullW3(in)              |---<---| fullE2
//read_almostfullW3(in)       |---<---| almost_fullE2
assign  dataInE2=dataOutW3 ;
assign  writeE2= writeOutW3;
assign readFullW3= fullE2;
assign  read_almostfullW3=almost_fullE2 ;


endmodule