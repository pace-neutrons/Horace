function  [efix,emode,ok,mess,en] = calc_efix_avrgs_(efix_arr,emode_arr,tol)
% calculate specific (emode dependent) average of efix array

en=struct('efix',efix_arr,'emode',emode_arr,'ave',NaN,'min',NaN,'max',NaN,'relerr',NaN);
if all(emode_arr==emode_arr(1))
    efix=sum(efix_arr)/numel(efix_arr);
    emode=emode_arr(1);
    en.ave=efix;
    en.min=min(efix_arr);
    en.max=max(efix_arr);
    if en.ave==0 && en.min==0 && en.max==0
        en.relerr=0;    % if all energies==0, then accept this as no relative error
    else
        en.relerr=max(en.max-efix,efix-en.min)./efix;
    end
    if isfinite(en.relerr) && abs(en.relerr)<=tol
        ok=true;
        mess='';
    else
        ok=false;
        mess=['Spread of efix lies outside acceptable fraction of average of ',num2str(tol)];
    end
else
    efix=NaN;
    emode=NaN;
    ok=false;
    mess='All datasets must have the same value of emode (1=direct inelastic , 2=indirect inelastic; 0=elastic)';
end
