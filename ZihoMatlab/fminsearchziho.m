function [argmin, minvalue] = fminsearchziho(f, varargin)


nvars = length(varargin);

for i=1:nvars
   [argmintemp(i) fval(i)]= fminsearch(f,i);
end

[minvalue argminindex]=min(fval);

argmin = argmintemp(argminindex);