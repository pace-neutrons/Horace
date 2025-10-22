function obj = put_samples(obj,varargin)
% Store samples info to the binary datafiles
%
% the main sqw data are either attached to sqw_hanle or provided as input parameters
%
obj = obj.put_block_data('bl_experiment_info_samples',varargin{:});