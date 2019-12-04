function qsqr_w = calculate_qsqr_w_pixels (win)
% Calculate |Q|^2 for the centres of the bins of an n-dimensional sqw dataset
%
%   >> qsqr_w = calculate_qsqr_w_pixels (win)
%
% Input:
% ------
%   win         Input sqw object
%
% Output:
% -------
%   qsqr_w      |Q|^2 and energy for each pixel in the dataset. Arrays are packaged
%              as cell arrays of column vectors: qsqr_w{1} is |Q|^2 and qsqr_w{2}
%              is energy


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


if numel(win)~=1
    error('Only a single sqw object is valid - cannot take an array of sqw objects')
end

% Get b-matrix, B, that gives crystal Cartesian coords Vcryst(i) = B(i,j) Vrlu(j)
B = bmatrix(win.data.alatt, win.data.angdeg);
 
% Get the bin centres in hkl
qhkl_w = calculate_qw_pixels2 (win);

% Convert to crystal Cartesian coordinates and sum the squares
qcryst = [qhkl_w{1}, qhkl_w{2}, qhkl_w{3}] * B';
qsqr_w = {sum(qcryst.^2,2), qhkl_w{4}};
