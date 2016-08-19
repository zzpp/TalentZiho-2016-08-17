function [h]=plotsaveziho(f,range, ymin, ymax, filename_header, varargin)
%plotsaveziho(f,[90:100:5000 5100:50:15000], [], [], 'fWM', t, loopthome)

nvars = length(varargin);

if size(range,2)==1
    range=range';
end

for j=1:size(range,2)
    errorplot(j)=f(range(j));
end
h=figure;
set(gcf,'Visible','off');
plot(range,errorplot,'b',range,zeros(1,size(range,2)),'r')

if ~isempty(ymin) && ~isempty(ymax)
   ylim([ymin, ymax]);
end


export_file=filename_header;
for i=1:nvars
    export_file = [export_file,'_' ,num2str(varargin{i})];
end

saveas(h,[export_file,'.jpg'])

%set(gcf,'Visible','on');

