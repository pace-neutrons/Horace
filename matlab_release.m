function release=matlab_release
% Returns Matlab release
%
%   >> release = matlab_release
%
% e.g. if R2011b i.e. version 7.13:
%   >> matlab_release
%   ans =
%   R2011b

tmp=regexp(version ,'(\w*','match');
release=tmp{1}(2:end);
