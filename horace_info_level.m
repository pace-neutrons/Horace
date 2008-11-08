function val=horace_info_level(val_in)
% Set or retrieve level of information to be output by Horace routines
%
%   >> horace_info_level (ival)     % set level to ival
%   >> ival = horace_info_level;    % retrive information level
%
% ival      Integer:
%          -1   No information messages to be printed
%           0   Major information messages to be printed
%           1   Minor information messages to be printed in addition
%                       :
%           The larger the value, the more information is printed
%           Default: +Inf

persistent val_store

% Initialise
if isempty(val_store)
    val_store=Inf;
end

if nargin>0
    if isscalar(val_in) && isnumeric(val_in) && ~isnan(val_in)
        val_store=val_in;
    else
        warning('Information level from Horace must be numeric and not NaN. Level left unchanged')
    end
end

if nargout>0
   val=val_store;
end
