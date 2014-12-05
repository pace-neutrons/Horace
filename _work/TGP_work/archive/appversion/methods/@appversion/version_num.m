function arr=version_num(w)
% Get the numeric array representation of a version
%
%   >> arr = version_num (ver)
%
% Input:
% ------
%   ver         appversion object
%
% Output:
% -------
%   arr         Array of the version indicies e.g. [3,2,13] for version 3.2.13

arr=w.version;
