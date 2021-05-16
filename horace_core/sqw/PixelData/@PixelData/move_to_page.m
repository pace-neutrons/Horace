function [page_number,total_num_pages] = move_to_page(obj, page_number, varargin)
% Set the object to point at the given page number
%   This function does nothing if the object is not file-backed or is
%   already on the given page
%
% Inputs:
% page_number -- page number to move to
%
% Returns:
% page_number -- the page this routine moved to
% total_num_pages -- total number of pages, present in the file
%
[page_number, total_num_pages, nosave] = parse_args(obj, page_number, varargin{:});
if obj.is_filebacked() && obj.page_number_ ~= page_number
    if ~nosave && obj.page_is_dirty_(obj.page_number_) && obj.dirty_page_edited_
        obj.write_dirty_page_();
    end
    obj.page_number_ = page_number;
    obj.dirty_page_edited_ = false;
    obj.data_ = zeros(obj.PIXEL_BLOCK_COLS_, 0);
end

end


% -----------------------------------------------------------------------------
function [page_number,total_num_pages, nosave] = parse_args(obj, varargin)
parser = inputParser();
parser.addRequired('page_number', @is_scalar_positive_int);
parser.addParameter('nosave', false, @islognumscalar);
parser.parse(varargin{:});

page_number = parser.Results.page_number;
total_num_pages = obj.get_num_pages_();
nosave = parser.Results.nosave;

if page_number > total_num_pages
    error('PIXELDATA:move_to_page', ...
        'Cannot advance to page %i only %i pages of data found.', ...
        page_number, total_num_pages);
end
end


function is = is_scalar_positive_int(number)
is = isscalar(number) && (number == floor(number)) && number >= 1;
end
