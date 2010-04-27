function write_nsqw_to_sqw (varargin)
% Read a collection of sqw files with a common grid and write to a single sqw file.
% Currently the input files are restricted to have been made from a single spe file.
%
%   >> write_nsqw_to_sqw (infiles, outfile)
%
% Input:
%   infiles         Cell array or character array of file name(s) of input file(s)
%   outfile         Full name of output file
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Gateway routine that calls sqw method
if get(hdf_config,'use_hdf')
    outfile = varargin{end};
    infiles = varargin{1:end-1};
    rez=sqw_hdf(outfile,infiles);
    rez.delete()
else
    write_nsqw_to_sqw (sqw, varargin{:});
end
