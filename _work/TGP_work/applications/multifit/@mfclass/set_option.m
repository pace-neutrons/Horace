function obj = set_option (obj, varargin)
% Set options
%
%   >> obj = obj.set_option ('-default')        % set default values for all options
%   >> obj = obj.set_option (name, value)       % set the named option
%   >> obj = obj.set_option (name, '-default')  % set the named option to default
%
% To enquire what the available options are, type:
%
%   >> obj.get_option


opt_names ={...
    'fit_control_parameters',...
    'listing'};

opt_funcs = {...
    @set_option_fit_control_parameters,...
    @set_option_listing};

if numel(varargin)==0
    % Do nothing
    return
    
elseif numel(varargin)==1
    % Only one argument: only acceptable case is '-default'
    val_in = varargin{1};
    if ~isempty(val_in) && is_string(val_in) && strncmpi(val_in,'-default',max([2,numel(val_in)]))
        for i=1:numel(opt_names)
            options.(opt_names{i}) = opt_funcs{i}();
        end
        obj.options_ = options;
    else
        error('Unrecognised input argument')
    end
    
elseif numel(varargin)==2
    % Name-value pair
    opt_name = varargin{1};
    if ~isempty(opt_name) && is_string(opt_name)
        tf = strncmpi (opt_name, opt_names, numel(opt_name));
        if sum(tf)==1
            i = find(tf);
            val_in = varargin{2};
            if ~isempty(val_in) && is_string(val_in) && strncmpi(val_in,'-default',max([2,numel(val_in)]))
                obj.options_.(opt_names{i}) = opt_funcs{i}();
            else
                [val,ok,mess] = opt_funcs{i}(val_in);
                if ok
                    obj.options_.(opt_names{i}) = val;
                else
                    error_message(mess)
                end
            end
        else
            error('Unrecognised or ambiguous option name')
        end
    else
        error('Must give option name as first argument')
    end
    
else
    error('Check number of input arguments')
end
