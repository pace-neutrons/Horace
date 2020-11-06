function wout = combine_dnd_same_bins (varargin)
% Combine dnd objects that are assumed to have the same size s,e,npix arrays
% Only s,e,npix are altered; all the other properties come from the first
% object in the input argument list.
%
% Correctly weights the signal by the number of pixels, but cannot account
% for duplicated pixels.
%
%   >> wout = combine_dnd_same_bins (w1,w2,w3...)

wout = varargin{1};
% Trivial case of just one input argument
if numel(varargin)==1
    return
end

% More than one dnd object
% ------------------------
s = varargin{1}.npix .* wout.s;
e = (varargin{1}.npix.^2) .* wout.e;
npix = wout.npix;
for i=2:numel(varargin)
    s = s + varargin{i}.npix .* varargin{i}.s;
    e = e + (varargin{i}.npix.^2) .* varargin{i}.e;
    npix = npix + varargin{i}.npix;
end
s = s./npix;
e = e./(npix.^2);
empty = (npix==0);
s(empty) = 0;
e(empty) = 0;

wout.s = s;
wout.e = e;
wout.npix = npix;
