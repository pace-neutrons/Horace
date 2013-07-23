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

%------------------------------------------------------------------------------
function dpl(w,varargin)
% Draws a plot of markers, error bars and lines for a spectrum or array of spectra. Same as dd.
%
%   >> dpl(w)
%   >> dpl(w,...)   % type >> help dd for options

dd(w,varargin{:});
