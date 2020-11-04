function obj = move_to_page(obj, page_number)
% Set the object to point at the given page number
%   This function does nothing if the object is not file-backed or is
%   already on the given page
%
page_number = parse_args(obj, page_number);

if obj.is_file_backed_() && obj.page_number_ ~= page_number

    if obj.page_is_dirty_(obj.page_number_) && obj.dirty_page_edited_
        obj.write_dirty_page_();
    end
    obj.page_number_ = page_number;
    obj.dirty_page_edited_ = false;
    obj.data_ = zeros(obj.PIXEL_BLOCK_COLS_, 0);
end

end


% -----------------------------------------------------------------------------
function page_number = parse_args(obj, varargin)
    parser = inputParser();
    parser.addRequired('page_number', @is_scalar_positive_int);
    parser.parse(varargin{:});

    page_number = parser.Results.page_number;

    if page_number > obj.get_num_pages_
        error('PIXELDATA:move_to_page', ...
              'Cannot advance to page %i only %i pages of data found.', ...
              page_number, obj.get_num_pages_);
    end
end


function is = is_scalar_positive_int(number)
    is = isscalar(number) && (number == floor(number)) && number >= 1;
end
