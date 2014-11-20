function write_nsqw_to_sqw (dummy, infiles, outfile)
% Read a collection of sqw files with a common grid and write to a single sqw file.
%
%   >> write_nsqw_to_sqw (dummy, infiles, outfile)
%
%
% *** DEPRECATED FUNCTION **********************************************************
% 
% Calls to this method should be replaced by calls to combine,
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
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
%   infiles         Cell array or character array of sqw file name(s) of input file(s)
%   outfile         Full name of output sqw file
%
% Output:
% -------
%   <no output arguments>

combine (sqw, infiles, outfile);
