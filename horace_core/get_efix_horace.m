function varargout=get_efix_horace(varargin)
% Return the mean fixed neutron energy and emode in a file or set of files containing Horace data
%
%   >> [efix,emode,ok,mess,en] = get_efix_horace(file)
%   >> [efix,emode,ok,mess,en] = get_efix_horace(file,tol)
%
% Input:
% ------
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
%   tol         [Optional] acceptable relative spread w.r.t. average:
%                   max(|max(efix)-efix_ave|,|min(efix)-efix_ave|) <= tol*efix_ave
%
% Output:
% -------
%   efix        Fixed neutron energy (meV) (=NaN if not all data sets have the same emode)
%   emode       Value of emode (1,2 for direct, indirect inelastic; =0 elastic)
%              All efix must have the same emode. (emode returned as NaN if not the case)
%   ok          Logical flag: =true if within tolerance, otherwise =false;
%   mess        Error message; empty if OK, non-empty otherwise
%   en          Structure with various information about the spread
%                   en.efix     array of all efix values, as read from sqw objects
%                   en.emode    array of all emode values, as read from sqw objects
%                   en.ave      average efix (same as output argument efix)
%                   en.min      minimum efix
%                   en.max      maximum efix
%                   en.relerr   larger of (max(efix)-efix_ave)/efix_ave
%                               and abs((min(efix)-efix_ave))/efix_ave
%                 (If emode not the same for all data sets, ave,min,max,relerr all==NaN)


% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)


if nargin<1 ||nargin>2
    error('Check number of input arguments')
elseif nargout>5
    error('Check the number of output arguments')
end

[varargout,mess] = horace_function_call_method (nargout, @get_efix, '$hor', varargin{:});
if ~isempty(mess), error(mess), end

