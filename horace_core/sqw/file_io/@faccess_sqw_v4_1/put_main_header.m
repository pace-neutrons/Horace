function obj = put_main_header(obj,varargin)
% Save or replace main sqw header into properly initialized
% binary sqw file
%Usage:
%>>obj.put_main_header();   -- store sqw obect main_header information 
%                              in sqw binary file. 
%
% Optional:                 operations are not well tested yet.
%>>obj.put_main_header('-update'); % redundant opiton not used any more
%
%>>obj = obj.put_header(sqw_obj); 
%                            -- stores header for sqw object, provided as
%                                input. 
%
% the main sqw data are either attached to sqw_hanle or provided as 
% input parameters -- not well tested yet.
%
obj = obj.put_block_data('bl__main_header',varargin{:});