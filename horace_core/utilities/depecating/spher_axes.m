classdef spher_axes < sphere_axes
    % Transient class, left for support of old data loading from .mat files
    % and v4 sqw binary files (if released with old ortho_proj class)
    %
    % The functionality of the ortho_proj class have been moved to
    % line_proj class
    %
    methods
        function obj = spher_axes(varargin)
            % constructor
            %
            if nargin ==0
                return;
            end
            warning('HORACE:deprecated:invalid_argument',...
                '"spher_axes" class is deprecated. Use "sphere_axes" class instead')
            obj = obj@sphere_axes(varargin{:});
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = line_proj();
            if isfield(S,'serial_name') && strcmp(S.serial_name,'spher_axes')
                S.serial_name  = 'sphere_axes';
            end
            obj = loadobj@serializable(S,obj);
        end
    end
    %----------------------------------------------------------------------
end
