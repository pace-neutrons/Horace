function qw=calculate_qw_bins(win)
% Calculate qh,qk,ql,en for the centres of the bins of a d2d dataset
%
%   >> qw=calculate_qw_bins(win)
%
% Input:
% ------
%   win     Input d2d dataset
%
% Output:
% -------
%   qw      Components of momentum (in rlu) and energy for each bin in the dataset
%           Arrays are packaged as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. qw{1}=qh, qw{2}=qk, qw{3}=ql, qw{4}=en

% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if numel(win)~=1
    error('Only a single input dataset is valid - cannot take an array of datasets')
end
qw=calculate_qw_bins(sqw_old(win));

