classdef d2d < DnDBase
    %D2D Create an 2-dimensional DnD object
    %
    % Syntax:
    %   >> w = d2d()               % Create a default, empty, D2D object
    %   >> w = d2d(sqw)            % Create a D2D object from a 2-dimensional SQW object
    %   >> w = d2d(filename)       % Create a D2D object from a file
    %   >> w = d2d(struct)         % Create from a structure with valid fields (internal use)

    properties (Constant, Access = protected)
       NUM_DIMS = 2;
    end

    methods(Static)
        %TODO: disabled until full functionality is implemeneted in new class;
        % The addition of this method causes sqw_old tests to incorrectly load data from .mat files
        % as new-DnD class objects
        %        function obj = loadobj(S)
        %            % Load a sqw object from a .mat file
        %            %
        %            %   >> obj = loadobj(S)
        %            %
        %            % Input:
        %            % ------
        %            %   S       An instance of this object or struct
        %            %
        %            % Output:
        %            % -------
        %            %   obj     An instance of this object
        %            %
        %               obj = sqw(S);
        %        end
    end
    
    methods
        wout=symmetrise_horace_2d(win,varargin);
        varargout = get(this, index);
        [speedup,midpoint]=compare_sym_axes(win,v1,v2,v3);
        varargout = cut (varargin);
        [ok,mess]=test_symmetrisation_plane(win,v1,v2,v3); % only defined for d2d, not d[0-1,3-4]d
        [diag,type]=test_symmetrisation_plane_digaonal(win,v1,v2,v3);
        [R,trans] = calculate_transformation_matrix(win,v1,v2,v3);
        varargout = multifit_sqw (varargin);
        
        function obj = d2d(varargin)
            obj = obj@DnDBase(varargin{:});
        end

    end
end
