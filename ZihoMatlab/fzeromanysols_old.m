function [x,fval,flag]=fzeromanysols(f,range, x0,factor,NumTries);

if size(range,2)==1
   range=range';
end
j=0;
for i=1:size(range,2)
    ff(i)=f(range(i));
    signf(i)=sign(ff(i));
    if i>1
       if signf(i-1) ~= signf(i) && ~isnan(signf(i-1).*signf(i)) && ~isinf(ff(i-1).*ff(i)) && isreal(ff(i-1).*ff(i));
         j=j+1;
         x00(1,j)=range(i-1);
         x00(2,j)=range(i);
         
         [x(j),fval(j),flag(j)]=fzero(f,  [x00(1,j) x00(2,j)] );
       end
    end
end

if j==0
    [x,fval,flag]=fzerochad(f,x0,factor,NumTries);
end

end


