function pix_out = binary_op_double_(obj, double_array, binary_op, flip, npix)
%% BINARY_OP_DOUBLE_ perform a binary operation between this PixelData object
% and an array
%
validate_input_array(obj, double_array, npix);

pix_out = obj;

if isempty(npix)
    base_page_size = pix_out.max_page_size_;
    while true

        pix_sigvar = sigvar(pix_out.signal, pix_out.variance);

        start_idx = (pix_out.page_number_ - 1)*base_page_size + 1;
        end_idx = min(start_idx + base_page_size - 1, obj.num_pixels);

        double_sigvar = sigvar(double_array(start_idx:end_idx), []);
        [pix_out.signal, pix_out.variance] = ...
                sigvar_binary_op_(pix_sigvar, double_sigvar, binary_op, flip);

        if pix_out.has_more()
            pix_out = pix_out.advance();
        else
            break;
        end

    end
else

    end_idx = 1;
    leftover_end = 0;
    pg_size = pix_out.max_page_size_;
    npix_cum_sum = cumsum(npix(:));
    if npix_cum_sum(end) ~= pix_out.num_pixels, error('a:b', 'c'); end

    while true

        start_idx = find(npix_cum_sum > 0, 1);

        leftover_begin = npix_cum_sum(start_idx);

        npix_cum_sum = npix_cum_sum - pg_size;

        end_idx = end_idx + find(npix_cum_sum(end_idx:end) > 0, 1) - 1;
        if isempty(end_idx)
            end_idx = numel(npix);
        end

        if start_idx == end_idx
            npix_chunk = min(pix_out.page_size, npix(start_idx) - leftover_end);
        else
            leftover_end = ...
                pix_out.page_size - (leftover_begin + sum(npix(start_idx + 1:end_idx - 1)));
            npix_chunk = npix(start_idx + 1:end_idx - 1);
            npix_chunk = [leftover_begin, npix_chunk(:).', leftover_end];
        end

        sig_chunk = replicate_array(double_array(start_idx:end_idx), npix_chunk);

        this_sigvar = sigvar(pix_out.signal, pix_out.variance);
        double_sigvar = sigvar(sig_chunk', []);
        [pix_out.signal, pix_out.variance] = ...
            sigvar_binary_op_(this_sigvar, double_sigvar, binary_op, flip);

        if pix_out.has_more()
            pix_out = pix_out.advance();
        else
            break;
        end

    end

end

end  % function


% -----------------------------------------------------------------------------
function validate_input_array(obj, double_array, npix)
    if ~isequal(size(double_array), [1, obj.num_pixels]) && isempty(npix)
        required_size = sprintf('[1, %i]', obj.num_pixels);
        actual_size = strjoin(repmat({'%i'}, 1, ndims(double_array)), ', ');
        actual_size = sprintf(['[', actual_size, ']'], size(double_array));
        error('PIXELDATA:do_binary_op', ...
              ['Cannot perform binary operation. Double array must ' ...
               'have size equal to number of pixels.\nFound size ''%s'', ' ...
               '''%s'' required.'], actual_size, required_size);
    end
end

function vout = replicate_array(v, npix)
    if numel(npix)==numel(v)
        % Get the bin index for each pixel
        nend=cumsum(npix(:));
        nbeg=nend-npix(:)+1;    % nbeg(i)=nend(i)+1 if npix(i)==0, but that's OK below
        nbin=numel(npix);
        npixtot=nend(end);
        vout=zeros(npixtot,1);
        for i=1:nbin
            vout(nbeg(i):nend(i))=v(i);     % if npix(i)=0, this assignment does nothing
        end
    else
        error('Number of elements in input array(s) incompatible')
    end
end
