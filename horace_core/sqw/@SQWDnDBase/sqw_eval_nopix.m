function obj = sqw_eval_nopix(obj, sqwfunc, all_bins, pars)
% SQW_EVAL_NOPIX
%
% Helper function for sqw eval executed on a pixel-less object (i.e. DnD or SQW with no pixels
% Called by `sqw_eval_` defined in sqw/DnDBase
%
% Input:
% ------
%   obj        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc     Handle to function that calculates S(Q,w)
%   all_bins    Boolean flag wither to apply function to all bins or only those contaiing data
%   pars       Arguments needed by the function.
%
%=================================================================
for i=1:numel(obj)
    obj(i).data = obj(i).data.sqw_eval_nopix(sqwfunc, all_bins, pars);
end

