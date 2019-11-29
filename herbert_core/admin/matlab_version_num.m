function numver=matlab_version_num
% Returns numeric representation of Matlab version
%
%   >> version = matlab_version_num
%
% The version number returned is not the true Matlab version, but one which
% numerical places Matlab versions in chronological order
%
% e.g. if R2011b i.e. version 7.13:
%   >> matlab_version_num
%   ans =
%       7.1300
%
% e.g. if R2007a i.e. version 7.4:
%   >> matlab_version_num
%   ans =
%       7.0400  (i.e. not 7.4)
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%


% T.G.Perring 23/7/13: replace the following *horrendously slow* call to ver:
%    vr = ver('MATLAB');
%    vers = vr.Version;
% with:
vers=version;

vs = regexp(vers,'\.','split');
numver = str2double(vs{1})+0.01*str2double(vs{2});
