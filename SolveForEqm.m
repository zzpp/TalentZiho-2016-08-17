function [YModel,EarningsModel,YwkrModel,LFPModel,ConsumpYoungModel,EarningsYoungModel,GDPYoungModel,EarningsAllModel,WageGapModel,WageGapAllModel,EarningsModel_g,HomeEarningsYModel,Home_and_MktOutputY,Utility,Utility2,Util1ms,Utilz,UtilC,UtilC2,FullConsumpY,Home_and_MktConsumpY,wModel,HModel,HModelAll,pModel,ExitFlag]=SolveForEqm(TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws);

% SolveForEqm.m    
%
% Given TauW, TauH, Z, TgHome, etc. this function solves for the general equilibrium.
%
%   Y    = GDP per person = Y in the model
%   Ywkr = GDP per worker = Y / LFP
%   LFP  = Aggregate LFP rate = Fraction of total population that is working
%
%  See 2015-06-02-SolvingGE.pdf notes.
%
%  Method: For each year,
%    1. Guess values for {mgtilde}, Y ==> 5 unknowns
%    2. Solve for {wi} from Hi^supply = Hi^demand
%    3. Compute mghat, Yhat 
%    4. Iterate until converge.

global Noccs Ngroups Ncohorts Nyears CohortConcordance TauW_Orig pData 
global TauW_C phi_C mgtilde_C w_C StopHere % For keeping track of history in solution

StopHere=0;

% Initialize cohort history, needed for solution.
w_C=zeros(Noccs,Ncohorts); 
mgtilde0=11000; % mgtilde := mg^(1/theta*1/(1-eta)) -- better scaled
mgtilde_C=ones(Ngroups,Ncohorts)*mgtilde0; 
TauW_C=zeros(Noccs,Ngroups,Ncohorts); % Cohort order
for g=1:Ngroups;
    TauW_C(:,g,1:6)=flipud(squeeze(TauW(:,g,:))')';
end;


% Guesses
Y0=15000;
%x0=[11000 8000 8000 8000 Y0];
%x0=[1100 800 800 800 Y0]; % For theta(1-eta)=3.44 and eta=1/4
%x0=[1100 800 800 800 Y0]/3; % For theta(1-eta)=3.44 and eta=1/4
x0=[15000 8000 10000 8000 Y0]; % For theta(1-eta)=1.9 and eta=.10 See mgtilde_C(:,c)=x(1:4); line below for help
%options=optimset('Display','iter'); %,'Algorithm','trust-region-dogleg');
options=optimset('Display','none'); %,'Algorithm','trust-region-dogleg');
wModel=zeros(Noccs,Nyears);
HModel=zeros(Noccs,Nyears);
LFPModel=zeros(Nyears,1);
pModel=zeros(Noccs,Ngroups,3,Nyears); % YMO is 3rd dimension
HModelAll=zeros(Noccs,Ngroups,3,Nyears); % YMO is 3rd dimension
EarningsModel=zeros(Nyears,1);    % Total Labor Earnings (differs from Y if Revenue~=0)
EarningsModel_g=zeros(Ngroups,Nyears);    % Total Labor Earnings by Group
EarningsAllModel=zeros(Nyears,1); % Total Labor Earnings if everyone worked (Pwork=1)
ConsumpYoungModel=zeros(Nyears,1);
EarningsYoungModel=zeros(Nyears,1);
HomeConsumpYModel=zeros(Nyears,1);
FullConsumpY=zeros(Nyears,1);
GDPYoungModel=zeros(Nyears,1);
HomeEarningsYModel=zeros(Nyears,1); % Earnings in home sector by the Young
Home_and_MktOutputY=zeros(Nyears,1); % Home+Mkt Production by the Young
Home_and_MktConsumpY=zeros(Nyears,1); % Home+Mkt Production by the Young
Utility=zeros(Nyears,1); 
Utility2=zeros(Nyears,1); 
Util1ms=zeros(Nyears,1); 
Utilz=zeros(Nyears,1); 
UtilC=zeros(Nyears,1); 
UtilC2=zeros(Nyears,1); 
SZTerm=zeros(Nyears,1); 
YModel=zeros(Nyears,1);
WageGapModel=zeros(Ngroups,Nyears);
WageGapAllModel=zeros(Ngroups,Nyears); % WageGap if everyone worked (Pwork=1)
ExitFlag=zeros(Nyears,1);

% Iterate over time to solve the model decade by decade
for t=1:Nyears;
    fprintf('.');
    fune_solve=@(x) e_solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,[]);
    [x,fval,flag]=fsolve(fune_solve,x0,options);
    ExitFlag(t)=flag; if flag~=1; disp 'Exit Flag not equal to one. Stopping...'; keyboard; end;
    [resid,wt,Ht,Yhat,HModelAllt,pModelt,LaborIncome,LaborIncome_g,WageGapt,ConsumpYoung_t,EarningsYoung_t,GDPYoung_t,LaborIncomeAll,WageGapAllt,HomeEarningsYt,Home_and_MktOutputYt,Utilityt,Utility2t,Util1mst,Utilzt,UtilCt,UtilC2t,FullConsumpYt,SZTermt,Home_and_MktConsumpYt]=e_solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws); 
    c=7-t;
    mgtilde_C(:,c)=x(1:4); % Drop the comma here to see the mgtilde if x0 guess is wrong
    w_C(:,c)=wt;
    wModel(:,t)=wt;
    HModel(:,t)=Ht;
    HModelAll(:,:,:,t)=HModelAllt;
    pModel(:,:,:,t)=pModelt;
    EarningsModel(t)=LaborIncome;
    EarningsModel_g(:,t)=LaborIncome_g;
    EarningsAllModel(t)=LaborIncomeAll;
    YModel(t)=Yhat;
    WageGapModel(:,t)=WageGapt;
    WageGapAllModel(:,t)=WageGapAllt;
    ConsumpYoungModel(t)=ConsumpYoung_t;
    EarningsYoungModel(t)=EarningsYoung_t;
    GDPYoungModel(t)=GDPYoung_t;
    HomeEarningsYModel(t)=HomeEarningsYt;
    Home_and_MktOutputY(t)=Home_and_MktOutputYt;
    Utility(t)=Utilityt;
    Utility2(t)=Utility2t;
    Util1ms(t)=Util1mst;
    Utilz(t)=Utilzt;
    UtilC(t)=UtilCt;
    UtilC2(t)=UtilC2t;
    FullConsumpY(t)=FullConsumpYt;
    SZTerm(t)=SZTermt;
    Home_and_MktConsumpY(t)=Home_and_MktConsumpYt;
    %StopHere=1;
    %solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar); % Returns Noccs x 1 vectors of wages and H(i,t)  and NxG wtilde

    % Compute LFP and GDP per worker from the solution
    % First, we add up across YMO
    Pwork_gYMO=squeeze(sum(pModelt(2:Noccs,:,:))); % Ngroups x YMO
    Pwork_g=zeros(Ngroups,1);
    %NumPeople_g=zeros(Ngroups,1);
    for ymo=0:2;
        Pwork_g    =Pwork_g+Pwork_gYMO(:,1+ymo).*q(:,c+ymo,t);
        %NumPeople_g=NumPeople_g+q(:,c+ymo,t);
    end;
    LFPModel(t)=sum(Pwork_g); % No need to multiply by NumPeople_g, as we've already done that!
    
    if flag==1;
        x0=x; % Use most recent results for new starting point
    end;
end;
YwkrModel=YModel./LFPModel;  % GDP per worker = GDP per person * Persons/Wkrs


% -------------------------------------------------------
% Sub-functions
% -------------------------------------------------------


function [resid,wt,Ht,Yhat,HModelAllt,pmodelt,LaborIncome,LaborIncome_g,WageGapt,ConsumpYoung_t,EarningsYoung_t,GDPYoung,LaborIncomeAll,WageGapAllt,HomeEarningsY,Home_and_MktOutputY,Utility,Utility2,Util1ms,Utilz,UtilC,UtilC2,FullConsumpY,SZTerm,Home_and_MktConsumpY]=e_solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws); 

% Given a guess for x=[mgtilde Y] 5x1 and a year t (e.g. 1=1960), 
% solve for w(i) in year t and then compute key moments:
%
%    1. Guess values for {mgtilde}, Y ==> 5 unknowns
%    2. Solve for {wi} from Hi^supply = Hi^demand
%    3. Compute mghat, Yhat 
%    4. Iterate until converge.


global Noccs Ngroups Ncohorts Nyears CohortConcordance TauW_Orig pData ShortNames CaseName
global TauW_C phi_C mgtilde_C w_C pModel % For keeping track of history in solution

mgtilde_t=x(1:4);
Y_t=x(5);

[wt,Ht,wtildet,HModelAllt,pmodelt,Pworkt]=solveeqm(x,t,TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar); % Returns Noccs x 1 vectors of wages and H(i,t)  and NxG wtilde
mgtildehat=(sum(wtildet.^theta)).^mu;
rho=1-1/sigma;
mu=1/theta*1/(1-eta);
Yhat=sum( (A(:,t).*Ht).^rho ).^(1/rho);
resid=[mgtilde_t-mgtildehat Yhat-Y_t];

% WageGapt (1 x Ngroups) = WageBar(g)/WageBar(WM) net of taxes
%   Average across occupations
%   HModelAllt (Noccs x Ngroups x YMO) but HModelAllt already includes q
%     HAll_i(:,ymo+1)=(q(:,c,t)'.*pig_t.*texp_t.*AvgQuality)';
%   q (Ngroups x Ncohorts x Nyears)
%   pmodelt (Noccs x Ngroups x YMO)  
%   LaborIncomeAll: Total earnings at market prices if *everyone* worked (Pwork=1)
%     From 2016-02-17-EarningsAll.pdf notes, we multiply HModelAllt by Pwork^(mu-1).
%     The mu exponent gets the "per worker" version right, and the -1 adjusts for 
%     the aggregation, converting p(i,g) into ptilde.
%
%   Simple aggregates in the model are all "per person" since our economy has a population=1.

TotalEarnings_ig = mult(squeeze(1-TauW(:,:,t)).*sum(HModelAllt,3),wt);  % Noccs x Ngroups
LaborIncome_g=sum(TotalEarnings_ig(2:Noccs,:)); % 1 x Ngroups
LaborIncome=sum(sum(TotalEarnings_ig(2:Noccs,:)));
TotalEarningsAll_ig = mult(squeeze(1-TauW(:,:,t)).*sum(HModelAllt.*Pworkt.^(mu-1),3),wt);  % Noccs x Ngroups
LaborIncomeAll=sum(sum(TotalEarningsAll_ig(2:Noccs,:)));

lfp_gc=squeeze(sum(pmodelt(2:Noccs,:,:))); % This is Pwork_gc Ngroups x YMO
c=7-t; co=c+2;
NumWorkers_g = sum(q(:,c:co,t).*lfp_gc,2)';  % 1xG
WageBar_g  = sum(TotalEarnings_ig)./NumWorkers_g; %1xG
WageGapt=WageBar_g/WageBar_g(1);

NumWorkersAll_g = sum(q(:,c:co,t).*1,2)';  % 1xG  lfp_gc=1
WageBarAll_g  = nansum(TotalEarningsAll_ig)./NumWorkersAll_g; %1xG
WageGapAllt=WageBarAll_g/WageBarAll_g(1);

% Market Consumption: Updated 6/9/16. See Chad-TalentNotes.pdf (page 2c)
%     c* = 1/3*(1-eta)*LifetimeIncome = cYoung
%     e*(1+tauh) = eta*LifetimeIncome
EarningsYoung_ig = mult(squeeze(1-TauW(:,:,t)).*HModelAllt(:,:,1),wt);  % Noccs x Ngroups
LIYoung_ig=Tbar(:,:,t)./TExperience(:,:,c,t).*EarningsYoung_ig; % Noccs x Ngroups
NumYoungt=sum(q(:,7-t,t));
cY_ig=1/3*(1-eta)*LIYoung_ig; % Aggregate market consumption for the young in i,g since HModelAll aggregates
cY_ig(1,:)=0; % Zero out home values in case they are NaN to make summations work easily.
ConsumpYoung_t=sum(sum(cY_ig))/NumYoungt; % Per young person
EarningsYoung_t=sum(sum(EarningsYoung_ig))/NumYoungt; % Per young person
if isnan(ConsumpYoung_t); disp 'ConsumpYoung_t isnan'; keyboard; end;

% HOME 
%  Compute home production and consumption
%  as well as total.
%     Key idea: Need E[estar^ee*eH | home]. Use simulation
%  Just for Young (we don't see 1960/70 M/O e/s/h(.)

if ~isempty(NumHomeDraws);
    %tic
    %fprintf('Computing Home stuff...  ');
    HomeEarningsY_ig=zeros(Noccs,Ngroups)*NaN;
    HomeConsump_ig=zeros(Noccs,Ngroups)*NaN;
    Utility_ig=zeros(Noccs,Ngroups)*NaN;
    Util1ms_ig=zeros(Noccs,Ngroups)*NaN;
    Utilz_ig  =zeros(Noccs,Ngroups)*NaN;
    UtilC_ig  =zeros(Noccs,Ngroups)*NaN;
    szterm_g = zeros(1,Ngroups)*NaN;
    ptilde=pmodelt./Pworkt;  % Noccs x Ngroups x YMO
    ptildeY=squeeze(ptilde(:,:,1)); % Young
    s_c=1./(1+(1-eta)/beta./phi(:,t));

    for g=1:Ngroups;
        u1=rand(NumHomeDraws,Noccs);
        eH=(-log(u1)).^(-1/theta);
        u2=rand(NumHomeDraws,Noccs);
        estar=(-mult(log(u2),ptildeY(:,g)')).^(-1/theta);
        
        THOME=squeeze(TgHome(1,g,c));
        homestuff=(1-TauW(:,g,t)).*wt.*TExperience(:,g,c,t)./ (wH_T(t).*THOME.*TgHome(:,g,c));
        home=(eH>mult(estar,homestuff'));
        FracHomeSimul=mean(sum(home(:,2:Noccs)))/NumHomeDraws;
        FracHomeModel=1-mean(Pworkt(2:Noccs,g,1));
        %fprintf('Frac home in simulation =%10.5f vs Frac home in model =%10.5f\n',[FracHomeSimul FracHomeModel]);
        if abs(FracHomeSimul-FracHomeModel)>1e-3; 
            disp 'Error...';
            fprintf('Frac home in simulation =%10.5f vs Frac home in model =%10.5f\n',[FracHomeSimul FracHomeModel]);
            keyboard;
        end;
        stophi=s_c.^phi(:,t);
        hbar=stophi.*( eta*(1-TauW(:,g,t)).*wt.*Tbar(:,g,t).*stophi./(1+TauH(:,g,c)) ).^(eta/(1-eta));
 
        eproduct=estar.^(eta/(1-eta)).*eH;
        eproduct(home)=NaN;
        SimMean=nanmean(eproduct)';
        HomeEarningsY_ig(:,g)=wH_T(t).*THOME.*TgHome(:,g,c).*hbar.*SimMean;
        % Note: HomeEarningsY_ig is already an "average" earnings per home person in i,g

        estarhome=estar; estarhome(~home)=NaN; % Omit if not at home
        ed2=nanmean(estarhome.^(1/(1-eta)))'; % For ed spending of people staying home
        ed1=(1+TauH(:,g,c)).*( eta*(1-TauW(:,g,t)).*wt.*Tbar(:,g,t).*stophi./(1+TauH(:,g,c)) ).^(1/(1-eta));
        EduGross_ig=ed1.*ed2; % Noccs x 1 for group g
        LIHomeY_ig=Tbar(1,g,t)./TExperience(1,g,c,t).*HomeEarningsY_ig(:,g); % Noccs x 1 for group g
        HomeConsumpY_ig(:,g)=1/3*(LIHomeY_ig-EduGross_ig);  % Smooth over lifetime
        indx=find(HomeConsumpY_ig(:,g)<0);
        if ~isempty(indx); 
            fprintf('Fixing %4.0f observations with Negative Home Consumption -> 1/3 of mean\n',length(indx)); 
            HomeConsumpY_ig(indx,g)=1/3*nanmean(HomeConsumpY_ig(:,g));
        end;
        
        % Note: cY_ig is an aggregate, whereas HomeConsumptionY_ig is an average
        NumYoungWorkers_ig = Pworkt(:,g,1).*ptildeY(:,g)*q(g,c,t);
        NumYoungHome_ig = (1-Pworkt(:,g,1)).*ptildeY(:,g)*q(g,c,t);
        FullConsump_ig(:,g)=(cY_ig(:,g)+ HomeConsumpY_ig(:,g).*NumYoungHome_ig)./(NumYoungWorkers_ig+NumYoungHome_ig);
        Cterm=beta*(Pworkt(:,g,1).*log(cY_ig(:,g)./NumYoungWorkers_ig) + (1-Pworkt(:,g,1)).*log(HomeConsumpY_ig(:,g)));
        Cterm2=beta*log(FullConsump_ig(:,g));
        Utility_ig(:,g) = log(1-s_c) + Cterm + log(Z(:,g,c));
        Utility2_ig(:,g) = log(1-s_c) + Cterm2 + log(Z(:,g,c));
        Util1ms_ig(:,g) = log(1-s_c);
        Utilz_ig(:,g)   = log(Z(:,g,c));
        UtilC_ig(:,g)   = Cterm;
        UtilC2_ig(:,g)  = Cterm2;
        
        % if strcmp(CaseName,'Benchmark') | strcmp(CaseName,'Sandbox');
        %     disp ' ';
        %     fprintf('Components of utility for group %1.0f\n',g);
        %     if t>1;
        %         load oldptildeY;
        %         szterm=(log(1-s_c)+log(Z(:,g,c))).*(ptildeY(:,g)-ptildeYold(:,g));
        %     else;
        %         szterm=ones(size(s_c))*NaN;
        %     end;
        %     xx=[log(1-s_c)  beta*Pworkt(:,g,1).*log(cY_ig(:,g)./NumYoungWorkers_ig)  beta*(1-Pworkt(:,g,1)).*log(HomeConsumpY_ig(:,g))  log(Z(:,g,c)) log(1-s_c)+log(Z(:,g,c)) ptildeY(:,g)*100  Utility_ig(:,g) szterm];
        %     cshow(ShortNames,xx,'%12.2f','log(1-s) log(cM) log(cH) log(z) log[(1-s)z] ptildeY Utility sz*dPtilde');
        %     szterm_g=nansum(szterm);
        %     fprintf('The sum of log[(1-s)z]*Delta(ptilde) = %12.4f\n',szterm_g);
        %     ptildeYold=ptildeY;
        % end;
    end;
    
    % if strcmp(CaseName,'Benchmark') | strcmp(CaseName,'Sandbox');
    %     ptildeYold=ptildeY;
    %     save oldptildeY ptildeYold;
    % end;
    
    pHome=squeeze(pmodelt(1,:,1));  % 1 x Ngroups
    HomeEarningsY_g=nansum(ptildeY.*HomeEarningsY_ig); % 1 x Ngroups
    HomeEarningsY=sum(pHome'.*HomeEarningsY_g'.*squeeze(q(:,c,t)));
    HomeEarningsY=HomeEarningsY/NumYoungt; % Per young person
    
    GDPYoung_ig = mult(HModelAllt(:,:,1),wt);  % HModelAllt already includes the q(.) and p(.)
    GDPYoung =sum(sum(GDPYoung_ig))/NumYoungt; % Per young Person
    Home_and_MktOutputY=GDPYoung+HomeEarningsY;
 
    HomeConsumpY_g=nansum(ptildeY.*HomeConsumpY_ig); % 1 x Ngroups
    HomeConsumpY=sum(pHome'.*HomeConsumpY_g'.*squeeze(q(:,c,t)));
    HomeConsumpY=HomeConsumpY/NumYoungt; % Per young person
    
    FullConsumpY_g=nansum(ptildeY.*FullConsump_ig);                 % 1xNgroups
    FullConsumpY  =sum(FullConsumpY_g'.*squeeze(q(:,c,t)))/NumYoungt;

    Utility_g=nansum(ptildeY.*Utility_ig);                 % 1xNgroups
    Utility  =sum(Utility_g'.*squeeze(q(:,c,t)))/NumYoungt;
    Utility2_g=nansum(ptildeY.*Utility2_ig);                 % 1xNgroups
    Utility2  =sum(Utility2_g'.*squeeze(q(:,c,t)))/NumYoungt;
    Util1ms_g=nansum(ptildeY.*Util1ms_ig);                 % 1xNgroups
    Util1ms  =sum(Util1ms_g'.*squeeze(q(:,c,t)))/NumYoungt;
    Utilz_g=nansum(ptildeY.*Utilz_ig);                 % 1xNgroups
    Utilz  =sum(Utilz_g'.*squeeze(q(:,c,t)))/NumYoungt;
    UtilC_g=nansum(ptildeY.*UtilC_ig);                 % 1xNgroups
    UtilC  =sum(UtilC_g'.*squeeze(q(:,c,t)))/NumYoungt;
    UtilC2_g=nansum(ptildeY.*UtilC2_ig);                 % 1xNgroups
    UtilC2  =sum(UtilC2_g'.*squeeze(q(:,c,t)))/NumYoungt;
    SZTerm   =sum(szterm_g'.*squeeze(q(:,c,t)))/NumYoungt;
    
    if FullConsumpY==0; disp 'FullConsumpY = 0'; keyboard; end;
    %toc;
else;
    HomeEarningsY=NaN;
    GDPYoung=NaN;
    Home_and_MktOutputY=NaN;
    HomeConsumpY=NaN;
    FullConsumpY=NaN;
    Utility=NaN;
    Utility2=NaN;
    Util1ms=NaN;
    Utilz=NaN;
    UtilC=NaN;
    UtilC2=NaN;
    SZTerm=NaN;
end;
Home_and_MktConsumpY=HomeConsumpY+ConsumpYoung_t;
Utility=exp(Utility); % To feed the right number in for chaining (like Consumption, not log(c))
Utility2=exp(Utility2); % To feed the right number in for chaining (like Consumption, not log(c))
Util1ms=exp(Util1ms); % To feed the right number in for chaining (like Consumption, not log(c))
Utilz  =exp(Utilz);   % To feed the right number in for chaining (like Consumption, not log(c))
UtilC  =exp(UtilC);   % To feed the right number in for chaining (like Consumption, not log(c))
UtilC2 =exp(UtilC2);   % To feed the right number in for chaining (like Consumption, not log(c))

%if ~isnan(GDPYoung); keyboard; end;
