function [pix_indices,ignore_range,raw_data,keep_precision,align] = ...
    parse_get_pix_args_(obj,accepts_logical,varargin)
% Parce input arguments which may be provided to get_pixels function and
% return standard form of this arguments
% Inputs:
% obj             -- initialized instance of PixelData class
% accept_logical  -- true or false depending on the get_pixels version
%                    which may or may not accept logical arguments
%                    depending on the PixelDataBase class subclass, calling
%                    get_pixels
% varargin        -- inputs which may be provided to get_pixels function
% Optional inputs:
% pix_indexes     -- logical or numerical array of pixel indexes to return
%                    pixels corresponding to these indexes, or keyword
%                    'all'
% '-ignore_range' -- if present, indicates to not calculate pixel ranges when
%                    returning PixelData class
% '-raw_data'     -- do not wrap pixel data into pixel class and return
%                    underlying pixel array
% '-keep_precision'
%                --  do not change the precision of the output data, i.e.
%                    if internal PixelData are single precision data,
%                    output data shoule be single precision too.
% '-align'       --  if present and pixels are misaligned, apply alignment
%                    matrix to the appropriate pixel data and return
%                    aligned data
% Outputs:
% pix_indices    -- logical or numerical array of pixel indexes to return
%                   pixels corresponding to these indexes. If
%                   accept_logical is false, input logical indices are
%                   converted into numerical indices. If input pix_indeces
%                   are missing, the indexes corepond to page for
%                   filebacked pixels or all pixels in memory for memory
%                   based pixels. If keyword 'all' is present, try to retur
%                   array of all pixel indexes. Fails if this array does
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

switch numel(argi)
    case 0
        [ind_min,ind_max] = obj.get_page_idx_();
        pix_indices = ind_min:ind_max;

    case 1
        pix_indices = argi{1};

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
                'pixel indices should be an array of numeric positive numbers, which define indices or vector of logical values')
        end

        if any(pix_indices > obj.num_pixels)
            error('HORACE:PixelDataBase:invalid_argument', ...
                'Some numerical indices exceed the total number of pixels')
        end

    otherwise
        error('HORACE:PixelDataBase:invalid_argument', ...
            'Too many inputs provided to parse_get_pix_args_')
end
end
