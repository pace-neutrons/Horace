function obj = set_options (obj, varargin)
% Set options:
%
%   >> obj = obj.set_options ('-default')       % set default values for all options
%   >> obj = obj.set_options (name, value)      % set the named option
%   >> obj = obj.set_options (name, '-default') % set the named option to default
%   >> obj = obj.set_options (name1, value1, name2, value2,...)       
%                                               % set the named options ('-default'
%                                               % is a valid value for any name)
%
% Available options are:
%
%   fit_control_parameters  Vector of values: [dp, max_iter, tol]
%               dp          Relative change in parameter value for calculation
%                          of numerical derivative [default: 10^-4]
%                           - if dp > 0    calculate as (f(p+h)-f(p))/h
%                           - if dp < 0    calculate as (f(p+h)-f(p-h))/(2h)
%                          where h = abs(p*dp)
%               max_iter    Maximum number of iterations [Default: 20]
%               tol         Convergence criterion: convergence to the minimum
%                          is deemed to have occured if chi-squared improves
%                          by less than:
%                             relative quantity: tol (tol>0)
%                           - absolute quantity: tol (tol<0)
%                          [Default: 10^-3]
%
%   listing     Verbosity of output listing to screen:
%                =0 for no printing to command window 
%                =1 prints iteration summary to command window 
%                =2 additionally prints parameter values at each iteration 
%                =3 additionally lists which datasets were computed for the
%                   foreground and background functions. Diagnostic tool.
%
%   selected    If true, then return the calculated data values
%              for a simulation or the result of a fit only at unmasked
%              data points and that would be retained for fitting (i.e. 
%              exclude points with zero errors)
%               If false, calculate at all data points
%              [Default: true]
%
%   squeeze_xye If the selected option is set to true, then in the case of
%              x-y-e data only (i.e. non-object data only) return the
%              calculated data values:
%               If true: delete all data points that are masked or removed
%              from fitting
%               If false: set the value of such data poiints to NaN and the
%              errors to 0
%              [Default: false]


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)


%--------------------------------------------------------------------------
% Add options and their set functions here
opt_names ={...
    'fit_control_parameters',...
    'listing',...
    'selected',...
    'squeeze_xye'};

opt_funcs = {...
    @set_option_fit_control_parameters,...
    @set_option_listing,...
    @set_option_selected,...
    @set_option_squeeze_xye};

%--------------------------------------------------------------------------
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
    
elseif rem(numel(varargin),2)==0
    % Name-value pairs
    for k=1:numel(varargin)/2
        opt_name = varargin{2*k-1};
        if ~isempty(opt_name) && is_string(opt_name)
            tf = strncmpi (opt_name, opt_names, numel(opt_name));
            if sum(tf)==1
                i = find(tf);
                val_in = varargin{2*k};
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
    end
    
else
    error('Check number and type of input arguments')
end
