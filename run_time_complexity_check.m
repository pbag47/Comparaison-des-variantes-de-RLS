clear variables
close all

N = 0:500:15000 ;

t = zeros(length(N), 1) ;
for i = 1:length(N)
    V1 = randn(N(i), 1) ;
    tic()
    V2 = V1 * V1' ;
    t(i) = toc() ;
end

figure(1)
plot(N, t)