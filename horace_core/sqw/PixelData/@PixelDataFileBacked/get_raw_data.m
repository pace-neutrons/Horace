function  data =  get_raw_data(obj,varargin)
% get unchanged pixel data for single data page
% Inputs:
% obj   -- Initialized instance of PixelDataFileBacked
% Optional:
% page_number -- if provided, request particular page number, rather then
%                current page
% idx         -- char string, which describes the name of the indexes to
%                get. If present, return the requested pixel data parts
%                rather then all pixel data
%
if nargin == 1
    page_number = obj.page_num_;
end
if nargin > 1
    if iscell(varargin{1})|| ischar(varargin{1})
        fld = varargin{1};
    elseif isnumeric(varargin{1})
        page_number = varargin{1};
        if nargin > 2 && (iscell(varargin{2})|| ischar(varargin{2}))
            fld = varargin{2};
        else
            fld= [];
        end
    else
        fld= [];
    end
else
    fld = [];
end

if isempty(obj.f_accessor_)
    data = obj.EMPTY_PIXELS;
else
    [pix_idx_start, pix_idx_end] = obj.get_page_idx_(page_number);
    if isempty(fld)
        data = double(obj.f_accessor_.Data.data(:, pix_idx_start:pix_idx_end));
    else
        idx = obj.FIELD_INDEX_MAP_(fld);
        data = double(obj.f_accessor_.Data.data(idx, pix_idx_start:pix_idx_end));
    end
end

