function val=horace_info_level(val_in)
% Set or retrieve level of information to be output by Horace routines
%
%   >> horace_info_level (ival)     % set level to ival
%   >> ival = horace_info_level;    % retrieve information level
%
%   ival    Integer:
%              -1   No information messages to be printed
%               0   Major information messages to be printed
%               1   Minor information messages to be printed in addition
%                       :
%           The larger the value, the more information is printed
%
%
% *** DEPRECATED FUNCTION ***
%   Please set or get the information level directly from the Horace configuration:
%       >> set(hor_config,'horace_info_level',ival);
%       >> ival = get(hor_config,'horace_info_level');


disp('*** Deprecated function: horace_info_level                                   ***')
disp('*** Please set or get the info level directly from the Horace configuration: ***')
disp('***       >> set(hor_config,''log_level'',ival)                        ***')
disp('***       >> ival = get(hor_config,''log_level'')                      ***')

if nargin>0
    try
        set(hor_config,'log_level',val_in);
    catch ME
        error(ME.message)
    end
end

if nargout>0 || nargin==0
    val = get(hor_config,'log_level');
end
