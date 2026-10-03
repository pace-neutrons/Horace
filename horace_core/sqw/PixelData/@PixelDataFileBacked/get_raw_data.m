function  data =  get_raw_data(obj,page_number,varargin)
% get unchanged pixel data for single data page
% Inputs:
% obj   -- Initialized instance of PixelDataFileBacked
%
% Optional: (any or both of the following inputs:)
% page_number -- if provided, request particular page number, rather then
%                current page
% idx         -- char string, which describes the name of the indexes to
%                get. If present, return the requested pixel data parts
%                rather then all pixel data
% Output:
% data        -- [DEFAULT_NUM_PIX_FIELDS x page_size] if idx is not present
%                or [ncol x page_size] if idx present, where ncol is defined
%                by idx array of pixel information.
%
% Note:
% idx defines the pixel indexes as described in PixelDataBase.FIELD_INDEX_MAP_
%
if nargin == 1
    page_number = obj.page_num_;
end
if page_number == 1
    ;
end

if ~isempty(varargin)
    idx = obj.field_index(varargin{1});
elseif isfield(obj.f_accessor_.Data,'data2')
    idx = 1:3;
    sqw_struct = obj.sqw_obj;
else
    idx = obj.FIELD_INDEX_MAP_('all');
end

if isempty(obj.f_accessor_)
    data = obj.EMPTY_PIXELS;
else
    [pix_idx_start, pix_idx_end] = obj.get_page_idx_(page_number);
    if obj.keep_precision_
        data1 = obj.f_accessor_.Data.data(idx, pix_idx_start:pix_idx_end);
    else
        data1 = double(obj.f_accessor_.Data.data(idx, pix_idx_start:pix_idx_end));
    end
    if isfield( obj.f_accessor_.Data,'data2')
        pix_idx2_end = sum(obj.nonzerosignal_pix(1:page_number));
        pix_idx2_start = pix_idx2_end - obj.nonzerosignal_pix(page_number) + 1;
        if obj.keep_precision_
            data2 = obj.f_accessor_.Data.data2(:,pix_idx2_start:pix_idx2_end);
        else
            data2 = double(obj.f_accessor_.Data.data2(:,pix_idx2_start:pix_idx2_end));
        end
        data(8,data2(1,:)) = data2(2,:);
        data(9,data2(1,:)) = data2(3,:);

        qw = calculate_qw_pixels3(sqw_struct, ...            
        data1(1,:),data1(2,:),data1(3,:),false,true);

        data(5:7,:) = data1;
        data(1:4,:) = qw;
    else
        data = data1;
    end
end
