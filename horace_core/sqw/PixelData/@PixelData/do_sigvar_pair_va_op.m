function pix_out = do_sigvar_pair_va_op(obj, svpair_op, varargin)
% Perform a "sigvarpair" operation on this object's signal and variance
% arrays, input separately and with additional input varargs
%
% Input:
% -----
% svpair_op   Function handle pointing to the operation to perform. This
%             operation should take a sigvar object as an argument.
% varargs     Variable final arguments according to svpair_op needs.
%
if nargout == 1
    % Only do a copy if a return argument exists, otherwise perform the
    % operation on obj
    pix_out = copy(obj);
else
    pix_out = obj;
end

pix_out.move_to_first_page();
while true
    [pg_result_s, pg_result_e] = svpair_op(pix_out.signal, pix_out.variance, varargin{:});
    pix_out.signal = pg_result_s;
    pix_out.variance = pg_result_e;

    if pix_out.has_more()
        pix_out = pix_out.advance();
    else
        break;
    end
end
