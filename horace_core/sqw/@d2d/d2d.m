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

    methods
        function obj = d2d(varargin)
            obj = obj@DnDBase(varargin{:});
            if nargin==0
                obj.nbins_all_dims = [2,2,1,1];
            end
        end

        wout=combine_horace_2d(w1,w2,varargin);
        wout=symmetrise_horace_2d(win,varargin);
        wout=rebin_horace_2d(win,varargin);

        [speedup,midpoint]=compare_sym_axes(win,v1,v2,v3);
        varargout = cut(varargin);
        [R,trans] = calculate_transformation_matrix(win,v1,v2,v3);

        varargout = get(this, index);
    end

    methods(Access = private)
        [irange, uoff]=calculate_integration_range(w1, w2);
        [ok, same_axes, mess]=check_rebinning_axes(w1, w2);
        [xright,yright,sright,eright,nright]=discard_lhs(win,x,y,s,e,n,v1,v2,v3);

        [ok, mess] = test_symmetrisation_plane(win, v1, v2, v3);
        [diag, type] = test_symmetrisation_plane_diagonal(win, v1, v2, v3);
    end

    methods(Static, Access = private)
        out=left_turn(a,b,c);
        out=right_turn(a,b,c);

        [sout,eout,nout]=rebin_shoelace(xin,yin,sin,ein,nin,xout,yout);
        [xr,yr,sr,er,nr]=reflect_data_bins(xin,yin,sin,ein,nin,R,trans);

        Area = shoelace_areacalc(xout,yout,xin,yin,inarea,outarea);
        intersection=shoelace_calculate_all_intersections(xout,yout,xin,yin,totinside);
        intpoints=shoelace_check_in_quad(a1,b1,c1,d1,a2,b2,c2,d2);
        inside = shoelace_inside_quad(p,a,b,c,d);
        [intpoints,numpoints]=shoelace_intersections_convhull(xout,yout,xin,yin,i);
        [xc,yc]=shoelace_intersections_turning(x1,y1,x2,y2);
        likely = shoelace_preprocess(xin,yin,xout,yout);
        [xout,yout,inarea_out,outarea_out,sout,eout,nout]=shoelace_rearrangement(xin,yin,...
            inarea,outarea,sin,ein,nin,likely);
        area=shoelace_triangle_area(a,b,c);
        [y,ndx] = sortrows_special(x,col);
    end

    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class. Put it as it is replacing the
            obj = d2d();
            obj = loadobj@serializable(S,obj);
        end

    end
end
