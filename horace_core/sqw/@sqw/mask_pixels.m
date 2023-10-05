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
%                      pixels to retain. Random selection of pixels
%                      with wout.num_pixels == keep_info is retained as the
%                      result of the operation.
%    *OR*              Array of 1 or 0 (or true or false) that indicate
%                      which pixels to retain (true to retain, false to ignore)
%                      Numeric or logical array with the same number of
%                      elements as there are pixels in the obj.
%    *OR*
%                      sqw object in which the signal in individual pixels is
%                      interpreted as a mask array:
%                           >=1  to retain
%                            <1  to remove
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
    if obj.pix.num_pixels ~= keep_info.pix.num_pixels
        error('HORACE:sqw:invalid_argument', ...
            'Number of pixels in input and mask object must be the same')
    end
elseif (isnumeric(keep_info) || islogical(keep_info)) && ...
        numel(keep_info)~=numel(obj.data.s)
    num_keep = sum(keep_info);
    if num_keep<=0
        error('HORACE:sqw:invalid_argument', ...
            'Can not mask all pixels. Num pixels to keep should be positive number. Provided: %d', ...
            num_keep);
    elseif num_keep>obj.num_pixels
        error('HORACE:sqw:invalid_argument', ...
            'Can not keep more pixels then available. Num pixels to keep should be smaller or equal to num_pixels (%d). Provided: %d', ...
            obj.num_pixels,num_keep)
    end

    if ~isscalar(keep_info) && ~islogical(keep_info)
        keep_info=logical(keep_info);
    end
else
    error('HORACE:sqw:invalid_argument', ...
        'Mask must provide a numeric or logical array with same number of elements as the data or an SQW with the same projection and axes')
end

pix_op       = PageOp_mask();
[pix_op,obj] = pix_op.init(obj,keep_info);
wout         = obj.apply_c(pix_op);
