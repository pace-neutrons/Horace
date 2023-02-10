function obj = put_instruments(obj,varargin)
% Store instruments container to the binary file
%
% the main sqw data with instruments are either attached 
% to obj.sqw_holder or provided as input parameters.
%
obj = obj.put_block_data('bl_experiment_info_instruments',varargin{:});