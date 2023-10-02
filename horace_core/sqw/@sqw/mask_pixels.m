function wout = mask_pixels (obj, keep_info)
% Remove the pixels indicated by the mask array
%
% Note: mask will be applied to the stored data array
% according as the projection axes, not the display axes.
% Thus permuting the display axes does not alter the
% effect of masking the data.
%
%   >> wout = mask_pixels (win, keep_info)    % Mask array
%
% Input:
% ------
%   win                Input sqw object
%
%
%   keep_info
%    EITHER:           single number, which specifies the number of
%                      pixels to retain. Random selection of 
%    *OR*              Array of 1 or 0 (or true or false) that indicate
%                      which pixels to retain (true to retain, false to ignore)
%                      Numeric or logical array of same number of pixels
%                      as the data.
%    *OR*
%                      sqw object in which the signal in individual pixels is
%                      interpreted as a mask array:
%                           =1 (or true)  to retain
%                           =0 (or false) to remove
%                      the sqw object must have the same number of pixels
%                      as the object to be masked.
%
% Output:
% -------
%   wout                Output dataset.

% Original author: T.G.Perring

% Check object to be masked is an sqw-type object
if ~has_pixels(obj)
    error('HORACE:sqw:invalid_argument', ...
        'Can mask pixels only in an sqw-type object')
end


% Trivial case of empty or no mask arguments
if ~exist('keep_info', 'var') || isempty(keep_info)
    return
end



if isa(keep_info, 'SQWDnDBase')
    if ~has_pixels(keep_info)
        error('HORACE:sqw:invalid_argument', ...
            'If the mask object is a Horace object if must be sqw-type i.e. contain pixel information')
    end

    if ~isequal(obj.pix.num_pixels, keep_info.pix.num_pixels)
        error('HORACE:sqw:invalid_argument', ...
            'Number of pixels in input and mask object must be the same')
    end

elseif (isnumeric(keep_info) || islogical(keep_info)) && ...
        numel(keep_info)~=numel(obj.data.s)

    if ~islogical(keep_info)
        if isscalar(keep_info)
            if keep_info<0
                    error('HORACE:sqw:invalid_argument', ...
                        'Can not mask all pixels. Num pixels to ')
            elseif keep_info>obj.pix.num_pixels
            end
        else
            keep_info=logical(keep_info);
        end
    end
else
    error('HORACE:sqw:invalid_argument', ...
        'Mask must provide a numeric or logical array with same number of elements as the data or an SQW with the same projection and axes')
end

pix_op       = PageOp_mask();
[pix_op,obj] = pix_op.init(obj,keep_info);
wout    = obj.apply_c(pix_op);


% % Section the pix array, if sqw type, and update pix_range and img_range(s)
% % (linear) bin number for each pixel
% ibin = replicate_array(1:prod(sz), obj.data.npix);
% npix = accumarray(ibin(keep_info), ones(1, sum(keep_info)), [prod(sz), 1]);
%
% wout.data.npix = reshape(npix, sz);
%
% wout = wout.get_new_handle();
% wout.pix = wout.pix.mask(keep_info);
%
% wout = recompute_bin_data(wout);
%
% end
