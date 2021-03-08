function abs_pix_indices = logical_to_normal_index_(obj, logical_indices)
%ABS_PIX_INDICES Convert the given logical indices to normal indices
%
if numel(logical_indices) > obj.num_pixels
    if any(logical_indices(obj.num_pixels + 1:end))
        error( ...
            'HORACE:PIXELDATA:badsubscript', ...
            ['The logical indices contain a true value ' ...
                'outside of the array bounds.'] ...
        );
    else
        logical_indices = logical_indices(1:obj.num_pixels);
    end
end
abs_pix_indices = find(logical_indices);
