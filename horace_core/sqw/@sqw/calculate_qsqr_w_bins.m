function qsqr_w = calculate_qsqr_w_bins (win,varargin)
% Calculate |Q|^2 for the centres of the bins of an n-dimensional sqw dataset
%
%   >> qsqr_w = calculate_qsqr_w_bins (win)
%   >> qsqr_w = calculate_qsqr_w_bins (win,'-boundaries')
%   >> qsqr_w = calculate_qsqr_w_bins (win,'-edges')
%
% Input:
% ------
%   win         Input sqw object
%
% Optional arguments:
% '-boundaries'  Return qh,qk,ql,en at vertices of bins, not centres
% '-edges'       Return qh,qk,ql,en at vertices of the hyper cuboid that
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

if numel(win)~=1
    error('HORACE:sqw:invalid_argument', ...
        'Only a single sqw can be input for this function - cannot take an array of sqw objects')
end

% Get b-matrix, B, that gives crystal Cartesian coords Vcryst(i) = B(i,j) Vrlu(j)
B = bmatrix(win.data.alatt, win.data.angdeg);

% Get the bin centres in hkl
qhkl_w = win.calculate_qw_bins (varargin{:});

% Convert to crystal Cartesian coordinates and sum the squares
qcryst = [qhkl_w{1}, qhkl_w{2}, qhkl_w{3}] * B';
qsqr_w = {sum(qcryst.^2,2), qhkl_w{4}};

