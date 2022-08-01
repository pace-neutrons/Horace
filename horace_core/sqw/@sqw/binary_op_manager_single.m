function wout = binary_op_manager_single(w1, w2, binary_op)
% Implements a binary operation for objects with a signal and a variance array.
%
% Generic method, generalised for sqw objects, that requires:
%   (1) have methods to set, get and find size of signal and variance arrays:
%           >> sz = sigvar_size(obj)
%           >> w = sigvar(obj)          % w is sigvar object (has fields w.s, w.e)
%           >> obj = sigvar_set(obj,w)  % w is sigvar object
%   (2) have dimensions method that gives the dimensionality of the double array
%           >> nd = dimensions(obj)

if ~is_allowed_type(w1) || ~is_allowed_type(w2)
    error('SQW:binary_op_manager_single', ...
          ['Cannot perform binary operation between types ' ...
           '''%s'' and ''%s''.'], class(w1), class(w2));
end

if ~isa(w1, 'double') && ~isa(w2, 'double')

    if isa(w1, 'sqw') && has_pixels(w1) && isa(w2, 'sqw') && has_pixels(w2)
        % Both inputs SQW objects with pixels
        wout = do_binary_op_sqw_sqw(w1, w2, binary_op);

    elseif isa(w1, 'sqw') && has_pixels(w1)
        % w1 is sqw-type (with pixels), but w2 could be anything that is not
        % a double e.g. sqw object with no pixels, a d2d object, or sigvar object etc.
        wout = do_binary_op_sqw_and_non_double(w1, w2, binary_op);

    elseif isa(w2, 'sqw') && has_pixels(w2)
        % w2 is sqw-type (with pixels), but w2 could be anything that is not
        % a double e.g. sqw object with no pixels, a d2d object, or sigvar object etc.
        wout = do_binary_op_sqw_and_non_double(w2, w1, binary_op, true);

    elseif isa(w1, 'sqw') &&  isa(w2, 'sqw')
        % Both inputs are SQW objects with NO pixels
        error('SQW:binary_op_manager_single', ...
              ['Cannot perform binary operation between two SQW objects containing no PixelData']);
    end

elseif isa(w2, 'double')

    if has_pixels(w1)
        % first input is an sqw object and second input is a double
        wout = do_binary_op_sqw_double(w1, w2, binary_op);

    else
        % w2 is an sqw object that contains no pixel data and w1 is a double
        if isscalar(w2) || isequal(size(w1.s), size(w2))
            wout = w1;
            result = binary_op(sigvar(w1), sigvar(w2, []));
            wout = sigvar_set(wout, result);
        else
            error('SQW:binary_op_manager_single', ...
                  ['Check that the numeric variable is scalar or array ' ...
                   'with same size as object signal']);
        end
    end

elseif isa(w1, 'double')

    if has_pixels(w2)
        % w1 input is a double and w2 is an sqw object
        wout = do_binary_op_sqw_double(w2, w1, binary_op, true);

    else
        % w1 is a double and w2 is an sqw object that contains no pixel data
        if isscalar(w1) || isequal(size(w2.s), size(w1))
            wout = w2;
            result = binary_op(sigvar(w1, []), sigvar(w2));
            wout = sigvar_set(wout, result);
        else
            error('SQW:binary_op_manager_single', ...
                  ['Check that the numeric variable is scalar or array '
                   'with same size as object signal']);
        end
    end
end

end

% =============================================================================
% Helpers
% =============================================================================
function allowed = is_allowed_type(obj)
    allowed_types = {'double', 'SQWDnDBase', 'sigvar'};
    allowed = any(cellfun(@(t) isa(obj, t), allowed_types));
end


function wout = do_binary_op_sqw_double(w1, w2, binary_op, flip)
    % Perform a binary operation between an SQW object and a double scalar or
    % array, returning the resulting SQW object
    %
    % Input
    % -----
    % w1    An SQW object
    % w2    A double scalar or array of doubles
    % binary_op Function handle of binary operation to execute
    % flip  Flip the order of the operands: (default = false)
    %       if flip = false calculate (w1 .op. w2) e.g. sqw - double
    %       if flip = true, calculate (w2 .op. w1) e.g. double - sqw
    %
    % Return
    % ------
    % wout  An SQW object
    if isscalar(w2) || isequal(size(w1.data.npix), size(w2))
        flip = exist('flip', 'var') && flip;
        wout = copy(w1);
        if ~isscalar(w2)
            wout.data.pix = wout.data.pix.do_binary_op(...
                w2, binary_op, 'flip', flip, 'npix', w1.data.npix);
        else
            wout.data.pix = wout.data.pix.do_binary_op(...
                w2, binary_op, 'flip', flip);
        end

        wout = recompute_bin_data(wout);
    else
        error('SQW:binary_op_manager_single', ...
              ['Check that the numeric variable is scalar or array with ' ...
               'same size as object signal']);
    end
end

function wout = do_binary_op_sqw_sqw(w1, w2, binary_op, flip)
    % Perform a binary operation between two SQW objects, returning the
    % resulting SQW object
    %
    % Input
    % -----
    % w1    An SQW object
    % w2    An SQW object
    % binary_op Function handle of binary operation to execute
    % flip  Flip the order of the operands: (default = false)
    %       if flip = false calculate (w1 .op. w2)
    %       if flip = true, calculate (w2 .op. w1)
    %
    % Return
    % ------
    % wout  An SQW object
    flip = exist('flip', 'var') && flip;

    [n1, sz1] = dimensions(w1);
    [n2, sz2] = dimensions(w2);

    if n1 == n2 && all(sz1 == sz2)
        if any(w1.data.npix(:) ~= w2.data.npix(:))
            throw_npix_mismatch_error(w1, w2);
        end

        wout = copy(w1);
        wout.pix = w1.pix.do_binary_op(w2.pix, binary_op, 'flip', flip);
        wout = recompute_bin_data(wout);
    else
        error('SQW:binary_op_manager_single', ...
              ['sqw type objects must have commensurate array dimensions ' ...
               'for binary operations']);
    end
end

function wout = do_binary_op_sqw_and_non_double(w1, w2, binary_op, flip)
    % Perform a binary operation between an SQW object and another object that
    % is not a double.
    %
    % Input
    % -----
    % w1    An SQW object
    % w2    An instance of DnD or sigvar or no-pixel SQW object
    % binary_op Function handle of binary operation to execute
    % flip  Flip the order of the operands: (default = false)
    %       if flip = false calculate (w1 .op. w2) e.g. sqw - non-sqw
    %       if flip = true, calculate (w2 .op. w1) e.g. non-sqw - sqw
    %
    % Return
    % ------
    % wout  An SQW object
    w2_size = sigvar_size(w2);
    if isequal([1, 1], w2_size) || isequal(size(w1.data.npix), w2_size)
        wout = w1;
        flip = exist('flip', 'var') && flip;


        if isa(w2, 'SQWDnDBase') 
            % Need to remove bins with npix=0 in the object for the
            % binary operation
            if isa(w2, 'DnDBase')
                omit = logical(w2.npix);
                % cast the DnD object to a sigvar for processing
                operand = w2.sigvar();
            elseif isa(w2, 'sqw') && ~has_pixels(w2) % pixel-less SQW
                omit = logical(w2.data.npix);
                operand = w2;
            end
            wout = mask(wout, omit);
        else % sigvar
            operand = w2;
        end
        
        wout.pix = wout.pix.do_binary_op( ...
            operand, binary_op, 'flip', flip, 'npix', wout.data.npix);
        wout = recompute_bin_data(wout);
    else
        error('SQW:binary_op_manager_single', ...
                ['Check that the numeric variable is scalar or array ' ...
                'with same size as object signal']);
    end
end

function throw_npix_mismatch_error(w1, w2)
    % Throw an error caused by by an npix data mismatch between the two input
    % sqw objects. npix for both sqw objects must be equal
    npix1 = sum(w1.data.npix(:));
    npix2 = sum(w2.data.npix(:));
    nelmts = numel(w2.data.npix);
    idiff = find(w1.data.npix(:) ~= w2.data.npix(:));
    ndiff = numel(idiff);

    % number of elements to be printed if the data are different
    ndiff_to_print = 3;
    disp('ERROR in binary operations:')
    disp(['  sqw type objects have ', num2str(nelmts), ...
          ' bins and ', num2str(ndiff), ...
          ' of them have a different number of pixels'])
    for i = 1:min(ndiff, ndiff_to_print)
        disp(['  Element of npix with index ', num2str(idiff(i)), ...
              ' for left operand equals: ', ...
              num2str(w1.data.npix(idiff(i))), ...
              ' and for right operand: ', ...
              num2str(w2.data.npix(idiff(i)))]);
    end

    if ndiff > ndiff_to_print
        disp(['  ...and ', num2str(ndiff - ndiff_to_print), ' others']);
    end

    disp(['  Total number of pixels in left operand is ', ...
          num2str(npix1), ' and in right operand is ', num2str(npix2)])
    error('SQW:binary_op_manager_single', ...
          'The two SQW objects have different npix arrays.')
end
