function [x,fval,flag,j]=plotsaveziho(f,range, ymin, ymax, file_name, varargin)

if size(range,2)==1
    range=range';
end

h=figure;
set(gcf,'Visible','off');

for j=1:size(range,2)
    errorplot(j)=f(range(j));
end
plot(range,errorplot,'b',range,zeros(1,size(range,2)),'r')

if exist('ymin')==1 && exist('ymax')==1
   ylim([ymin, ymax]);
end

export_file=filename;
for i=1:nvars
    export_file = [export_file,'_' ,num2str(varargin(i))];
end

saveas(h,[export_file,'.jpg'])

