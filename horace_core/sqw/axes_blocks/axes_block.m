classdef axes_block < ortho_axes
    % Transiend class, left for support of old data loading from .mat files
    % and v4 sqw binary files (if released with old axes_block)
    %
    % The functionality have been moved to ortho_axes class
    %
    methods
        function obj = axes_block(varargin)
            % constructor
            %
            obj = obj@ortho_axes(varargin{:});
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = ortho_axes();
            obj = loadobj@serializable(S,obj);
        end
    end
    %----------------------------------------------------------------------
end
