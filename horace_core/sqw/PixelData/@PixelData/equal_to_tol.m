function [ok, mess] = equal_to_tol(obj, other_pix, varargin)
%% EQUAL_TO_TOL Check if two PixelData objects are equal to a given tolerance
%
[tol, nan_equal] = parse_args(varargin{:});

[ok, mess] = validate_other_pix(obj, other_pix);
if ~ok
    return
end

obj = obj.move_to_first_page();
other_pix = other_pix.move_to_first_page();

if obj.page_size == other_pix.page_size
    [ok, mess] = equal_to_tol(...
            obj.data, other_pix.data, tol, 'nan_equal', nan_equal);
    while ok && obj.has_more()
        obj = obj.advance();
        other_pix = other_pix.advance();
        [ok, mess] = equal_to_tol(...
                obj.data, other_pix.data, tol, 'nan_equal', nan_equal);
    end
elseif obj.page_size == obj.num_pixels
    [ok, mess] = pix_paged_and_in_mem_equal_to_tol(...
            other_pix, obj, tol, 'nan_equal', nan_equal);
elseif other_pix.page_size == other_pix.num_pixels
    [ok, mess] = pix_paged_and_in_mem_equal_to_tol(...
            obj, other_pix, tol, 'nan_equal', nan_equal);
else
    error('PIXELDATA:equal_to_tol', ...
          ['Cannot compare PixelData objects that have different page ' ...
           'sizes.\nFound page sizes %i and %i.'], obj.page_size, ...
          other_pix.page_size);
end

end


% -----------------------------------------------------------------------------
function [ok, mess] = pix_paged_and_in_mem_equal_to_tol(...
        paged_pix, in_mem_pix, varargin)
    start_idx = 1;
    end_idx = paged_pix.page_size;
    [ok, mess] = equal_to_tol(in_mem_pix.data(:, start_idx:end_idx), ...
                              paged_pix.data, varargin{:});
    while ok && paged_pix.has_more()
        paged_pix.advance();
        start_idx = end_idx + 1;
        end_idx = end_idx + paged_pix.page_size;
        [ok, mess] = equal_to_tol(in_mem_pix.data(:, start_idx:end_idx), ...
                                  paged_pix.data, varargin{:});
    end
end


function [ok, mess] = validate_other_pix(obj, other_pix)
    ok = true;
    mess = '';

    if ~(isa(other_pix, 'PixelData'))
        ok = false;
        mess = sprintf('Objects of class ''%s'' and ''%s'' cannot be equal.', ...
                       class(obj), class(other_pix));
        return
    end

    if ~all(size(obj) == size(other_pix))
        ok = false;
        mess = sprintf(['PixelData objects are not equal. ' ...
                        'Argument 1 has size [%s] , argument 2 has size [%s]'], ...
                       num2str(size(obj)), num2str(size(other_pix)));
        return
    end
end


function [tol, nan_equal] = parse_args(varargin)
    parser = inputParser();
    parser.addOptional('tol', [0, 0], @(x) (numel(x) <= 2) && all(x >= 0));
    parser.addParameter('nan_equal', true, @(x) isscalar(x) && islogical(x));
    parser.addParameter('name_a', 'input_1', @ischar);
    parser.addParameter('name_b', 'input_2', @ischar);
    parser.parse(varargin{:});

    tol = parser.Results.tol;
    nan_equal = parser.Results.nan_equal;
end
