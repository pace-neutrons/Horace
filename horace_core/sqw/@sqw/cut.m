function wout = cut(obj, varargin)
%%CUT
%

if numel(obj) > 1
    error('SQW:cut', ...
          ['You cannot take a cut from an array, or cell array, of sqw or ' ...
           'dnd object.\nConsider cutting the objects in a loop.']);
end

dnd_type = obj.data.pix.num_pixels == 0;
ndims_source = numel(obj.data.pax);

if dnd_type
    % Inputs have no pixels, delegate to cut_dnd
    wout = cut_dnd_main(obj, ndims_source, varargin{:});
    return
end

return_cut = nargout > 0;
[proj, pbin, opt] = validate_args(obj, return_cut, ndims_source, varargin{:});

if return_cut
    wout = cut_single(obj, proj, pbin, opt.keep_pix, opt.outfile);
else
    cut_single(obj, proj, pbin, opt.keep_pix, opt.outfile);
end

end  % function


% -----------------------------------------------------------------------------
function [proj, pbin, opt] = validate_args(obj, return_cut, ndims_source, varargin)
    [ok, mess, ~, proj, pbin, args, opt] = cut_sqw_check_input_args( ...
        obj, ndims_source, return_cut, varargin{:} ...
    );
    if ~ok
        error ('CUT_SQW:invalid_arguments', mess)
    end

    % Ensure there are no excess input arguments
    if numel(args) ~= 0
        error ('CUT_SQW:invalid_arguments', ...
               'Check the number and type of input arguments')
    end
end
