function config=get_all(this,opt)
% Retrieve all configurations currently in memory
%
%   >> config = get_all (config)             % retrive current configurations
%   >> config = get_all (config,'default')   % retrive default configurations
%
% Each field in the structure corresponds to a configuration thatis currently
% in memory.
%
% $Revision$ ($Date$)
%


if nargin==1
    config=config_store(false);
elseif nargin==2 && ischar(opt) && ~isempty(opt) && size(opt,1)==1 && strncmpi(opt,'default',length(opt))
    config=config_store(true);
else
    error('Check input arguments')
end
