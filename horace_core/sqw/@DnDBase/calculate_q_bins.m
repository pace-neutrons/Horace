function [q,en]=calculate_q_bins(win)
% Calculate qh,qk,ql,en for the centres of the bins of an n-dimensional sqw or dnd dataset
%
%   >> [q,en]=calculate_q_bins(win)
%
% Input:
% ------
%   win     Input dnd object
%
% Output:
% -------
%   q       Components of momentum (in rlu) for each bin in the dataset for a single energy bin
%           Arrays are packaged as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. q{1}=qh, q{2}=qk, q{3}=ql
%   en      Column vector of energy bin centres. If energy was an integration axis, then returns the
%           centre of the energy integration range

if numel(win)~=1
    error('HORACE:DnDBase:invalid_argument', ...
        'Only a single object is valid - cannot take an array of %s objects', ...
        class(win))
end
[nodes,en] = win.axes.get_bin_nodes('-3D','-bin_centre');
proj = win.proj;
q = proj.transform_img_to_hkl(nodes);
q = {q(1,:)',q(2,:)',q(3,:)'};
