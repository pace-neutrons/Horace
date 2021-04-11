function wout = binary_op_manager_single(w1, w2, binary_op)
% Implement binary operator for objects with a signal and a variance array.
%
% Generic method, generalised for sqw objects, that requires:
%   (1) have methods to set, get and find size of signal and variance arrays:
%           >> sz = sigvar_size(obj)
%           >> w = sigvar(obj)          % w is sigvar object (has fields w.s, w.e)
%           >> obj = sigvar_set(obj,w)  % w is sigvar object
%   (2) have dimensions method that gives the dimensionality of the double array
%           >> nd = dimensions(obj)
%   (3) have private function that returns class name
%           >> name = classname     % no argument - gets called by its association
%                                     with the class
%
allowed_types = {'double', 'd0d', 'd1d', 'd2d', 'd3d', 'd4d', 'sqw', 'sigvar'};
if ~ismember(class(w1), allowed_types) || ~ismember(class(w2), allowed_types)
    error('SQW:binary_op_manager_single', ...
          ['Cannot perform binary operation between types ' ...
           '''%s'' and ''%s''.'], class(w1), class(w2));
end

if ~isa(w1, 'double') && ~isa(w2, 'double')

    if isa(w1, 'sqw') && isa(w2, 'sqw')
        % Both inputs SQW objects
        wout = do_binary_op_sqw_sqw(w1, w2, binary_op);

    elseif (isa(w1, classname) && is_sqw_type(w1))
        % w1 is sqw-type, but w2 could be anything that is not a double e.g.
        % dnd-type sqw object, or a d2d object, or sigvar object etc.
        wout = do_binary_op_sqw_and_non_double(w1, w2, binary_op);

    elseif (isa(w2, classname) && is_sqw_type(w2))
        % w2 is sqw-type, but w1 could be anything that is not a double e.g.
        % dnd-type sqw object, or a d2d object, or sigvar object etc.
        wout = do_binary_op_sqw_and_non_double(w2, w1, binary_op, true);
    end

elseif isa(w2, 'double')

    if is_sqw_type(w1)
        % first input is an sqw object and second input is a double
        wout = do_binary_op_sqw_double(w1, w2, binary_op);

    else
        % w2 is an sqw object that contains no pixel data and w1 is a double
        if isscalar(w2) || isequal(size(w1.s), size(w2))
            wout = w1;
            result = binary_op(sigvar(w1), w2);
            wout = sigvar_set(wout, result);
        else
            error('SQW:binary_op_manager_single', ...
                  ['Check that the numeric variable is scalar or array ' ...
                   'with same size as object signal']);
        end
    end

elseif isa(w1, 'double')

    if is_sqw_type(w2)
        % w1 input is a double and w2 is an sqw object
        wout = do_binary_op_sqw_double(w2, w1, binary_op, true);

    else
        % w1 is a double and w2 is an sqw object that contains no pixel data
        if isscalar(w1) || isequal(size(w2.s), size(w1))
            wout = w2;
            result = binary_op(w1, sigvar(w2));
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
function wout = do_binary_op_sqw_double(w1, w2, binary_op, flip)
    % Perform a binary operation between an SQW object and a double scalar or
    % array, returning the resulting SQW object
    %
    % Input
    % -----
    % w1    An SQW object
    % w2    A double scalar or array of doubles
    % flip  Flip the order of the operands e.g. if flip = false do sqw - double
    %       if flip = true, do double - sqw (default = false)
    %
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
    flip = exist('flip', 'var') && flip;

    [n1, sz1] = dimensions(w1);
    [n2, sz2] = dimensions(w2);

    if n1 == n2 && all(sz1 == sz2)
        if any(w1.data.npix(:) ~= w2.data.npix(:))
            throw_npix_mismatch_error(w1, w2);
        end

        wout = copy(w1);
        wout.data.pix = w1.data.pix.do_binary_op(w2.data.pix, binary_op, 'flip', flip);
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
    % w2    An instance of dnd or sigvar
    %
    % Return
    % ------
    % wout  An SQW object
    %
    sz = sigvar_size(w2);
    if isequal([1, 1], sz) || isequal(size(w1.data.npix), sz)
        wout = w1;
        % Need to remove bins with npix=0 in the non-sqw object in the
        % binary operation
        if isa(w2, classname) || isa(w2, 'd0d') || isa(w2, 'd1d') || ...
                isa(w2, 'd2d') || isa(w2, 'd3d') || isa(w2, 'd4d')
            if isa(w2, classname)% must be a dnd-type sqw object
                omit = logical(w2.data.npix);
            else % must be a d0d,d1d...
                omit = logical(w2.npix);
            end
            wout = mask(wout, omit);
        end

        flip = exist('flip', 'var') && flip;
        wout.data.pix = wout.data.pix.do_binary_op(w2, binary_op, 'flip', flip, ...
                                                  'npix', wout.data.npix);
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
