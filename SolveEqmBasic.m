% SolveEqmBasic.m    
%
%  Takes the TalentData.mat data on Taus, Z's, TgHome, A(i,t).
%  Solves for the equilibrium w(i) and Y
%
%  See 2015-06-02-SolvingGE.pdf notes.
%
%  Method: For each year,
%    1. Guess values for {mgtilde}, Y ==> 5 unknowns
%    2. Solve for {wi} from Hi^supply = Hi^demand
%    3. Compute mghat, Yhat 
%    4. Iterate until converge.

clear; global CaseName;
diarychad('SolveEqmBasic',CaseName);

global Noccs Ngroups Ncohorts Nyears CohortConcordance TauW_Orig pData HAllData q ShortNames
global TauW_C phi_C mgtilde_C w_C % For keeping track of history in solution

load(['TalentData_' CaseName]); % From EstimateTauZ2 and earlier programs
ShowParameters;

[YModel,EarningsModel,YwkrModel,LFPModel,ConsumpYoungModel,EarningsYoungModel,GDPYoungModel,EarningsAllModel,WageGapModel,WageGapAllModel,EarningsModel_g,HomeEarningsYModel,Home_and_MktOutputY,Utility,Utility2,Util1ms,Utilz,UtilC,UtilC2,FullConsumpY,Home_and_MktConsumpY,wModel,HModel,HModelAll,pModel,ExitFlag]=SolveForEqm(TauH,TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws);

% Now show results using a separate program (so we can call it elsewhere when testing)
SolveEqmBasic_Display


GDPBaseline=YModel;
GDPBaseline_Young=GDPYoung_Model;
EarningsBaseline=EarningsModel;
EarningsAllBaseline=EarningsAllModel;
GDPwkrBaseline=YwkrModel;
LFPBaseline=LFPModel;
WageGapBaseline=WageGapModel;
WageGapAllBaseline=WageGapAllModel;
EarningsBaseline_g=EarningsModel_g;
ConsumpYoungBaseline=ConsumpYoungModel;
EarningsYoungBaseline=EarningsYoungModel;
GDPYoungBaseline=GDPYoungModel;
HomeEarningsYBaseline=HomeEarningsYModel;
Home_and_MktOutputYBaseline=Home_and_MktOutputY;
UtilityBaseline=Utility;
Utility2Baseline=Utility2;
Util1msBaseline=Util1ms;
UtilzBaseline=Utilz;
UtilCBaseline=UtilC;
UtilC2Baseline=UtilC2;
FullConsumpYBaseline=FullConsumpY;
Home_and_MktConsumpYBaseline=Home_and_MktConsumpY;
save(['SolveEqmBasic_' CaseName],'GDPBaseline','GDPwkrBaseline','GDPBaseline_Young','EarningsBaseline','EarningsBaseline_g','EarningsAllBaseline','ConsumpYoungBaseline','EarningsYoungBaseline','GDPYoungBaseline','LFPBaseline','WageGapBaseline','WageGapAllBaseline','HomeEarningsYBaseline','Home_and_MktOutputYBaseline','UtilityBaseline','Utility2Baseline','Util1msBaseline','UtilzBaseline','UtilCBaseline','UtilC2Baseline','FullConsumpYBaseline','Home_and_MktConsumpYBaseline');



% For Benchmark case, let's compute the gains from eliminating TauH, TauW and Both
if isequal(CaseName,'Benchmark');
    
    [Y_NoTauH,a1,a2,a3,a4,a5,YYoung_NoTauH]=SolveForEqm(zeros(size(TauH)),TauW,Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws);    
    [Y_NoTauW,a1,a2,a3,a4,a5,YYoung_NoTauW]=SolveForEqm(TauH,zeros(size(TauW)),Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws);    
    [Y_NoTaus,a1,a2,a3,a4,a5,YYoung_NoTaus]=SolveForEqm(zeros(size(TauH)),zeros(size(TauW)),Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws);    

    Gain_NoTauH=Y_NoTauH./YModel-1;
    Gain_NoTauW=Y_NoTauW./YModel-1;
    Gain_NoTaus=Y_NoTaus./YModel-1;
    YGain_NoTauH=YYoung_NoTauH./GDPYoungModel-1;
    YGain_NoTauW=YYoung_NoTauW./GDPYoungModel-1;
    YGain_NoTaus=YYoung_NoTaus./GDPYoungModel-1;
    
    disp ' '; disp ' ';
    disp '********************************************************************';
    disp '       Counterfactual results with ZERO TAUW AND TAUH';
    disp '********************************************************************'; disp ' ';
    disp ' '; disp ' ';
    
    disp 'OVERALL: Additional output gain over baseline with no frictions (percent):';
    cshow(' ',[Decades 100*[Gain_NoTauH Gain_NoTauW Gain_NoTaus]],'%6.0f %12.1f','Year NoTauH NoTauW NoTauH/W');

    disp ' ';
    disp 'GDPYoung: Additional output gain over baseline with no frictions (percent):';
    cshow(' ',[Decades 100*[YGain_NoTauH YGain_NoTauW YGain_NoTaus]],'%6.0f %12.1f','Year NoTauH NoTauW NoTauH/W');

    % For Baseline case, also show results if Zero TauW/TauH (for Altonji)
    [YModel,EarningsModel,YwkrModel,LFPModel,ConsumpYoungModel,EarningsYoungModel,GDPYoungModel,EarningsAllModel,WageGapModel,WageGapAllModel,EarningsModel_g,HomeEarningsYModel,Home_and_MktOutputY,Utility,Utility2,Util1ms,Utilz,UtilC,UtilC2,FullConsumpY,Home_and_MktConsumpY,wModel,HModel,HModelAll,pModel,ExitFlag]=SolveForEqm(zeros(size(TauH)),zeros(size(TauW)),Z,TgHome,TExperience,TigYMO,A,phi,q,wH_T,gam,beta,eta,theta,mu,sigma,Tbar,NumHomeDraws);
    SolveEqmBasic_Display

    disp '********************************************************************';
    disp '    END of Counterfactual results with ZERO TAUW AND TAUH';
    disp '********************************************************************';

end;

diary off;
