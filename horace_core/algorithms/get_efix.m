function [efix,emode,ok,mess,en] = get_efix(win,tol)
% Return the mean fixed neutron energy and emode for cellarray of arrays
% containing sqw objects or sqw files
%
%   >> [efix,emode,ok,mess,en] = get_efix(win)
%   >> [efix,emode,ok,mess,en] = get_efix(win,tol)
%
% Input:
% ------
%   win         celarray of sqw objects or sqw files of sqw type
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
if ~iscell(win)
    win = {win};
end


nobj=numel(win);     % number of sqw objects or files
efix_arr = cell(1,nobj);
emode_arr = cell(1,nobj);
for i=1:nobj
    w = win{i};
    if ischar(w)|| isstring(w)
        ld = loaders_factory.instance().get_loader(w);
        if ~ld.sqw_type
            error('HORACE:algorithms:invalid_argument',...
                ['efix and emode can only be retrived from sqw-type data.\n', ...
                ' Object N%d, file name %s does not contain sqw information'], ...
                i,w)
        end
        exper= ld.get_header('-all');
        efix_arr{i} = exper.get_efix();
        emode_arr{i} = exper.get_emode();
        ld.delete();
    else
        if ~w.sqw_type
            error('HORACE:algorithms:invalid_argument',...
                ['efix and emode can only be retrived from sqw-type data.\n', ...
                ' Object N%d, is obj of class: %s '], ...
                i,class(w))

        end
        efix_arr{i} = w.experiment_info.get_efix();
        emode_arr{i} = w.experiment_info.get_emode();
    end
end
efix_arr = [efix_arr{:}];
emode_arr = [emode_arr{:}];

% calculate specific (emode dependent) average of efix array
[efix,emode,ok,mess,en] = Experiment.calc_efix_avrgs(efix_arr,emode_arr,tol);
