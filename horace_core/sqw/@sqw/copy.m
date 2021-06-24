function new_sqw = copy(obj, varargin)
% Copy this SQW object or an array of sqw objects
%
%   >> new_sqw = copy(old_sqw);
%
%   >> new_sqw = copy(old_sqw, 'exclude_pix', true);
%
% Keyword Inputs:
% ---------------
% exclude_pix   The sqw object copy will contain an empty PixelData object
%
% As PixelData is a handle class, we must call the copy operator on the pixels
% for the two SQW objects to not point to the same pixel data
%
[obj, exclude_pix] = parse_args(obj, varargin{:});

new_sqw = obj;
for i = 1:numel(obj)
    if is_sqw_type(obj(i)) && ~exclude_pix
        new_sqw(i).data.pix = copy(obj(i).data.pix);
    else
        new_sqw(i).data.pix = PixelData();
    end
end

end


% -----------------------------------------------------------------------------
function [obj, exclude_pix] = parse_args(obj, varargin)
    parser = inputParser();
    parser.addRequired('obj', @(x) isa(x, 'sqw'));
    parser.addParameter('exclude_pix', false, @(x) islogical(x));
    parser.parse(obj, varargin{:});

    exclude_pix = parser.Results.exclude_pix;
end
