function add_spe(varargin)
% Adds normalised spe files together, ignoring bad pixels and normalising the final output
% 
%   >> mess = add_spe(weight,spedir,spefiles,spefileout)
%   >> mess = add_spe(weight,spedir,spefiles,spefileout,scale)
%
%   weight      Array of relative weights e.g. [1000,1500] (proton current in uAhrs);
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
%
%   scale       [Optional] Overall scaling factor by which to multiply the resulting data file
%               Default: unity

% Gateway routine to spe method
if nargin>5
    error('Check number of arguments')
end
mess = add(spe,varargin{:});
if ~isempty(mess)
    error(mess)
end
