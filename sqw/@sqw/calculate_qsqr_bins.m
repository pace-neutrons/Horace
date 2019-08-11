function [qsqr,en] = calculate_qsqr_bins (win)
% Calculate |Q|^2 for the centres of the bins of an n-dimensional sqw dataset
%
%   >> qsqr = calculate_qsqr_bins (win)
%
% Input:
% ------
%   win     Input sqw object
%
% Output:
% -------
%   qsqr    |Q|^2 for each bin in the dataset for a single energy bin (column vector)
%
%   en      Column vector of energy bin centres. If energy was an integration axis,
%           then returns the centre of the energy integration range

% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)


if numel(win)~=1
    error('Only a single sqw object is valid - cannot take an array of sqw objects')
end

% Get b-matrix, B, that gives crystal Cartesian coords Vcryst(i) = B(i,j) Vrlu(j)
B = bmatrix(win.data.alatt, win.data.angdeg);
 
% Get the bin centres in hkl
[qhkl,en] = calculate_q_bins (win);

% Convert to crystal Cartesian coordinates and sum the squares
qcryst = [qhkl{1}, qhkl{2}, qhkl{3}] * B';
clear qhkl  % clear large arrays
qsqr = sum(qcryst.^2,2);
