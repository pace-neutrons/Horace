function qsqr_w = calculate_qsqr_w_bins (win,optstr)
% Calculate |Q|^2 for the centres of the bins of an n-dimensional sqw dataset
%
%   >> qsqr_w = calculate_qsqr_w_bins (win)
%   >> qsqr_w = calculate_qsqr_w_bins (win,'boundaries')
%   >> qsqr_w = calculate_qsqr_w_bins (win,'edges')
%
% Input:
% ------
%   win         Input sqw object
%   
% Optional arguments:
% 'boundaries'  Return qh,qk,ql,en at verticies of bins, not centres
% 'edges'       Return qh,qk,ql,en at verticies of the hyper cuboid that
%              encloses the plot axes
%
% Output:
% -------
%   qsqr_w      |Q|^2 and energy for each bin in the dataset. Arrays are packaged
%              as cell arrays of column vectors: qsqr_w{1} is |Q|^2 and qsqr_w{2}
%              is energy
%               Note that the centre of the integration range is used in
%              the calculation of qh,qk,ql,en even with the options
%              'boundaries' or 'edges'
%               If one or both of the integration ranges is infinite, then
%              the value of the corresponding coordinate is taken as zero.


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


if numel(win)~=1
    error('Only a single sqw object is valid - cannot take an array of sqw objects')
end

% Get b-matrix, B, that gives crystal Cartesian coords Vcryst(i) = B(i,j) Vrlu(j)
B = bmatrix(win.data.alatt, win.data.angdeg);
 
% Get the bin centres in hkl
if ~exist('optstr','var')
    qhkl_w = calculate_qw_bins (win);
else
    qhkl_w = calculate_qw_bins (win,optstr);
end

% Convert to crystal Cartesian coordinates and sum the squares
qcryst = [qhkl_w{1}, qhkl_w{2}, qhkl_w{3}] * B';
qsqr_w = {sum(qcryst.^2,2), qhkl_w{4}};
