function obj = PixelData(varargin)
% Wrapper function to handle old-style scripts
% Creates a PixelData object as per new functionality
    obj = PixelDataBase.create(varargin{:});
end
