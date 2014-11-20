function write_nsqw_to_sqw (varargin)
% Read a collection of sqw files with a common grid and write to a single sqw file.
%
%   >> write_nsqw_to_sqw (infiles, outfile)
%
%
% *** DEPRECATED FUNCTION **********************************************************
% 
% Calls to this function should be replaced by calls to combine_sqw,
% which will take the same input arguments. It is a more general function
% that will combine a mixture of files aand object.
%
% For more details, type:
%   >> help combine_sqw
%
%
% **********************************************************************************
%
% Input:
% ------
%   infiles         Cell array or character array of file name(s) of input file(s)
%   outfile         Full name of output file
%
% Output:
% -------
%   <no output arguments>


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


disp('*** DEPRECATED FUNCTION:  Please replace this call to  write_spe_to_sqw  with one to  combine_sqw ***')

% Gateway routine that calls sqw method
combine (sqw, varargin{:});
