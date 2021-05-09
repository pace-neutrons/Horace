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
        function obj = loadobj(S)
            % Load a d1d object from a .mat file
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       An instance of this object or struct
            %
            % -------
            % Output:
            %   obj     An instance of this object
            obj = d1d(S);
            if isa(S,'d1d')
               obj = S;
               return
            end
            if numel(S)>1
               tmp = d1d();
               obj = repmat(tmp, size(S));
               for i = 1:numel(S)
                   obj(i) = d1d(S(i));
               end
            else
               obj = d1d(S);
            end
        end
    end
end
