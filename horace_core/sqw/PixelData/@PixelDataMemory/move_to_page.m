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

end


% -----------------------------------------------------------------------------
function [page_number,total_num_pages, nosave] = parse_args(obj, varargin)
persistent parser
if isempty(parser)
    parser = inputParser();
    parser.addRequired('page_number', @is_scalar_positive_int);
    parser.addParameter('nosave', false, @islognumscalar);
end
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
