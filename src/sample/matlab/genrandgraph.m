N = 64;
p= 0.1;
K= 2;

A = full(smallw(N,K,p));

A(find(A>1)) = 1;

save adjmat
