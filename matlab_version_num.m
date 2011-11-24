function version=matlab_version_num
% Returns numeric representation of Matlab version
%
%   >> version = matlab_version_num
%
% e.g.
%   >> matlab_version_num
%   ans =
%       7.1300

vr = ver('MATLAB');
vers = vr.Version;
vs = regexp(vers,'\.','split');
version = str2double(vs{1})+0.01*str2double(vs{2});
