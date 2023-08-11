function cleanup_handle = set_temporary_warning(state, varargin)
%% SET_WARNING set a warning state and return an onCleanup object that
% will reset the warning when it goes out of scope
%
% >> cleanup_handle = set_temporary_warning('off', 'HORACE:singularMatrix');
% Or 
% >> cleanup_handle = set_temporary_warning('off', 'HORACE:singularMatrix','HORACE:invalid_argument');
% to suppress multiple warnings
%
if nargout ~= 1
    error('TEST:set_temporary_warning', 'Function requires 1 output argument.');
end
n_warn = numel(varargin);
ws = cell(n_warn,1);
for i = 1:n_warn
    ws{i} = warning(state, varargin{i});
end
ws = [ws{:}];
cleanup_handle = onCleanup(@() warning(ws));

end
