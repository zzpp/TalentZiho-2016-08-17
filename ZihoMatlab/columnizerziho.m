function x = columnizerziho(a)

[n m]=size(a);

if ndims(a)==2 && n==1
    x=a';
else
    x=a;
end