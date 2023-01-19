classdef PixelData < PixelDataBase
% Dummy class for legacy compatibility
    methods
        function obj = PixelData(varargin)
        % Wrapper function to handle old-style scripts
        % Creates a PixelData object as per new functionality
            warning("PixelData constructor is deprecated. Please use PixelDataBase.create")
            obj = PixelDataBase.create(varargin{:});
        end

    end

    methods(Static)
        function obj = loadobj(S)
            obj = loadobj@PixelDataBase(S);
        end
    end
end
