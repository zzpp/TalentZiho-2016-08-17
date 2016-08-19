% integralexamples.m  6/24/16
%
%  Compares the numerical integration and simulation approaches.
%  These should give the same answer, but they don't. This makes me think there is
%  an error in my numerical integration derivation, as there were lots of places to make errors
%  there.  Better to just use the simulation (errors should average out across occs).

clear
theta=2.12
eta=.10
ee=eta/(1-eta)
beta=1
Pwork=.5
ptilde=.05
pig=Pwork*ptilde
m=1/ptilde

gofep = @(ep) m*theta*ep.^(-(1+theta)).*exp(-m*ep.^(-theta));
fun   = @(ep) theta*ep.^(ee*theta).*exp(-(x./ep.^ee).^(-theta)).*gofep(ep); 
bofx  = @(x)  (x/beta).^(1-eta);

xHprime = @(x) 1/(1-Pwork).*( (1-eta).*bofx(x).*gofep(bofx(x)).*(exp( (1/beta)^eta.*x.^(-(1-eta)) )...
                              - pig) + x.^(-theta).*integralkey(x,theta,ee,eta,beta,ptilde))
tic
TheMean = integral(xHprime,1e-2,1e8);
fprintf('The mean of ep^ee*epsilonH given you stay at home is %8.4f\n',TheMean)
toc


% Now try with Chang's simulation approach
N=10^7
tic
u1=rand(N,1);
eH=(-log(u1)).^(-1/theta);
u2=rand(N,1);
estar=(-ptilde*log(u2)).^(-1/theta);

home=(eH>beta*estar);
SimMean=mean( estar(home).^ee.*eH(home) );
fprintf('The Simulation mean of ep^ee*epsilonH given you stay at home is %8.4f\n',SimMean)
toc