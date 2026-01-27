function  obj = put_det_info(obj,varargin)
% Store information about sqw object detectors
%
% the main sqw data to take detpar from are either attached to
% sqw object contained in obj.sqw_holder property or provided 
% as first input parameter
%
%

obj = obj.put_block_data('bl__detpar',varargin{:});