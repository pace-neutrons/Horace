function cleanup_handle = set_temporary_warning_off(varargin)
%SET_TEMPORARY_WARNING_OFF hide warnings of the given type
%   Returns a cleanup objects that will restore Matlab's warning state when it
%   goes out of scope.
%
% Usage
% -----
%   The following hides warnings when attempting to remove a path from Matlab's
%   path that is not on the path.
%
%   >> cleanup = set_temporary_warning_off('MATLAB:rmpath:DirNotFound');
%
old_warn_state = warning;
cleanup_handle = onCleanup(@() warning(old_warn_state));

for i = 1:numel(varargin)
    warning('OFF', varargin{i});
end
