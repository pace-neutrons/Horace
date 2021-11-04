function set_efix(filelist,varargin)
% Set the fixed neutron energy for an array of sqw files.
%
%   >> wout = set_efix(filelist, efix)
%   >> wout = set_efix(filelist, efix, emode)
%
% Input:
% ------
%   win         cellarray of files, containing sqw  objects
%   efix        Value or array of values of efix. If an array, all sqw
%              objects must have the same number of contributing spe data sets
%   emode       [Optional] Energy mode: 1=direct inelastic, 2=indirect inelastic, 0=elastic
%
% Output:
% -------
%   wout        Output sqw objects


% Original author: T.G.Perring
%


% Parse input
% -----------

narg=numel(varargin);
if narg<1 || narg>2
    error('HORACE:sqw:invalid_argument',...
        'This function accepts one or two input arguments')
end
if narg>=1
    efix=varargin{1}(:);
    if ~(isnumeric(efix) && numel(efix)>=1 && all(isfinite(efix)) && all(efix>=0))
        error('HORACE:sqw:invalid_argument',...
            'efix must be numeric scalar or array of finite values');
    end
end
if narg>=2
    emode=varargin{2};
    if ~(isnumeric(emode) && isscalar(emode) && (emode==0||emode==1||emode==2))
        error('HORACE:sqw:invalid_argument',...
            'emode must 1 (direct geometry), 2 (indirect geometry) or 0 (elastic)')
    end
else
    emode=[];   % indicates emode to be left untouched
end
% get file accessors
[ldrs,sqw_type] = get_loaders(filelist);

% Perform operations
% ==================

% Check that the data has the correct type
if ~all(sqw_type)
    non_sqw_ind = find(~sqw_type);
    error('HORACE:sqw:invalid_argument',...
        'efix and emode can only be changed in sqw-type data. Files N: %s are not sqw-type files',...
        evalc('disp(non_sqw_ind)'))
end

% Change efix and emode
% ---------------------
n_files = numel(ldrs);
for i=1:n_files
    exp_inf   = ldrs{i}.get_header('-all','-no_instument','-no_sample');
    if isempty(emode)
        exp_inf   = exp_inf.set_efix_emode(efix,'-keep_emode');   %
    else
        exp_inf   = exp_inf.set_efix_emode(efix,emode);
    end
    ld = ldrs{i}.upgrade_file_format(); % also reopens file in update mode if format is already the latest one    
    ld.put_headers(exp_inf);
    ld.delete();
end