classdef d1d < DnDBase
    %D1D Create an 1-dimensional DnD object
    %
    % Syntax:
    %   >> w = d1d()               % Create a default, empty, D1D object
    %   >> w = d1d(sqw)            % Create a D1D object from a 1-dimensional SQW object
    %   >> w = d1d(filename)       % Create a D1D object from a file
    %   >> w = d1d(struct)         % Create from a structure with valid fields (internal use)

    properties (Dependent)
        NUM_DIMS;
    end

    methods
        function obj = d1d(varargin)
            obj = obj@DnDBase(varargin{:});
            if nargin == 0
                obj.axes.single_bin_defines_iax = [false,true,true,true];
                obj.axes.dax= 1;
                obj.s_ = 0;
                obj.e_ = 0;
                obj.npix_ = 0;                
            end
        end
        dat = IX_dataset_1d(obj);

        wout = combine_horace_1d(w1,w2,varargin);
        wout = rebin_horace_1d(win, varargin);
        wout = symmetrise_horace_1d(win, varargin);

        function nd = get.NUM_DIMS(~)
            nd =1;
        end
        function [nd,sz] = dimensions(obj)
            nd = 1;
            sz = obj.axes_.data_nbins;
        end
    end
    methods(Access = protected)
        function obj = set_senpix(obj,val,field)
            % always do 1-D array a column array
            % its importent for replication, as Matlab assumes that first
            % index defines column.
            val = val(:);
            obj = set_senpix@DnDBase(obj,val,field);
        end

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
            % boilerplate loadobj method, calling generic method of
            % saveable class. Put it as it is replacing the
            obj = d1d();
            obj = loadobj@serializable(S,obj);
        end
    end
end
