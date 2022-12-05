function [pulse_model,pm_par_avrg,ok,mess,p] =calc_mod_pulse_avrgs_(pm_par,pm_list,tol)
%CALC_MOD_PULSE_AVRGS_ calculates average parameters of the pulse model
%provided 

pulse_model = pm_list{1};
all_same = cellfun(@(x)strcmp(x,pulse_model),pm_list);
if ~all(all_same)
    mess = sprintf('Different objects have different pulse models defined on them');
    ok = false;
    return;
end


p=struct('pp',[],'ave',[],'min',[],'max',[],'relerr',[]);
p.pp=pm_par;
p.ave=mean(pm_par,1);
p.min=min(pm_par,[],1);
p.max=max(pm_par,[],1);
tmp=~(p.ave==0 & p.min==0 & p.max==0);
p.relerr=zeros(size(p.ave));
p.relerr(tmp)=max([p.max(tmp)-p.ave(tmp);p.ave(tmp)-p.min(tmp)],[],1)./p.ave(tmp);
if any(p.relerr>=tol)
    ok=false;
    mess=['Spread of one or more pulse parameters lies outside acceptable fraction of average of ',num2str(tol)];
else
    ok = true;
    mess = '';
end
pm_par_avrg=p.ave;

