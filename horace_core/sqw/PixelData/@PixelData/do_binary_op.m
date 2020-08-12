function pix_out = do_binary_op(obj, operand, binary_op, varargin)
%% DO_BINARY_OP perform a binary operation between this object and the given
%  operand
%
%  >> pix_diff = obj.do_binary_op(other_pix, @minus_single, 'flip', true)
%
%  >> pix_sum = obj.do_binary_op(signal_array, @plus_single, 'npix', npix)
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

if isscalar(operand) && isa(operand, 'double')
    pix_out = binary_op_scalar_(obj, operand, binary_op, flip);
elseif isa(operand, 'double')
    pix_out = binary_op_double_(obj, operand, binary_op, flip);
elseif isa(operand, 'PixelData')
    pix_out = binary_op_pixels_(obj, operand, binary_op, flip);
end

end  % function

% -----------------------------------------------------------------------------
function [flip, npix] = parse_args(varargin)
    parser = inputParser();
    addRequired(parser, 'obj', @(x) isa(x, 'PixelData'));
    addRequired(parser, 'operand', @(x) isa(x, 'PixelData') || isnumeric(x));
    addRequired(parser, 'binary_op', @(x) isa(x, 'function_handle'));
    addParameter(parser, 'flip', false, @(x) isa(x, 'logical'));
    addParameter(parser, 'npix', [], @isnumeric);
    parse(parser, varargin{:});

    flip = parser.Results.flip;
    npix = parser.Results.npix;
end
