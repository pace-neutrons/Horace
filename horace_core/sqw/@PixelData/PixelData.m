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

properties (Constant)
    % The minimum number of columns the pixel data can have
    MIN_PIXEL_BLOCK_COLS_ = 9;
end

properties (Access=private)
    % The raw pixel data behind this interface
    data_ = zeros(9, 0);

    % The way the pixel data is stored, either 'memory' or 'file'
    storage_type_;
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
        % Construct a PixelData object
        %  data     The pixel data to interface to. This can be a numeric array
        %           or a path to a .sqw file.
        if nargin == 1
            obj.data = data;
        end
    end

    function sref = subsref(obj, s)
        % Implements a "get-index" operator for the class
        %  Indexing PixelData objects directly, indexes into the 'data'
        %  attribute. This is implemented to provide backwards compatibility
        %  for scripts written for Horace versions < 4.
        switch s(1).type
        case '.'
            sref = builtin('subsref', obj, s);
        case '()'
            sref = builtin('subsref', obj.data, s);
        case '{}'
            error('PIXELDATA:subsref', ...
                  'Operator ''{}'' not defined for class ''PixelData''.');
        end
    end

    function obj = subsasgn(obj, s, val)
        % Implements a "set-index" operator for the class
        %  Indexing PixelData objects directly, indexes into the 'data'
        %  attribute. This is implemented to provide backwards compatibility
        %  for scripts written for Horace versions < 4.
        if isempty(s) && isa(val, 'PixelData')
            obj = PixelData(val);
        end
        switch s(1).type
        case '.'
            obj = builtin('subsasgn', obj, s, val);
        case '()'
            obj.data = builtin('subsasgn', obj.data, s, val);
        case '{}'
            error('PIXELDATA:subsasgn', ...
                  'Operator ''{}'' not defined for class ''PixelData''.');
        end
    end

    function pixel_data = get.data(obj)
        pixel_data = obj.data_;
    end

    function set.data(obj, pixel_data)
        if isa(pixel_data, 'char')
            obj.set_file_as_data_(pixel_data);
        elseif isa(pixel_data, 'numeric')
            obj.set_numeric_array_as_data_(pixel_data);
        else
            err_msg = ['Cannot instantiate PixelData object with type %s. ' ...
                       'Only file paths and numeric types allowed'];
            error('PIXELDATA:data', err_msg, class(pixel_data));
        end
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

methods (Access=protected)

    function set_file_as_data_(obj, file_path)
        % Set the source of the pixel data as a file path
        if ~(exist(file_path, 'file'))
            err_msg = ['Cannot instantiate PixelData object with ', ...
                       'non-existent file ''%s''.'];
            error('PIXELDATA:data', err_msg, file_path);
        end
        obj.storage_type_ = 'file';
        obj.data_ = file_path;
    end

    function set_numeric_array_as_data_(obj, num_array)
        % Set the source of the pixel data as a numeric array
        if size(num_array, 1) < obj.MIN_PIXEL_BLOCK_COLS_
            msg = ['Cannot set pixel data, invalid dimensions. Axis 1 must '...
                   'have length greater than %i. Found %i.'];
            error('PIXELDATA:data', msg, obj.MIN_PIXEL_BLOCK_COLS_, ...
                  size(num_array, 1));
        end
        obj.storage_type_ = 'memory';
        obj.data_ = num_array;
    end

end

end
