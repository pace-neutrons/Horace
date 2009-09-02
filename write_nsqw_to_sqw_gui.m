function write_nsqw_to_sqw_gui (varargin)
% Read a collection of sqw files with a common grid and write to a single sqw file.
% Currently the input files are restricted to have been made from a single spe file.
%
%   >> write_nsqw_to_sqw_gui (infiles, outfile,handles)
%
% Input:
%   infiles         Cell array or character array of file name(s) of input file(s)
%   outfile         Full name of output file
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Gateway routine that calls sqw method
write_nsqw_to_sqw_gui (sqw, varargin{:});
