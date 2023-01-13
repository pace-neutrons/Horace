function obj = put_main_header(obj,varargin)
% Store main header data to the file
%
% the main sqw data are either attached to sqw_hanle or provided as input parameters
%
obj = obj.put_block_data('bl__main_header',varargin{:});