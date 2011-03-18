function varargout=ixf_global_var_warning_level(varargin)
% Set warning level for global variable handling. Determines informational and error
% levels in ixf_global_vars
%
%   >> level=ixf_global_var_warning_level('get')
%   >> [level,is_none,is_info,is_warning,is_error]=ixf_global_var_warning_level('get')
%
%   >> ixf_global_var_warning_level('set',level)
%
%   level   String with value 'none', 'info', 'warning', 'error'
%   is_none,is_info,is_warning,is_error     Logical flags

% *************************
% *** PUT BACK !!!
% mlock; % for stability

% Initiate a structure to store global variable routines warning level
persistent level_store  
if isempty(level_store)
    level_store={'none',true,false,false,false};     % make empty structure
end

if nargin==0 || (nargin==1 && strcmp(varargin{1},'get'))
    varargout=level_store;
elseif nargin==2 && strcmp(varargin{1},'set')
    ind=find(strcmpi(varargin{2},{'none','info','warning','error'}),1);
    if ~isempty(ind)
        level_store={varargin{2},false,false,false,false};
        level_store{ind+1}=true;
    else
        error('Check arguments')
    end
else
    error('Check arguments')
end
