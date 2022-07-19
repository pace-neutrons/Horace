function [q,en]=calculate_q_bins(win)
% Calculate qh,qk,ql,en for the centres of the bins of an n-dimensional sqw or dnd dataset
%
%   >> [q,en]=calculate_q_bins(win)
%
% Input:
% ------
%   win     Input sqw/dnd object
%
% Output:
% -------
%   q       Components of momentum (in rlu) for each bin in the dataset for a single energy bin
%           Arrays are packaged as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. q{1}=qh, q{2}=qk, q{3}=ql
%   en      Column vector of energy bin centres. If energy was an integration axis, then returns the
%           centre of the energy integration range
[q,en] = win.data.caclulate_q_bins();
