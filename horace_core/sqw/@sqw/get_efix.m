function [efix,emode,ok,mess,en] = get_efix(obj,tol)
% Return the mean fixed neutron energy and emode for an array of sqw objects.
%
%   >> [efix,emode,ok,mess,en] = get_efix(win)
%   >> [efix,emode,ok,mess,en] = get_efix(win,tol)
%
% Input:
% ------
%   win         Array of sqw objects of sqw type
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
%

% Parse input
% -----------
if exist('tol','var')
    if ~(isnumeric(tol) && isscalar(tol) && tol >=0)
        error('HORACE:sqw:invalid_argument',...
            'Check optional fractional tolerance is a non-negative scalar')
    end
else
    tol=5e-3;    % relative tolerance of spread of incident energies
end

% Perform operations
% ------------------

efix_arr  = arrayfun(@(x)x.experiment_info_.get_efix(),obj,'UniformOutput',false);
efix_arr  = [efix_arr{:}];
emode_arr = arrayfun(@(x)x.experiment_info_.get_emode(),obj,'UniformOutput',false);
emode_arr = [emode_arr{:}];

[efix,emode,ok,mess,en] = Experiment.calc_efix_avrgs(efix_arr,emode_arr,tol);
