function y = integralkey(x,theta,ee,eta,beta,ptilde);

m=1/ptilde;
gofep = @(ep) m*theta*ep.^(-(1+theta)).*exp(-m*ep.^(-theta));
bofx  = @(x)  (x/beta).^(1-eta);

y=zeros(size(x));
for i=1:length(y);
    fun   = @(ep) theta*ep.^(ee*theta).*exp(-(x(i)./ep.^ee).^(-theta)).*gofep(ep); 
    y(i)=integral(fun,0,bofx(x(i)));    
end;
