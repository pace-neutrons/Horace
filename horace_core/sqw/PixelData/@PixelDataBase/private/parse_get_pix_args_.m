function [pix_indices,ind_in_pix,ignore_range,raw_data,keep_precision,align] = ...
    parse_get_pix_args_(obj,accepts_logical,varargin)
% Parse input arguments which may be provided to get_pixels function and
% return standard form of this arguments
% Inputs:
% obj             -- initialized instance of PixelData class
% accepts_logical -- true or false depending on the get_pixels version
%                    which may or may not accept logical arguments
%                    depending on the PixelDataBase class subclass, calling
%                    get_pixels
% varargin        -- inputs which may be provided to get_pixels function
% Optional inputs:
% pix_indices     -- logical or numerical array of pixel indexes to return
%                    pixels corresponding to these indexes, or keyword
%                    'all'
% index_set       -- string or cellarray of strings which defines
%                    pixel fields to return (e.g. 'signal', 'q_coordinates').
%                    If present, function will only return selected pixel fields.
%                    Can only be provided in conjunction with
%                    the '-raw_data' keyword.
% string or cellarray of strings which defines
%                    selection of pixel parts to return. If present, indicates
%                    to not to return complete pixels data but return subset
%                    of pixel fields values.
%                    Can be provided with keyword -raw_data only.
%
% '-ignore_range' -- if present, indicates to not calculate pixel ranges when
%                    returning PixelData class
% '-raw_data'     -- do not wrap pixel data into pixel class and return
%                    underlying pixel array
% '-keep_precision'
%                --  do not change the precision of the output data, i.e.
%                    if internal PixelData are single precision data,
%                    output data should be single precision too.
% '-align'       --  if present and pixels are misaligned, apply alignment
%                    matrix to the appropriate pixel data and return
%                    aligned data
% Outputs:
% pix_indices    -- logical or numerical array of pixel indices to return
%                   pixels corresponding to these indices. If
%                   accept_logical is false, input logical indices are
%                   converted into numerical indices. If input pix_indeces
%                   are missing, the indices correspond to page for
%                   filebacked pixels or all pixels in memory for memory
%                   based pixels. If keyword 'all' is present, try to return
%                   array of all pixel indices. Fails if this array does
%                   not fit memory.
% ignore_range   -- true if present '-ignore_range', false otherwise
% raw_data       -- true if present '-raw_data', false otherwise
% keep_precision -- true if present '-keep_precision', false otherwise
% align          -- true if present '-align', false otherwise

[ok, mess, ignore_range, raw_data, keep_precision, align,argi] = ...
    parse_char_options(varargin, ...
    {'-ignore_range','-raw_data','-keep_precision','-align'});
if ~ok
    error('HORACE:PixelDataBase:invalid_argument',mess);
end
nargi =numel(argi);
ind_in_pix = [];
switch nargi
    case 0
        [ind_min,ind_max] = obj.get_page_idx_();
        pix_indices = ind_min:ind_max;
    case {1,2}
        pix_indices = argi{1};
        if nargi > 1
            if ~raw_data
                error('HORACE:PixelDataBase:invalid_argument', ...
                    'get_pixel argument: %s is compatible with -raw_data switch only', ...
                    disp2str(argi{2}))
            end
            ind_in_pix= obj.field_index(argi{2});
        else
            ind_in_pix= [];
        end

        if islogical(pix_indices)
            if accepts_logical
                if numel(pix_indices) ~= obj.num_pixels
                    pix_indices = obj.logical_to_normal_index_(pix_indices);
                end
                return;
            else
                pix_indices = obj.logical_to_normal_index_(pix_indices);
            end
        elseif istext(pix_indices) && strcmpi(pix_indices,'all')
            if accepts_logical
                pix_indices = true(1,obj.num_pixels);
            else
                pix_indices = 1:obj.num_pixels;
            end
            return;
        end
        if ~isindex(pix_indices)
            error('HORACE:PixelDataBase:invalid_argument',...
                ['pixel indices should be an array of numeric positive numbers,' ...
                ' which define indices or vector of logical values'])
        end

        if any(pix_indices > obj.num_pixels)
            error('HORACE:PixelDataBase:invalid_argument', ...
                'Some numerical indices exceed the total number of pixels')
        end
    otherwise
        error('HORACE:PixelDataBase:invalid_argument', ...
            'Too many inputs provided to parse_get_pix_args_')
end

