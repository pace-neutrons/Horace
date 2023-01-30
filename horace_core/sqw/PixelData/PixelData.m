classdef PixelData < PixelDataMemory
    % Dummy class for loading legacy .mat files containing old version of 
    % PixelData (PixelDataMemory now)
    methods
        function obj = PixelData(varargin)
            % Wrapper function to handle old-style scripts
            % Creates a PixelData object as per new functionality
            if nargin == 0
                return;
            end
            obj = obj@PixelDataMemory(varargin{:});            
        end

    end

    methods(Static)
        function obj = loadobj(S)
            obj = PixelDataMemory();
            obj = loadobj@PixelDataMemory(S,obj);
        end
    end
end
