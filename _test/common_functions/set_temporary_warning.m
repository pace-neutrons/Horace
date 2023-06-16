function cleanup_handle = set_temporary_warning(state, warnID)
%% SET_WARNING set a warning state and return an onCleanup object that
% will reset the warning when it goes out of scope
%
% >> cleanup_handle = set_temporary_warning('off', 'HORACE:singularMatrix');
%
if nargout ~= 1
    error('TEST:set_temporary_warning', 'Function requires 1 output argument.');
end

ws = warning(state, warnID);
cleanup_handle = onCleanup(@() warning(ws));

end
