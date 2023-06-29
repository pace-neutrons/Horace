function val = func_eval (obj, func_handle, varargin)
% Evaluate a function for array of detector indices and wavevector
%
%   >> X = func_eval (obj, func_handle, wvec)       % for default indices
%   >> X = func_eval (obj, func_handle, ind, wvec)  % specific indices
%
% Input:
% ------
%   obj         IX_detector_array object
%
%   func_handle Function handle e.g. effic or mean, which follows one of
%               the syntax options:
%               	val = effic (obj, wvec)
%               	val = effic (obj, ind, wvec)
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet) as a row vector.
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%               If both ind and wvec are arrays, then they must have the same
%               number of elements, but not necessarily the same shape.
%
%
% Output:
% -------
%   val         Array of output values.
%               The output is formed by stacking the output for each single
%               detector into a larger array, with the size of
%               the stacking array being whichever of ind or wvec is an
%               array.
%
%               Note:
%                 - if ind is a scalar, the calculation is performed for
%                  that value at each of the values of wvec
%                 - if wvec is a scalar, the calculation is performed for
%                  that value at each of the values of ind
%
%               If both ind and wvec are arrays, the shape is that of wvec


% Parse to get detector indices and wavevectors, and check consistency of sizes
[sz_stack, ind, wvec] = parse_ind_wvec_ (obj, varargin{:});

% Repackage ind and wvec into arguments for a call to each contributing
% IX_detector_bank
[ix, ibank, ndet_bank, ind, wvec] = repackage_ind_wvec_ (obj, ind, wvec);

% Loop over the detector banks
nbank = numel(ibank);
if nbank==1
    % Detectors came from just one bank; single function call and return
    % The call to repackage_ind_wvec above will have returned numeric
    % arrays for ind and wvec
    val = func_eval (obj.det_bank_, func_handle, ind, wvec);
    
else
    % Detectors came from two or more banks; loop over banks
    % The call to repackage_ind_wvec above will have returned a cell array
    % of column vectors for ind; wvec will be either a scalar or a cell
    % array of numeric column vectors   
    wvec_is_scalar = ~iscell(wvec);     % wvec must be a numeric scalar
    if wvec_is_scalar
        val_tmp = func_eval (obj.det_bank_(ibank(1)), func_handle, ind{1}, wvec);
    else
        val_tmp = func_eval (obj.det_bank_(ibank(1)), func_handle, ind{1}, wvec{1});
    end
    
    % Create 2D output array from size of output for a single point and
    % total number of detector/wvec pairs
    sz_root = size_array_split (size(val_tmp), [numel(ind{1}), 1]);
    nel = prod(sz_root);     % number of element of val per detector/wvec pair
    val = NaN(nel, prod(sz_stack));
    iend = cumsum(ndet_bank);
    ibeg = iend - ndet_bank + 1;
    
    % Fill output array from computations for each bank
    val(:,ibeg(1):iend(1)) = reshape(val_tmp, [nel, ndet_bank(1)]);
    for i = 2:nbank
        if wvec_is_scalar
            val{i} = func_eval (obj.det_bank_(ibank(i)), func_handle, ind{i}, wvec);
        else
            val{i} = func_eval (obj.det_bank_(ibank(i)), func_handle, ind{i}, wvec{i});
        end
        val(:,ibeg(i):iend(i)) = reshape(val_tmp, [nel, ndet_bank(1)]);
    end
    
    % Re-order and reshape to correct output size
    val(:,ix) = val;
    val = reshape (val, size_array_stack (sz_root, sz_stack));
end    
