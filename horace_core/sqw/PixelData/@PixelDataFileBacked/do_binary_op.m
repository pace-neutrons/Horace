function pix_out = do_binary_op(obj, operand, binary_op, varargin)
%% DO_BINARY_OP perform a binary operation between this object and the given
%  operand
%
%  >> pix_diff = obj.do_binary_op(other_pix, @minus_single, 'flip', true)
%
%  >> pix_sum = obj.do_binary_op(signal_array, @plus_single, 'npix', npix)
%
%  >> pix_sum = obj.do_binary_op(signal_array, @plus_single, 'npix', npix, 'flip', true)
%
% Input
% -----
% operand    The second operand to use in the binary operation.
%            The operand must have one of the following types:
%              - scalar double
%              - double array, the size of the array must be equal to
%                obj.num_pixels
%              - object with fields 's' and 'e' (e.g. dnd or sigvar)
%              - another PixelData object with obj.num_pixels equal
% binary_op  Function handle pointing to the desired binary operation. The
%            function should take 2 objects with '.s' and '.e' attributes, e.g.
%            a sigvar object
%
% Named arguments
% ---------------
% flip       Flip the order of the operands, e.g. perform "this - operand" if
%            flip is false, perform "operand - this" if flip is true.
% npix       An array giving number of pixels in each bin. This argument should
%            have equal size to operand (assuming operand is numeric) and
%            sum(npix, [], 'all') must be equal to obj.num_pixels
%
[flip, npix] = parse_args(obj, operand, binary_op, varargin{:});

if nargout == 0
    pix_out = obj;
else
    %TODO: #928 If it is copy here, what is should be? Initialized
    %f-accessor should be here
    pix_out = copy(obj); % this one currently creates Memorybacked pixels in tests
    %pix_out = obj;
end

if isscalar(operand) && isa(operand, 'double')
    pix_out = binary_op_scalar_(pix_out, operand, binary_op, flip);
elseif isa(operand, 'double')
    pix_out = binary_op_double_(pix_out, operand, binary_op, flip, npix);
elseif isa(operand, 'PixelDataBase')
    pix_out = binary_op_pixels_(pix_out, operand, binary_op, flip);
elseif isa(operand, 'DnDBase') || isa(operand, 'sigvar')
    pix_out = binary_op_sigvar_(pix_out, operand, binary_op, flip, npix);
end

end  % function

% -----------------------------------------------------------------------------
function [flip, npix] = parse_args(varargin)
    parser = inputParser();
    addRequired(parser, 'obj', @(x) isa(x, 'PixelDataBase'));
    addRequired(parser, 'operand', @(x) valid_operand(x));
    addRequired(parser, 'binary_op', @(x) isa(x, 'function_handle'));
    addParameter(parser, 'flip', false, @(x) isa(x, 'logical'));
    addParameter(parser, 'npix', [], @isnumeric);
    parse(parser, varargin{:});

    flip = parser.Results.flip;
    npix = parser.Results.npix;
end


function is = valid_operand(operand)
    is = isa(operand, 'PixelDataBase') || ...
         isnumeric(operand) || ...
         ~isempty(regexp(class(operand), '^d[0-4]d$', 'ONCE')) || ...
         isa(operand, 'sigvar');
end
