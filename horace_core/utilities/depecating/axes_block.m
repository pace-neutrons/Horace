classdef axes_block < line_axes
    % Transient class, left for support of old data loading from .mat files
    % and v4 sqw binary files (if released with old axes_block)
    %
    % The functionality of the axes_block class have been moved to line_axes
    % class
    %
    methods
        function obj = axes_block(varargin)
            % constructor
            %

            if nargin ==0
                return;
            end
            warning('HORACE:deprecated:invalid_argument',...
                '"axes_block" class is deprecated. Use "line_axes" instead')
            obj = obj@line_axes(varargin{:});
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = line_axes();
            if isfield(S,'serial_name') && strcmp(S.serial_name,'axes_block')
                S.serial_name  = 'line_axes';
            end
            obj = loadobj@serializable(S,obj);
        end
    end
    %----------------------------------------------------------------------
end
