12/02/2015  12:07 PM
-------------------
1)router depth can change on demand to reduce area
2)when N=16, V1 time=600.
3)router time=800
4) talk with zhiyuan qing, in weekend
   talk with Mr.fox. in 12/02 afternoon
   talk with minda fang, in ?

5）noc time=800. or smaller

12/03/2015  03:47 PM
--------------------
1)fixed bug, noc_router ip

noc doesn't work. noly one output.

noc_router  #(WIDTH,DEPTH,2'b00) router0 (clk,reset,
	writeE[0],writeW[0],writeL[0],//write ports
	read_FullE[0],read_FullW[0],read_FullL[0],//destination port is full
	read_almostFullE[0],read_almostFullW[0],read_almostFullL[0],//destination port is almost full
	dataInE[0],dataInW[0],datainL[0],//write data ports

	dataOutE[0],dataOutW[0],dataOutL[0],//output ports
	writeOutE[0],writeOutW[0],writeOutL[0],//connect to write port of destination
	fullE[0],fullW[0],fullL[0],
	almost_fullE[0],almost_fullW[0],almost_fullL[0]//full outputs from FIFOs
	);

noc_router  #(WIDTH,DEPTH,2'b01) router1 (clk,reset,
	writeE[1],writeW[1],writeL[1],//write ports
	read_FullE[1],read_FullW[1],read_FullL[1],//destination port is full
	read_almostFullE[1],read_almostFullW[1],read_almostFullL[1],//destination port is almost full
	dataInE[1],dataInW[1],datainL[1],//write data ports

	dataOutE[1],dataOutW[1],dataOutL[1],//output ports
	writeOutE[1],writeOutW[1],writeOutL[1],//connect to write port of destination
	fullE[1],fullW[1],fullL[1],
	almost_fullE[1],almost_fullW[1],almost_fullL[1]//full outputs from FIFOs
	);

noc_router  #(WIDTH,DEPTH,2'b10) router2 (clk,reset,
	writeE[2],writeW[2],writeL[2],//write ports
	read_FullE[2],read_FullW[2],read_FullL[2],//destination port is full
	read_almostFullE[2],read_almostFullW[2],read_almostFullL[2],//destination port is almost full
	dataInE[2],dataInW[2],datainL[2],//write data ports

	dataOutE[2],dataOutW[2],dataOutL[2],//output ports
	writeOutE[2],writeOutW[2],writeOutL[2],//connect to write port of destination
	fullE[2],fullW[2],fullL[2],
	almost_fullE[2],almost_fullW[2],almost_fullL[2]//full outputs from FIFOs
	);

noc_router  #(WIDTH,DEPTH,2'b11) router3 (clk,reset,
	writeE[3],writeW[3],writeL[3],//write ports
	read_FullE[3],read_FullW[3],read_FullL[3],//destination port is full
	read_almostFullE[3],read_almostFullW[3],read_almostFullL[3],//destination port is almost full
	dataInE[3],dataInW[3],datainL[3],//write data ports

	dataOutE[3],dataOutW[3],dataOutL[3],//output ports
	writeOutE[3],writeOutW[3],writeOutL[3],//connect to write port of destination
	fullE[3],fullW[3],fullL[3],
	almost_fullE[3],almost_fullW[3],almost_fullL[3]//full outputs from FIFOs
	);
