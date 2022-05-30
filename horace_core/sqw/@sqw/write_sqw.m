function cl = write_sqw(sqw_obj,filename,varargin)
% write sqw object into recent-format binary sqw file
% Input:
% sqw_obj -- proper sqw object
% filename -- file with the name to write
%
% Provided as pair for read_sqw. To have balanced operations load/save,
% read/write
cl = save(sqw_obj,filename,varargin{:});