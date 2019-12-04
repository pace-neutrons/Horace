function [q,en]=calculate_q_bins(win)
% Calculate qh,qk,ql,en for the centres of the bins of a d0d dataset
%
%   >> [q,en]=calculate_q_bins(win)
%
% Input:
% ------
%   win     Input d0d dataset
%
% Output:
% -------
%   q       Components of momentum (in rlu) for each bin in the dataset for a single energy bin
%           Arrays are packaged as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. q{1}=qh, q{2}=qk, q{3}=ql
%   en      Column vector of energy bin centres. If energy was an integration axis, then returns the
%           centre of the energy integration range

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if numel(win)~=1
    error('Only a single input dataset is valid - cannot take an array of datasets')
end
[q,en]=calculate_q_bins(sqw(win));
