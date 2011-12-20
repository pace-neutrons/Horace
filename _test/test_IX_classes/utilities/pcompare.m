function pcompare(varargin)
% Draw multiple workspaces as points and lines between them
%
%   >> pcompare (w1, w2, w3, ...)

acolor k b r m g y
w=varargin{1};
for i=2:numel(varargin)
    w=[w,varargin{i}];
end
dpl(w)
