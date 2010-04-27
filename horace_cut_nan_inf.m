function val=horace_cut_nan_inf(ignore_nan,ignore_inf)
% Determine whether or not to ignore NaN and/or Inf when performing cuts
%
%   >> horace_cut_nan_inf (ignore_nan,ignore_inf)     % set true or false in each case
%   >> val = horace_cut_nan_inf;    % get values: val.ignore_nan, val.ignore_inf
%
% Default is: val.ignore_nan=true, val.ignore_inf=false.

persistent val_store

% Initialise
if isempty(val_store)
    [nan,inf]=get(hor_config,'ignore_nan','ignore_inf');
    val_store=struct('nan',logical(nan),'inf',logical(inf));
end

if nargin==2
    if isscalar(ignore_nan) && ((isnumeric(ignore_nan) && ~isnan(ignore_nan))||islogical(ignore_nan))
        set(hor_config,'ignore_nan',ignore_nan)        
        val_store.nan=logical(ignore_nan);
    else
        warning('Ignore_nan must be scalar logical. Ignore status left unchanged')
    end
    if isscalar(ignore_inf) && ((isnumeric(ignore_inf) && ~isnan(ignore_inf))||islogical(ignore_inf))
        set(hor_config,'ignore_inf',ignore_inf)                
        val_store.inf=logical(ignore_inf);
    else
        warning('Ignore_inf must be scalar logical. Ignore status left unchanged')
    end
elseif nargin~=0
    warning('Incorrect number of arguments. Ignore status left unchanged')
end

if nargout>0
   val=val_store;
end
