function  obj = put_det_info(obj,varargin)
% Store information about sqw object detectors
%
% the main sqw data to take detpar from are either attached to sqw_hanle 
% or provided as input parameters
%

obj = obj.put_block_data('bl__detpar',varargin{:});