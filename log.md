12/02/2015  12:07 PM
-------------------
1)router depth can change on demand to reduce area
2)when N=16, V1 time=600.
3)router time=800
4) talk with zhiyuan yao, in weekend
   talk with Mr.fox. in 12/02 afternoon
   talk with minda fang, in ?

5）noc time=800. or smaller


12/03/2015  03:47 PM
--------------------
1)fixed bug, noc_router ip

noc doesn't work. freezing/

12/04/2015  01:23 PM
--------------------
1)fixed bug, noc_tb.v

empty alway, cased fezzing

2)noc, wirteOut and Write signals seems no output.
 fixed. Reason: forget to reset the output data.
 fixed by reset output data every time.


12/05/2015  01:23 PM
--------------------

1) pageRank. when N=4,5. Converage, when N>5, overflow

12/06/2015 10:49 AM
1) pageRank is not overflow. The adj proven to be wrong. adj can't be random array. 

get same converaged result as pagerank_sample.v

try to reduce multi to reduce time.
 > multi_module? no, too slow
 >dirty bit, reduce unnecessary multi? no, time incrasing. depend on the largest datapath
> combine db*weight? no much diference.

tested N=8, get 16384, 1228. 


router 4 bit IP
# 1,          0,0001
# 0,          1,0001
# 0,          2,0001
# 0,          3,0001


2) router multicast feature added and passed.
.router can mulitcast message. (copy and forge)
.ticket cosuming routing: when message routing to local, the destination bit will be reset
package formate

|----DATA----|address|valid|
|------------|-4bits-|1 bit|

address formate: 1111, muliticast to 0,1,2,3
address formate: 0011, muliticast to 0,1
reserved address:0000, will be droped.

valid bit: 0=invalid, 1=valid


12/09/2015  06:03 PM
--------------------
noc work, do not change again.

*Request Formate*
range	11-5         4-3                2~1          0
type 	reg_id      Src port          Dest Port      Valid
len 	6 bits       2bit             2 bits     1 bit

*Response Formate*
    23~3                  2~1          0
  23~9|8~3             Dest Port       Valid
  Data|REG_ID   
 
*Ant Response Input*     
  23~9       8~3     
 Data       REG_ID   



12/10/2015  06:03 PM
--------------------

vals converaged, but sort result is wrong
converaged values seems wrong

12/11/2015  12:03 AM
----------------------
vals loses output

12/12/2015  11:59 PM
----------------------
issue 1)vals updatas, but not converage
possible issue: 
1) vals not synchronized >> add syc signal? (X)
synchronized. but still not converage.
possible issue: 
2) change to v1 page update. use next_val, cur_val
3) Width too small

issue 2)change to v1, no more update, block not released


3) can't request 2 or more page in one cycles


converage but wrong vals.


12/12/2015  11:59 PM
----------------------

node_val_next should return to initial value each clk


time= 171, next_val0,878 (接近)收到一个response-->>1313 （错）


response wrong!. when repeat response 


# val=  40265994 id=62
# val=  40265942 id=52
# val=  40265942 id=42
# val=  40265942 id=38
# val=  40265942 id=13
# val=  40265916 id=35
# val=  40265916 id=17
# val=  40265899 id= 0
# val=  40265899 id=60
# val=  40265899 id=34



//page rank of test bench download from nyu.class
#   45735--------------
# val=  40266188 id=10
# val=  40266101 id=34
# val=  40266014 id=55
# val=  40266014 id=48
# val=  40266014 id= 3
# val=  40266014 id=46
# val=  40266014 id=39
# val=  40266014 id=37
# val=  40266014 id=14
# val=  40266014 id= 0

//k=32;p=0.5;n=64;
#                41833--------------
# val= 419802862 id=27
# val= 336960407 id=63
# val= 335340607 id=52
# val= 333561646 id=17
# val= 331711123 id=12
# val= 328794692 id=39
# val= 325600700 id=21
# val= 258089161 id= 5
# val= 257495452 id= 7
# val= 257347198 id= 6

//matlab
27	0.025441948	4.69321E+17
63	0.020470126	3.77607E+17
12	0.020412333	3.76541E+17
52	0.020388486	3.76101E+17
17	0.020215235	3.72905E+17
39	0.01991976	3.67455E+17
21	0.019715103	3.63679E+17
5	0.015532713	2.86528E+17
6	0.015532204	2.86519E+17
46	0.015525654	2.86398E+17
45	0.015521528	2.86322E+17
4	0.015500649	2.85937E+17
7	0.015498943	2.85905E+17
47	0.015494717	2.85827E+17
44	0.015480882	2.85572E+17
33	0.015468844	2.8535E+17
58	0.015458943	2.85167E+17
57	0.01545765	2.85143E+17
34	0.015451609	2.85032E+17
32	0.015430966	2.84651E+17
3	0.015424698	2.84535E+17
8	0.015421193	2.84471E+17
48	0.015417798	2.84408E+17

//k=1;p=0.2;n=64;
#                41833--------------
# val= 419802862 id=27
# val= 336960407 id=63
# val= 335340607 id=52
# val= 333561646 id=17
# val= 331711123 id=12
# val= 328794692 id=39
# val= 325600700 id=21
# val= 258089161 id= 5
# val= 257495452 id= 7
# val= 257347198 id= 6

27	0.025441948	4.69321E+17
63	0.020470126	3.77607E+17
12	0.020412333	3.76541E+17
52	0.020388486	3.76101E+17
17	0.020215235	3.72905E+17
39	0.01991976	3.67455E+17
21	0.019715103	3.63679E+17
5	0.015532713	2.86528E+17
6	0.015532204	2.86519E+17
46	0.015525654	2.86398E+17
45	0.015521528	2.86322E+17
4	0.015500649	2.85937E+17
7	0.015498943	2.85905E+17
47	0.015494717	2.85827E+17
44	0.015480882	2.85572E+17
33	0.015468844	2.8535E+17
58	0.015458943	2.85167E+17
57	0.01545765	2.85143E+17

