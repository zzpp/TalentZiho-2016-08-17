function [GrowthShare,Gr_geo,YBaseline]=chaining(WhatChanges,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws,GroupToChange,ShowTimeBreakdown);

%function [Yconstanttau YconstantApq]=chaining(WhatChanges,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws);
%
% Details of the chaining.
%
%  WhatChanges={'TauWTauH','TauW','TauH','Both+Z','Both+ZTgHome'} determines how much is allowed to change
%  GroupToChange={'WW','BM','BW'} to study effect of changing Taus for just that group only.

global Nyears Decades GroupNames ExperienceCohortFactor HAllData CaseName WhatToChain

if ~exist('GroupToChange'); GroupToChange=0; end;
if ~exist('ShowTimeBreakdown'); ShowTimeBreakdown=0; end;
if isequal(WhatChanges,'TauW');         ChangeTauH=0; ChangeTauW=1; ChangeZ=0; ChangeTgHome=0; end;
if isequal(WhatChanges,'TauH');         ChangeTauH=1; ChangeTauW=0; ChangeZ=0; ChangeTgHome=0; end;
if isequal(WhatChanges,'TauWTauH');     ChangeTauH=1; ChangeTauW=1; ChangeZ=0; ChangeTgHome=0; end;
if isequal(WhatChanges,'Both+Z');       ChangeTauH=1; ChangeTauW=1; ChangeZ=1; ChangeTgHome=0; end;
if isequal(WhatChanges,'Both+ZTgHome'); ChangeTauH=1; ChangeTauW=1; ChangeZ=1; ChangeTgHome=1; end;
if isequal(WhatChanges,'NoChange');     ChangeTauH=0; ChangeTauW=0; ChangeZ=0; ChangeTgHome=0; end;


disp ' '; disp ' ';
disp '---------------------------------------------------';
disp (['   The chaining calculations for ' WhatChanges]);
disp '---------------------------------------------------';

% BASELINE -- First we get the baseline values, useful in both sides of chaining
%YBaseline=SolveForEqm(TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws);
load(['SolveEqmBasic_' CaseName]);

WageGapBaseline=WageGapBaseline';
WageGapBaseline(:,1)=[];
WageGapAllBaseline=WageGapAllBaseline';
WageGapAllBaseline(:,1)=[];
YBaseline=[GDPBaseline GDPwkrBaseline LFPBaseline EarningsBaseline EarningsAllBaseline ConsumpYoungBaseline EarningsYoungBaseline GDPYoungBaseline WageGapBaseline WageGapAllBaseline EarningsBaseline_g' HomeEarningsYBaseline Home_and_MktOutputYBaseline UtilityBaseline Utility2Baseline Util1msBaseline UtilzBaseline UtilCBaseline UtilC2Baseline FullConsumpYBaseline Home_and_MktConsumpYBaseline];
chaintle={'GDP per person','GDP per worker','Labor Force Participation (LFP)','Earnings','EarningsAll','ConsumpYoung (market)','EarningsYoung (market)','GDPYoung (market)','WageGapWW','WageGapBM','WageGapBW','WageGapAllWW','WageGapAllBM','WageGapAllBW','EarningsWM','EarningsWW','EarningsBM','EarningsBW','HomeEarningsY','Home_and_MktOutputY','Utility: CE-Welfare of Young','Utility2: log(Chome_Cmkt)','Utility: log(1-s) term','Utility: log(z) term','Utility: log(C) term','Utility: log(Chome_Cmkt)','FullConsumpY','Home_and_MktConsumpY'};


% First, solve for Yinit := Y(70,60) = Y with 70 taus but 60 state elsewhere
% Loop from t=1:(Nyears-1) and just move the tau's
Yinit=ones(size(YBaseline))*NaN;
Yi_output=Yinit; Yi_wkr=Yinit; Yi_earnings=Yinit; LFPi=Yinit;
fprintf('Solving for Yinit (e.g. Y with 1970 taus but the 1960 state)');

for t=1:(Nyears-1); % Loop over the year we take the state from (e.g. A/phi/Z)
  % Just move the Tau's
  disp ' ';
  TauWnext=TauW;
  if ChangeTauW; 
      if GroupToChange==0;
          TauWnext(:,:,t)=TauW(:,:,t+1); 
      else % For Group-Specific changes
          TauWnext(:,GroupToChange,t)=TauW(:,GroupToChange,t+1); 
      end;
  end;

  % Cohort states, be careful!
  TauHnext=TauH; Znext=Z; TgHomenext=TgHome;
  c=7-t;  CurrentCohorts=[c c+1 c+2]; % 1960 cohort, e.g.
  cN=c-1; NextCohorts=[cN cN+1 cN+2]; % 1970 cohort
  if ChangeTauH; 
        if GroupToChange==0;
            TauHnext(:,:,CurrentCohorts)=TauH(:,:,NextCohorts); 
        else;
            TauHnext(:,GroupToChange,CurrentCohorts)=TauH(:,GroupToChange,NextCohorts); 
        end;
  end;
  if ChangeZ; 
      if GroupToChange==0;
          Znext(:,:,CurrentCohorts)=Z(:,:,NextCohorts); 
      else;
          Znext(:,GroupToChange,CurrentCohorts)=Z(:,GroupToChange,NextCohorts); 
      end;
  end;
  if ChangeTgHome; 
      if GroupToChange==0;
          TgHomenext(:,:,CurrentCohorts)=TgHome(:,:,NextCohorts); 
      else;
          TgHomenext(:,GroupToChange,CurrentCohorts)=TgHome(:,GroupToChange,NextCohorts); 
      end;
  end;

  [y_output,y_earnings,y_wkr,lfp,consumpmkt,earningsyoung,gdpyoung,earningsall,wagegap,wagegapall,earnings_g,homeearningsY,home_and_mktoutputY,utility,utility2,util1ms,utilz,utilc,utilc2,fullconsumpY,home_and_mktconsumpY]=SolveForEqm(TauHnext,TauWnext,Znext,TgHomenext,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws);
  Yinit(t,:)=[y_output(t) y_wkr(t) lfp(t) y_earnings(t) earningsall(t) consumpmkt(t) earningsyoung(t) gdpyoung(t) wagegap(2:4,t)' wagegapall(2:4,t)' earnings_g(:,t)' homeearningsY(t) home_and_mktoutputY(t) utility(t) utility2(t) util1ms(t) utilz(t) utilc(t) utilc2(t) fullconsumpY(t) home_and_mktconsumpY(t)];
end;

gI=Yinit./YBaseline;
fmt='%6.0f %9.0f %9.0f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f';
cshow(' ',[Decades YBaseline(:,1) Yinit(:,1) gI],fmt,'Decade Baseline Yinit GrowthY gIYwkr gILFP gIearn gearnAll gIcons gEarnY gIgdpY gGapWW gGapBM gGapBW gGpAllWW gGpAllBM gGpAllBW gEarnWM gEarnWW gEarnBM gEarnBW gHome gHmMktY gUtil gUtil2 gU1ms gUz gUc gUc2 gFullC gHmMktC')


% Second, solve for Yfinal := Y(60,70) = Y with 60 taus but 70 state elsewhere
Yfinal=ones(size(YBaseline))*NaN;
disp ' ';
fprintf('Solving for Yfinal (e.g. Y with 1960 taus but the 1970 state)');

for t=2:Nyears; % Loop over the year we take the state from (e.g. A/phi/Z)
  % Just move the Tau's
  disp ' ';
  TauWprev=TauW;
  if ChangeTauW; 
      if GroupToChange==0;
          TauWprev(:,:,t)=TauW(:,:,t-1); 
      else;
          TauWprev(:,GroupToChange,t)=TauW(:,GroupToChange,t-1); 
      end;
  end;

  % Cohort states, be careful!
  TauHprev=TauH; TauHprev(:,:,8)=TauHprev(:,:,6); TauHprev(:,:,7)=TauHprev(:,:,6); % Placeholders
  TgHomeprev=TgHome; TgHomeprev(:,:,8)=TgHomeprev(:,:,6); TgHomeprev(:,:,7)=TgHomeprev(:,:,6); % Placeholders
  Zprev=Z; Zprev(:,:,8)=Zprev(:,:,6); Zprev(:,:,7)=Zprev(:,:,6); % Placeholders
  c=7-t;  CurrentCohorts=[c c+1 c+2]; % 1970 cohort, e.g.
  cP=c+1; PrevCohorts=[cP cP+1 cP+2]; % 1960 cohort
  if ChangeTauH; 
      if GroupToChange==0; % Using 'prev' to handle cohorts 7,8
          TauHprev(:,:,CurrentCohorts)=TauHprev(:,:,PrevCohorts); 
      else;
          TauHprev(:,GroupToChange,CurrentCohorts)=TauHprev(:,GroupToChange,PrevCohorts); 
      end;
  end; 
  if ChangeZ; 
      if GroupToChange==0;
          Zprev(:,:,CurrentCohorts)=Zprev(:,:,PrevCohorts); 
      else;
          Zprev(:,GroupToChange,CurrentCohorts)=Zprev(:,GroupToChange,PrevCohorts); 
      end;
  end;
  if ChangeTgHome; 
      if GroupToChange==0;
          TgHomeprev(:,:,CurrentCohorts)=TgHomeprev(:,:,PrevCohorts); 
      else;
          TgHomeprev(:,GroupToChange,CurrentCohorts)=TgHomeprev(:,GroupToChange,PrevCohorts); 
      end;
  end;

  [y_output,y_earnings,y_wkr,lfp,consumpmkt,earningsyoung,gdpyoung,earningsall,wagegap,wagegapall,earnings_g,homeearningsY,home_and_mktoutputY,utility,utility2,util1ms,utilz,utilc,utilc2,fullconsumpY,home_and_mktconsumpY]=SolveForEqm(TauHprev,TauWprev,Zprev,TgHomeprev,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws);
  Yfinal(t,:)=[y_output(t) y_wkr(t) lfp(t) y_earnings(t) earningsall(t) consumpmkt(t) earningsyoung(t) gdpyoung(t) wagegap(2:4,t)' wagegapall(2:4,t)' earnings_g(:,t)' homeearningsY(t) home_and_mktoutputY(t) utility(t) utility2(t) util1ms(t) utilz(t) utilc(t) utilc2(t) fullconsumpY(t) home_and_mktconsumpY(t)];
end;

gF=YBaseline./Yfinal;
cshow(' ',[Decades YBaseline(:,1) Yfinal(:,1) gF],fmt,'Decade Baseline Yfinal GrowthY gFYwkr gFlfp gFearn gearnAll gFcons gEarnY gFgdpY gGapWW gGapBM gGapBW gGpAllWW gGpAllBM gGpAllBW gEarnWM gEarnWW gEarnBM gEarnBW gHome gHmMktY gUtil gUtil2 gU1ms gUz gUc gUc2 gFullC gHmMktC')



% Now merge gI and gF to get the geometric average  % Adjust timing
gI=trimr(gI,0,1); 
gF=trimr(gF,1,0); 
Gr_geo=(gI.^(1/2)).*(gF.^(1/2));

disp ' ';
disp 'Here are the growth factors, Laspeyeres, Paasche, and GeoAvg:';
fmt='%5.0f %5.0f %8.4f %8.4f %8.4f';
tle='Yearto Year gInit gFinal GeoAvg';
years=[trimr(Decades,0,1) trimr(Decades,1,0)];
for i=1:length(chaintle);
    disp ' '; disp(chaintle{i});
    cshow(' ',[years gI(:,i) gF(:,i) Gr_geo(:,i)],fmt,tle);
end;
disp ' '; 
disp 'Cumulative growth from changes:'
for i=1:length(chaintle);
    fprintf([chaintle{i} ' = %8.4f\n'],prod(Gr_geo(:,i))); 
end;
disp ' ';
TT=Decades(6)-Decades(1);

growthBaseline=1/TT*log(YBaseline(Nyears,:)./YBaseline(1,:));
growthDueToVar=1/TT*log(prod(Gr_geo));
GrowthShare=growthDueToVar./growthBaseline*100;

growthBaseline6080=1/20*log(YBaseline(3,:)./YBaseline(1,:));
growthDueToVar6080=1/20*log(prod(Gr_geo(1:2,:)));
GrowthShare6080=growthDueToVar6080./growthBaseline6080*100;

growthBaseline8010=1/30*log(YBaseline(6,:)./YBaseline(3,:));
growthDueToVar8010=1/30*log(prod(Gr_geo(3:5,:)));
GrowthShare8010=growthDueToVar8010./growthBaseline8010*100;


disp ' ';
disp '///////////////////////////// KEY RESULT //////////////////////////////';
for i=1:length(chaintle);
    disp ' '; 
    if GroupToChange==0;
        disp(chaintle{i});
    else;
        disp([chaintle{i} ': changing taus/etc only for ' GroupNames{GroupToChange}]);
    end;
    
    fprintf('      Average annual growth of baseline (model) measure: %8.4f\n',growthBaseline(i)*100);
    fprintf(['        Average annual growth due to changing ' WhatChanges '      : %8.4f\n'],growthDueToVar(i)*100);
    fprintf(['                         >>>>>   Share accounted for by ' WhatChanges ' is %6.1f percent  <<<<<\n'],GrowthShare(i));

    if ShowTimeBreakdown;
        disp ' ';
        fprintf('       1960-80: Average annual growth of baseline: %8.4f\n',growthBaseline6080(i)*100);
        fprintf(['               Growth due to changing ' WhatChanges '      : %8.4f\n'],growthDueToVar6080(i)*100);
        fprintf(['                         >>>>>   Share accounted for by ' WhatChanges ' is %6.1f percent  <<<<<\n'],GrowthShare6080(i));
        disp ' ';
        fprintf('       1980-2010: Average annual growth of baseline: %8.4f\n',growthBaseline8010(i)*100);
        fprintf(['               Growth due to changing ' WhatChanges '      : %8.4f\n'],growthDueToVar8010(i)*100);
        fprintf(['                         >>>>>   Share accounted for by ' WhatChanges ' is %6.1f percent  <<<<<\n'],GrowthShare8010(i));
    end;
end;


%disp ' ';
%fprintf('Note well: %7.4f x %7.4f = %7.4f\n',[prod(Gr_geo) prod(GrAp_geo) prod(Gr_geo)*prod(GrAp_geo)]);
%disp ' '; disp ' ';

%Yconstanttau=100*[1; cumprod(GrAp_geo)];
%YconstantApq=100*[1; cumprod(Gr_geo)];

%if isequal(WhatChanges,'TauWTauH');
%    save(['Chaining2TauWTauH_' CaseName]);
%end;
