clear all

load adjmat
%A = [0 0 1 1; 
%    1 0 0 0; 
%    1 1 0 1; 
%    1 1 0 0];

N = size(A,1);
v(1:N,1) = ones(N,1)/N;

W = ones(N,1) * (1./sum(A)); 

A = A.*W; %%multiply with weights.


numIters = 1000; %%you should tune this for convergence

d = 0.15;

for i=2:1:numIters
    v(1:N,i) = (d/N)*ones(N,1) + ((1-d)*A ) * v(1:N,i-1); %(d*(.25)*ones(4) + (1-d)*A ) *v;     
end

plot(v')