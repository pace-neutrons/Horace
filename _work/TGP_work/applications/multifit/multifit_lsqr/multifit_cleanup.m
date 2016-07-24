function multifit_cleanup
% Cleanup multfit

% Clear persistent storage in multifit_store_state
multifit_store_state

% Clear stored calculated function values and associated stored variables
multifit_lsqr_func_eval
