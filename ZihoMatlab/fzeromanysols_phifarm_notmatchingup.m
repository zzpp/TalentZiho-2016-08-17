function [x,fval,flag,j,signf]=fzeromanysols(f,range);

if size(range,2)==1
   range=range';
end
j=0;
for i=1:size(range,2)
    range(i);
    ff(i)=f(range(i));
    signf(i)=sign(ff(i));
    
	check(i)=signf(i);
    if signf(i)~=1 && signf(i)~=-1
       check(i)=0;
    end
end


base=1;
for i=2:size(range,2)

    if check(base)~=check(i) && check(base)~=0 && check(i)~=0
	   
	   j=j+1;
       x00(1,j)=range(base);
       x00(2,j)=range(i);
       
       [x(j),fval(j),flag(j)]=fzero(f,  [x00(1,j) x00(2,j)] );
	   
	   base=i;
    end
end


if j==0
   x=[];
   fval=[];
   flag=[];
end

end


