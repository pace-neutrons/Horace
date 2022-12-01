function varargout = set_efix(in_data,varargin)
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
if ~iscell(in_data)
    in_data = {in_data};
end
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
%
% get accessors and check how efix/emode are set
n_obj = numel(in_data);
obj_list = cell(1,n_obj);
for i=1:numel(in_data)
    the_obj = in_data{i};
    if ischar(the_obj) || isstring(the_obj)
        obj_list{i} = sqw_formats_factory.instance().get_loader(the_obj);
        if ~obj_list{i}.sqw_type
            error('HORACE:sqw:invalid_argument',...
                'efix and emode can only be changed in sqw-type data. Files N:%d, Name %s is not sqw-type file',...
                i,the_obj)
        end
    elseif isa(the_obj,'sqw')
        obj_list{i} = the_obj;
    else
        error('HORACE:algorithms:invalid_argument',...
            'The object N%d in the list of input objects is neither sqw object nor sqw file. Its class is: %s', ...
            i,class(the_obj));
    end
end

[set_single,set_per_obj,n_runs_in_obj]=find_set_mode(obj_list,varargin{1});
% split input parameters according to the split algorithm
efix_split = cell(1,n_obj);
emode_split = cell(1,n_obj);
if set_single
    for i=1:n_obj
        efix_split{i} = efix;
        emode_split{i} = emode;
    end
else
    n_tot_runs =0;
    for i=1:n_obj
        if set_per_obj
            efix_split{i} = efix(i);
            if isempty(emode)
                emode_split{i} = [];
            else
                emode_split{i} = emode(i);
            end
        else
            efix_split{i} = efix(n_tot_runs+1:n_tot_runs+n_runs_in_obj(i));
            if isempty(emode)
                emode_split{i} = [];
            else
                emode_split{i} = emode(n_tot_runs+1:n_tot_runs+n_runs_in_obj(i));
            end
            n_tot_runs    = n_tot_runs + n_runs_in_obj(i);
        end
    end
end


% Perform operations
% ==================

% Change efix and emode
% ---------------------
out = cell(1,n_obj);
for i=1:n_obj
    the_obj = obj_list{i};
    if isa(the_obj,'sqw')
        exp_inf  = the_obj.experiment_info;
    else
        exp_inf   = the_obj.get_header('-all','-no_sampinst');
    end
    exp_inf   = exp_inf.set_efix_emode(efix_split{i},emode_split{i});%

    if isa(the_obj,'sqw')
        the_obj.experiment_info = exp_inf;
        out{i} = the_obj;
    else
        the_obj  = the_obj.upgrade_file_format(); % also reopens file in update mode if format is already the latest one
        the_obj.put_headers(exp_inf);
        the_obj.delete();
        out{i} = in_data{i};
    end
end
%
% format output parameters according to the output request
if nargout == 1
    varargout{1} = out;
else
    for i=1:nargout
        varargout{i} = out{i};
    end
end
