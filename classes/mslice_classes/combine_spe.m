function combine_spe(varargin)
% Weighted combination of spe files together. If a pixel is bad in any one of the
% spe files, it is masked as bad in the output file. 
%
%   >> mess = combine_spe(weight,spedir,spefiles,spefileout)
%
%   weight      Array of weights. The final output will not be further normalised.
%              Can be negative e.g. to take the difference between two files use
%              weights [1,-1]
%
%   spedir      Default directory containing the spe files e.g. 'c:\temp\mt_data\spe\'
%               (If argument spe file names in argument spefiles (below) contains the
%              full path, then spedir is ignored. Can set spedir='' i.e. blank string)
%
%   spefiles    Cell array of spe file names e.g. {'map01234.spe','map01299.spe'}
%               If full path is given for a file, then that overides the path in spedir
%              for that file.
%
%   spefileout  Name of spe file to contain the overall sum e.g. 'map01234_99.spe'
%               Default: place in the directory spedir if a full path is not given

% Gateway routine to spe method
if nargin>4
    error('Check number of arguments')
end
mess = combine(spe,varargin{:});
if ~isempty(mess)
    error(mess)
end
