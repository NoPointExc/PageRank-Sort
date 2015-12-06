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


