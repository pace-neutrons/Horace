classdef d1d < DnDBase
    %D1D Create an 1-dimensional DnD object
    %
    % Syntax:
    %   >> w = d1d()               % Create a default, empty, D1D object
    %   >> w = d1d(sqw)            % Create a D1D object from a 1-dimensional SQW object
    %   >> w = d1d(filename)       % Create a D1D object from a file
    %   >> w = d1d(struct)         % Create from a structure with valid fields (internal use)

    properties (Constant, Access = protected)
       NUM_DIMS = 1;
    end

    methods
        function obj = d1d(varargin)
            obj = obj@DnDBase(varargin{:});
        end

        wout = cut (varargin);
        wout = combine_horace_1d(w1,w2,varargin);
        wout = rebin_horace_1d(win, varargin);
        wout = symmetrise_horace_1d(win, varargin);
    end

    methods(Access = private)
        [ok, same_axes, mess] = check_rebinning_axes_1d(w1, w2);
    end

    methods(Static, Access = private)
        [xout, yout, eout, nout] = combine_1d(x1, y1, e1, n1, x2, y2, e2, n2, tol);
        [xout, yout, eout, nout] = symmetrise_1d(xin, yin, ein, nin, midpoint);
        [cumulsum, esum, nsum] = rebin_1d_finegrid(snew, enew, nnew, xinnew, lonew, hinew, eps, xlo, xhi, i);
        [cumulsum, esum, nout] = rebin_1d_multibins(ind, binfrac, snew, enew, nnew, xinnew, eps, xlo, xhi, i);
        [sout, eout, nout] = rebin_1d_general(xin, xout, sin, ein, nin);
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
end
