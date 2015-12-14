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
1)vals updatas, but not converage
possible issue: 
1) vals not synchronized >> add syc signal? (X)
synchronized. but still not converage.
possible issue: 
2) change to v1 page update. use next_val, cur_val
3) Width too small