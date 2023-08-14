classdef ortho_axes < line_axes
    % Transient class, left for support of old data loading from .mat files
    % and v4 sqw binary files (if released with old ortho_axes)
    %
    % The functionality of the axes_block class have been moved to line_axes
    % class
    %
    methods
        function obj = ortho_axes(varargin)
            % constructor
            %
            obj = obj@line_axes(varargin{:});
            if nargin ==0
                return;
            end
            warning('HORACE:deprecated:invalid_argument',...
                '"ortho_axes" class is deprecated. Use "line_axes" class instead')
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = line_axes();
            if isfield(S,'serial_name') && strcmp(S.serial_name,'ortho_axes')
                S.serial_name  = 'line_axes';
            end
            obj = loadobj@serializable(S,obj);
        end
    end
    %----------------------------------------------------------------------
end
