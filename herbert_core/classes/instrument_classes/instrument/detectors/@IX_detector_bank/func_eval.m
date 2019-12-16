function val = func_eval (obj, func_handle, argnam, varargin)
% Evaluate method of a detector bank on an array of detector banks
%
% For all detectors in all banks:
%   >> val = func (obj, func_handle, argnam, arg1, arg2, ...)
%
% For indicated detectors:
%   >> val = func (obj, func_handle, argnam, ind, arg1, arg2, ...)
%
%
% The syntax of the methods to be evaluated is:
%   >> val = func (<IX_detector_bank object>, arg1, arg2,...)      % all detectors
%   >> val = func (<IX_detector_bank object>, ind, arg1, arg2,...)
%
%
% Input:
% ------
%   obj         Array of IX_detector_bank objects
%
%   func_handle Handle to a method of IX_detector_bank which is to evaluated
%
%   argnam      Character string or cell array of strings of the names of
%               numerical arguments that are expected other than 'ind' below
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1 to sum of ndet for each bank)
%
%   arg1,arg2.. Numerical parameters whose names were given in 'argnam'.
%               Each argument must be a scalar or an array, with all arrays
%               having the same number of elements, including 'ind'.
%
% Output:
% -------
%   val         Efficiency (in range 0 to 1)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


try
    nel = arrayfun(@(x)(x.ndet),obj);
    [sz, ix, ibank, ind, args] = parse_ind_args (nel, argnam, varargin{:});
    
    nbank = numel(ibank);
    if nbank>1
        val_cell = cell(1,nbank);
        for i=1:nbank
            args_bank = extract_args (args,i);
            val_cell{i} = func_handle (obj(ibank(i)), ind{i}, args_bank{:});
            if i==1
                sz_data = get_size_data (val_cell{1}, numel(ind{1}));
            end
            val_cell{i} = reshape(val_cell{i}, prod(sz_data), numel(ind{i}));
        end
        val = cell2mat (val_cell);  % 2D array size [nval_per_point, npnts]
    else
        val = func_handle (obj(ibank), ind, args{:});
        sz_data = get_size_data (val, numel(ind));
        val = reshape(val, prod(sz_data), numel(ind));
    end
    
    % Reorder and then resize the output array
    val = val(:,ix);
    if prod(sz_data)==1     % scalar data per detector
        val = reshape(val, sz);
    else
        val = reshape(val,[sz_data,sz]);
        val = squeeze(val);
    end
    
catch ME
    ME.throwAsCaller()
end

%--------------------------------------------------------------------------
function args_single = extract_args (args,i)
% Given a cell array containing a list of arguments, pick out element ind
% of any cell array arguments. The other arguments are returned in full.

narg = numel(args);
args_single = cell(1,narg);
if narg>0
    cellarg = cellfun(@iscell,args);
    args_single(cellarg) = cellfun(@(x)(x{i}), args(cellarg), 'uniformOutput', false);
    args_single(~cellarg)= args(~cellarg);
end

