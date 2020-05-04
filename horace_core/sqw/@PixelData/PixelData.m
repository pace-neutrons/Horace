classdef PixelData < matlab.mixin.SetGet
% PixelData Provides an interface for access to pixel data
%
%   This class provides getters and setters for each data column in an SQW
%   pixel array. You can access the data using the attributes listed below or
%   using Matlab's get(obj, 'attr') and set(obj, 'attr', value) methods.
%
%
% Usage
%   >> pix_data = PixelData(data)
%   >> signal = pix_data.signal;
%
%  or equivalently:
%
%   >> pix_data = PixelData()
%   >> pix_data.data = data;
%   >> signal = get(pix_data, 'signal');
%
% Attributes:
%   data           The raw pixel data
%   coordinates    Get/set the coords in projection axes of the pixel data (4 x n array)
%   irun           The run index the pixel originated from (1 x n array)
%   idet           The detector group number in the detector listing for the pixels (1 x n array)
%   ienergy        The energy bin numbers (1 x n array)
%   signals        The signal array (1 x n array)
%   errors         The errors on the signal array (variance i.e. error bar squared) (1 x n array)
%   num_pixels     The number of pixels in the data block

properties (Access=private)
    PIXEL_BLOCK_COLS_ = 9;
    data_ = zeros(9, 0);
end
properties (Dependent)
    % Returns the full raw pixel data block (9 x n array)
    data;

    % Returns the coordinates of the pixels in the projection axes, i.e.: u1,
    % u2, u3 and dE (4 x n array)
    coordinates;

    % The run index the pixel originated from (1 x n array)
    irun;

    % The detector group number in the detector listing for the pixels (1 x n array)
    idet;

    % The energy bin numbers (1 x n array)
    ienergy;

    % The signal array (1 x n array)
    signals;

    % The errors on the signal array (variance i.e. error bar squared) (1 x n array)
    errors;

    % The number of pixels in the data block
    num_pixels;
end

methods

    function obj = PixelData(data)
        if nargin == 1
            obj.data = data;
        end
    end

    function is_empty = isempty(obj)
       is_empty = isempty(obj.data);
    end

    function s = size(obj, varargin)
        % Return the size of the PixelData
        %   Axis 1 gives the number of columns, axis 2 gives the number of
        %   pixels
        %
        % For the time being, the number of columns is equal to the number of
        % columns in the underlying pix data block. When we start allowing
        % additional columns to be added, the number of columns of a PixelData
        % object may not equal the number in the main underlying data
        % structure.
        % This overload should always return the number of columns in the
        % underlying structure + the number of additional columns
        s = size(obj.data, varargin{:});
    end

    function pixel_data = get.data(obj)
        pixel_data = obj.data_;
    end

    function obj = set.data(obj, pixel_data)
        if size(pixel_data, 1) ~= obj.PIXEL_BLOCK_COLS_
            msg = ['Cannot set pixel data, invalid dimensions. Axis 1 must '...
                   'have length %i found ''%i''.'];
            error('PIXELDATA:data_error', msg, obj.PIXEL_BLOCK_COLS_, ...
                  size(pixel_data, 1));
        end
        obj.data_ = pixel_data;
    end

    function coord_data = get.coordinates(obj)
        coord_data = obj.data(1:4, :);
    end

    function set.coordinates(obj, coordinates)
        obj.data(1:4, :) = coordinates;
    end

    function run_index = get.irun(obj)
        run_index = obj.data(5, :);
    end

    function set.irun(obj, iruns)
        obj.data(5, :) = iruns;
    end

    function detector_index = get.idet(obj)
       detector_index = obj.data(6, :);
    end

    function set.idet(obj, detector_indices)
       obj.data(6, :) = detector_indices;
    end

    function detector_index = get.ienergy(obj)
       detector_index = obj.data(7, :);
    end

    function set.ienergy(obj, energies)
        obj.data(7, :) = energies;
     end

    function signals = get.signals(obj)
       signals = obj.data(8, :);
    end

    function set.signals(obj, signals)
        obj.data(8, :) = signals;
     end

    function errors = get.errors(obj)
       errors = obj.data(9, :);
    end

    function set.errors(obj, errors)
        obj.data(9, :) = errors;
     end

    function num_pix = get.num_pixels(obj)
        num_pix = size(obj.data, 2);
    end

end

end
