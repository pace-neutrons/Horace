function hcompare(varargin)
% Draw multiple workspaces as points and histograms
%
%   >> hcompare (w1, w2, w3, ...)

acolor k b r m g y
w=varargin{1};
for i=2:numel(varargin)
    w=[w,varargin{i}];
end
dph(w)

%------------------------------------------------------------------------------
function dph(w,varargin)
% Draw markers, error bars and histogram for a spectrum or array of spectra.
%
%   >> dph(w)
%   >> dph(w,...)   % type >> help dd for options

dp(w,varargin{:});
ph(w);
