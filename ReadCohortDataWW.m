% ReadCohortDataWW  
%
%  This is a copy (on 8/17/16) of ReadCohortData.m. It switches
%  the data for WM and WW so that all subsequent programs can be run
%  to test the robustness of assuming tau(WW)=0 instead of taum(WM)=0.


if ~isequal(CaseName,'TauWWisZero');
    disp 'Do not run this program except for the TauWWisZero check';
    keyboard
end;
diarychad('ReadCohortDataWW',CaseName);
Names67Occupations; % load the names and "brawny" occupation index.
ShowParameters;

%Year,Group,Cohort,Occupation Number,Weighted Total People in Occ,Avg Occ Income,Education,Wage
%2010,10,1,0,7610209.5,,12.7,
%2010,10,1,1,1965792.0,54377.4,15.0,

%fname='occupation_file_chad-2015-06-16.csv';
fname='chad_output_file_2016_07_25.csv'
fmt='%f %f %f %f %f %f %f %f';
[year,group,cohort,occnum,dataNumPeople,dataEarnings,dataEducation,dataWage]=textread(fname,...
   fmt,'headerlines',1,'delimiter',',','emptyvalue',NaN);
occnum=occnum+1;  % So Home=1 rather than Home=0

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize key variables
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Nrecords=length(dataNumPeople);
Noccs=67
Ngroups=4  % wm ww bm bw
Ncohorts=8
Decades=[1960 1970 1980 1990 2000 2010]';
Nyears=length(Decades);

NumPeople=zeros(Noccs,Ngroups,Ncohorts,Nyears);
Education=NumPeople;
EarningsNominal=NumPeople;
WageNominal=NumPeople;
Earnings=NumPeople;
Wage=NumPeople;

disp 'Putting earnings / wage in $2009 constant using PCE Deflator';
% See PCEDeflatorNIPA.txt from https://research.stlouisfed.org/fred2/series/DPCERD3A086NBEA
pce=[
   17.535   % 1960-01-01
   22.311   % 1970-01-01
   43.959   % 1980-01-01
   67.440   % 1990-01-01
   83.131   % 2000-01-01
  101.653   % 2010-01-01
]';


% Totals across all groups (provided by Erik in the .xls file)
AllNumPeople=zeros(Noccs,Ncohorts,Nyears);
AllEducation=AllNumPeople;
AllEarnings=AllNumPeople;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reshape into the multidimensional matrices
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:Nrecords;
    %if group(i)==10; % All -- Old code
    if group(i)==0; % All -- new code as of 7/25/16
        AllNumPeople(occnum(i),cohort(i),find(Decades==year(i)))=dataNumPeople(i);
        AllEarnings(occnum(i),cohort(i),find(Decades==year(i)))=dataEarnings(i);
        AllEducation(occnum(i),cohort(i),find(Decades==year(i)))=dataEducation(i);
    else; % One of our 4 key groups
        if year(i)>1950; % Ignore the 1950 data for now...
            decindx=find(Decades==year(i)); % e.g. decindx=2 for year=1970
            NumPeople(occnum(i),group(i),cohort(i),decindx)=dataNumPeople(i);
            if dataEarnings(i)==0; dataEarnings(i)=NaN; end; % If 0 earnings
            EarningsNominal(occnum(i),group(i),cohort(i),decindx)=dataEarnings(i);
            Earnings(occnum(i),group(i),cohort(i),decindx)=dataEarnings(i)/pce(decindx)*pce(Nyears);
            Education(occnum(i),group(i),cohort(i),decindx)=dataEducation(i);
            WageNominal(occnum(i),group(i),cohort(i),decindx)=dataWage(i);
            Wage(occnum(i),group(i),cohort(i),decindx)=dataWage(i)/pce(decindx)*pce(Nyears);
        end;        
    end;
end;

% Shut off any earnings in the Home sector -- remnants of Erik's program 7/25/16
AllEarnings(1,:,:,:)=NaN;
EarningsNominal(1,:,:,:)=NaN;
Earnings(1,:,:,:)=NaN;

% **************************************************************
% --------------------------------------------------------------
% WW: Here is where we switch WM and WW
% --------------------------------------------------------------
% **************************************************************

WM=1; WW=2;
NumPeopleWW=NumPeople(:,WW,:,:); NumPeopleWM=NumPeople(:,WM,:,:);
NumPeople(:,WM,:,:)=NumPeopleWW;
NumPeople(:,WW,:,:)=NumPeopleWM;

EarningsNominalWW=EarningsNominal(:,WW,:,:); EarningsNominalWM=EarningsNominal(:,WM,:,:);
EarningsNominal(:,WM,:,:)=EarningsNominalWW;
EarningsNominal(:,WW,:,:)=EarningsNominalWM;

EarningsWW=Earnings(:,WW,:,:); EarningsWM=Earnings(:,WM,:,:);
Earnings(:,WM,:,:)=EarningsWW;
Earnings(:,WW,:,:)=EarningsWM;

EducationWW=Education(:,WW,:,:); EducationWM=Education(:,WM,:,:);
Education(:,WM,:,:)=EducationWW;
Education(:,WW,:,:)=EducationWM;

WageNominalWW=WageNominal(:,WW,:,:); WageNominalWM=WageNominal(:,WM,:,:);
WageNominal(:,WM,:,:)=WageNominalWW;
WageNominal(:,WW,:,:)=WageNominalWM;

WageWW=Wage(:,WW,:,:); WageWM=Wage(:,WM,:,:);
Wage(:,WM,:,:)=WageWW;
Wage(:,WW,:,:)=WageWM;



% %%%%%%%%%%
%  Ziho code
% %%%%%%%%%%

%fix missing values

for generation=7:9

for g=1:1
for i=2:Noccs
    
    clear matrix_to_be_fixed
    for c=1:6
        matrix_to_be_fixed(c)=NumPeople(i,g,generation-c,c);
    end
    matrix_to_be_fixed=matrix_to_be_fixed';
    
    missing=(  isnan(  matrix_to_be_fixed )  |   matrix_to_be_fixed==0   );
    if all(missing); keyboard;
    elseif any(missing);
        display(['Something missing in c=' num2str(c) ', i=' num2str(i) ', g=' num2str(g)])
        %keyboard
        matrix_to_be_fixed=fixmissing(  matrix_to_be_fixed , missing);
    end;
    
    for c=1:6
        NumPeople(i,g,generation-c,c)=matrix_to_be_fixed(c);
    end
    

    
    
    %=================================
    clear matrix_to_be_fixed
    for c=1:6
        matrix_to_be_fixed(c)=EarningsNominal(i,g,generation-c,c);
    end
    matrix_to_be_fixed=matrix_to_be_fixed';
    
    missing=(  isnan(  matrix_to_be_fixed )  |   matrix_to_be_fixed==0   );
    if all(missing); keyboard;
    elseif any(missing);
        display(['Something missing in c=' num2str(c) ', i=' num2str(i) ', g=' num2str(g)])
        %keyboard
        matrix_to_be_fixed=fixmissing(  matrix_to_be_fixed , missing);
    end;
    
    for c=1:6
        EarningsNominal(i,g,generation-c,c)=matrix_to_be_fixed(c);
    end
    %===================================
    clear matrix_to_be_fixed
    for c=1:6
        matrix_to_be_fixed(c)=Earnings(i,g,generation-c,c);
    end
    matrix_to_be_fixed=matrix_to_be_fixed';
    
    missing=(  isnan(  matrix_to_be_fixed )  |   matrix_to_be_fixed==0   );
    if all(missing); keyboard;
    elseif any(missing);
        display(['Something missing in c=' num2str(c) ', i=' num2str(i) ', g=' num2str(g)])
        %keyboard
        matrix_to_be_fixed=fixmissing(  matrix_to_be_fixed , missing);
    end;
    
    for c=1:6
        Earnings(i,g,generation-c,c)=matrix_to_be_fixed(c);
    end
    


    %===================================
    clear matrix_to_be_fixed
    for c=1:6
        matrix_to_be_fixed(c)=Education(i,g,generation-c,c);
    end
    matrix_to_be_fixed=matrix_to_be_fixed';
    
    missing=(  isnan(  matrix_to_be_fixed )  |   matrix_to_be_fixed==0   );
    if all(missing); keyboard;
    elseif any(missing);
        display(['Something missing in c=' num2str(c) ', i=' num2str(i) ', g=' num2str(g)])
        %keyboard
        matrix_to_be_fixed=fixmissing(  matrix_to_be_fixed , missing);
    end;
    
    for c=1:6
        Education(i,g,generation-c,c)=matrix_to_be_fixed(c);
    end
    


    
%     %===================================
    clear matrix_to_be_fixed
    for c=1:6
        matrix_to_be_fixed(c)=WageNominal(i,g,generation-c,c);
    end
    matrix_to_be_fixed=matrix_to_be_fixed';
    
    missing=(  isnan(  matrix_to_be_fixed )  |   matrix_to_be_fixed==0   );
    if all(missing); keyboard;
    elseif any(missing);
        display(['Something missing in c=' num2str(c) ', i=' num2str(i) ', g=' num2str(g)])
        %keyboard
        matrix_to_be_fixed=fixmissing(  matrix_to_be_fixed , missing);
    end;
    
    for c=1:6
        WageNominal(i,g,generation-c,c)=matrix_to_be_fixed(c);
    end
    %=================================== 
    clear matrix_to_be_fixed
    for c=1:6
        matrix_to_be_fixed(c)=Wage(i,g,generation-c,c);
    end
    matrix_to_be_fixed=matrix_to_be_fixed';
    
    missing=(  isnan(  matrix_to_be_fixed )  |   matrix_to_be_fixed==0   );
    if all(missing); keyboard;
    elseif any(missing);
        display(['Something missing in c=' num2str(c) ', i=' num2str(i) ', g=' num2str(g)])
        %keyboard
        matrix_to_be_fixed=fixmissing(  matrix_to_be_fixed , missing);
    end;
    
    for c=1:6
        Wage(i,g,generation-c,c)=matrix_to_be_fixed(c);
    end
    
    %===================================

end
end
end
% %%% End of Ziho missing value stuff.



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute p == fraction of WW in Cohort 3 in 2000 who are lawyers
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p=zeros(size(NumPeople));
% Treat "NaN as 0 for purposes of computing p
xNumPeople=NumPeople;
xNumPeople(isnan(xNumPeople))=0;
total=sum(xNumPeople,1); % Add across occupations
for i=1:Noccs;
    p(i,:,:,:)=xNumPeople(i,:,:,:)./total;
end;


% pDataYWM -- p in the data for Young WM
for t=1:Nyears;
    pDataYWM(:,t)=p(:,1,7-t,t);
end;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute q(g,c,t) == fraction of Population who are WW in Cohort 3 in 2000 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xNumPeople_t=sum(squeeze(sum(sum(xNumPeople)))); % 1xT vector date t "populations"
xNumPeople_gct=squeeze(sum(xNumPeople));         % Sum over occupations
q=zeros(Ngroups,Ncohorts,Nyears)*NaN;
for t=1:Nyears;
    q(:,:,t)=squeeze(xNumPeople_gct(:,:,t))/xNumPeople_t(t);
end;




% Adjust Earnings if WageGapAdjustmentFactor=1/2 or Zero.
%  That is, Earnings = (1-WageGapAdjustmentFactor)*Earnings(WM) + WageGapAdjustmentFactor*Earnings(g)
%   Zero ==> Earnings = WM earnings, so no wage gap.
%   1/2  ==>  equally-weighted average of own and WM earnings.
for g=1:Ngroups;
    Earnings(:,g,:,:)=(1-WageGapAdjustmentFactor)*Earnings(:,WM,:,:) + WageGapAdjustmentFactor*Earnings(:,g,:,:);
    Wage(:,g,:,:)=(1-WageGapAdjustmentFactor)*Wage(:,WM,:,:) + WageGapAdjustmentFactor*Wage(:,g,:,:);
end;


% Education YWM for calibrating phiFARM
EducationYWM=zeros(Noccs,Nyears);
for t=1:Nyears;
    EducationYWM(:,t)=Education(:,1,7-t,t);
end;
disp ' ';
disp 'Education of Young WM';
cshow(ShortNames,EducationYWM,'%8.4f','1960 1970 1980 1990 2000 2010');
disp ' '

disp ' ';
fprintf(['OccupationtoIdentifyPhi = %2.0f ' OccupationNames(OccupationtoIdentifyPhi,:) '\n'],OccupationtoIdentifyPhi);
if OccupationtoIdentifyPhi~=42;
    disp 'Implied values of Phi for this occupation:'
    sKey=EducationYWM(OccupationtoIdentifyPhi,:)/25; % 25 years is denominator
    PhiKeyOcc=(1-eta)/beta.*sKey./(1-sKey)
else;
    PhiKeyOcc=phiFarm
end;

% Now call LookatCohortData to create some graphs
% and save the data for estimation.

LookatCohortData

diary off;
