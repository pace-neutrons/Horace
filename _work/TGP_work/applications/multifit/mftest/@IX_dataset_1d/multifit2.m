function mf_object = multifit2(varargin)
% New version of multifit_func for IX_dataset_1d objects

mf_init = mfcustom ('IX_dataset_1d',@func_eval,[],@func_eval,[]);
mf_object = mfclass(mf_init,varargin{:});
