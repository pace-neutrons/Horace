function S=get_all(this,opt)
% Retrieve all configurations currently in memory as a structure
%
%   >> S = get_all (config)             % retrive all current configurations
%   >> S = get_all (config,'default')   % retrive all default configurations
%
% Each field in the structure S corresponds to a configuration thatis currently
% in memory.

if nargin==1
    S=config_store(false);
elseif nargin==2 && ischar(opt) && ~isempty(opt) && size(opt,1)==1 && strncmpi(opt,'default',length(opt))
    S=config_store(true);
else
    error('Check input arguments')
end
