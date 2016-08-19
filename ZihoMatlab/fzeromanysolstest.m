function fzeromanysolstest(check);



base=1;
for i=2:size(check,2)

    if check(base)~=check(i) && check(base)~=0 && check(i)~=0
	   
	   j=j+1;
       x00(1,j)=check(base)
       x00(2,j)=check(i)
	   base
	   i
	   
	   base=i;
    end
end
