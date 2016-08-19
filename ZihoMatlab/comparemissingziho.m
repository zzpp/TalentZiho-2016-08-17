function [asame,bsame,a,b,x] = comparemissingziho(A,B,missingif)

%missingif is usually just [NaN] or [0, NaN]
%A and B are quantities with the same size
%a = elements that are missing in A but not missing in B
%b = elements that are missing in B but not missing in A
%x = elementa that are missing in both

%ismember itself doesn't deal with NaN. So do this.
ismembernan = @(a,b) ismember(a,b) | (isnan(a) & any(isnan(b)));

Amissing=ismembernan(A,missingif);
Bmissing=ismembernan(B,missingif);

a=Amissing.*~Bmissing;
b=~Amissing.*Bmissing;
x=Amissing.*Bmissing;

if sum(sum(a))==0
  asame='There is no place where A has missing value and B does not have it';
else
    asame='There are places where A has missing value and B does not have it';
end

if sum(sum(b))==0
  bsame='There is no place where B has missing value and A does not have it';
else
    bsame='There are places where B has missing value and A does not have it';
end

end
