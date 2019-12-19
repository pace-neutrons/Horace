function val=horace_cut_nan_inf(ignore_nan,ignore_inf)
% Determine whether or not to ignore NaN and/or Inf when performing cuts
%
%   >> horace_cut_nan_inf (ignore_nan,ignore_inf)   % set true or false in each case
%   >> val = horace_cut_nan_inf;                    % get values: val.ignore_nan, val.ignore_inf
%
% Good default choices are:
%   ignore_nan = true
%   ignore_inf = false
%
% *** DEPRECATED FUNCTION ***
%   Please set or get the information level directly from the Horace configuration:
%       >> set(hor_config,'ignore_nan',ignore_nan,'ignore_inf',ignore_inf);
%       >> [val.ignore_nan,val.ignore_inf]=get(hor_config,'ignore_nan','ignore_inf');


disp('*** Deprecated function: horace_cut_nan_inf                                  ***')
disp('*** Please set or get the info level directly from the Horace configuration: ***')
disp('*** >> set(hor_config,''ignore_nan'',ignore_nan,''ignore_inf'',ignore_inf)       ***')
disp('*** >> [val.ignore_nan,val.ignore_inf]=get(hor_config,''ignore_nan'',''ignore_inf'')')

if nargin==2
    try
        set(hor_config,'ignore_nan',ignore_nan,'ignore_inf',ignore_inf);
    catch ME
        error(ME.message)
    end
elseif nargin~=0
    error('Incorrect number of arguments')
end

if nargout>0 || nargin==0
    [val.ignore_nan,val.ignore_inf]=get(hor_config,'ignore_nan','ignore_inf');
end
