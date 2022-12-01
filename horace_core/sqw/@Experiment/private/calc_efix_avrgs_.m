function  [efix,emode,ok,mess,en] = calc_efix_avrgs_(efix_arr,emode_arr,tol)
% calculate specific (emode dependent) average of efix array
%
% Input:
% ------
%  efix_arr     Array of energies
%  emode_arr    Array of instrument modes. (the same length as efix_arr)
%   tol         [Optional] acceptable relative spread w.r.t. average:
%                   max(|max(efix)-efix_ave|,|min(efix)-efix_ave|) <= tol*efix_ave
%
% Output:
% -------
%   efix        Mean fixed neutron energy (meV) (=NaN if not all data sets have the same emode)
%   emode       Value of emode (1,2 for direct, indirect inelastic; =0 elastic)
%              All efix must have the same emode. (emode returned as NaN if not the case)
%   ok          Logical flag: =true if within tolerance, otherwise =false;
%   mess        Error message; empty if OK, non-empty otherwise
%   en          Structure with various information about the spread
%                   en.efix     array of all efix values, as read from sqw objects
%                   en.emode    array of all emode values, as read from sqw objects
%                   en.ave      average efix (same as output argument efix)
%                   en.min      minimum efix
%                   en.max      maximum efix
%                   en.relerr   larger of (max(efix)-efix_ave)/efix_ave
%                               and abs((min(efix)-efix_ave))/efix_ave
%                 (If emode not the same for all data sets, ave,min,max,relerr all==NaN)

% Original author: T.G.Perring

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
