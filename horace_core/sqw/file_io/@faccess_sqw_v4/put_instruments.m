function obj = put_instruments(obj,varargin)
% Store instruments to the file
%
% the main sqw data are either attached to sqw_hanle or provided as input parameters
%
obj = obj.put_block_data('bl_experiment_info_instruments',varargin{:});