function multifit_cleanup (init_func)
% Cleanup multfit

% Clear persistent storage in multifit_store_state
multifit_store_state

% Clear stored calculated function values and associated stored variables
multifit_lsqr_func_eval

% Clear any persistent storage in the initialisation function:
if ~isempty(init_func)
    init_func();
    disp('Cleaning up initialisation function')
end
