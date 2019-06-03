classdef projection<aProjection
    %  Class defines coordinate projections necessary to make Horace cuts
    %  in crystal coordinate system (orthogonal or non-orthogonal)
    %
    %  Uses projection axis and projection logic, defined by projaxis class
    %  and works as interface to this class for defining projection
    %
    %  Defines coordinate transformations, used by cut_sqw when making
    %  Horace cuts
    %
    % $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
    %
    properties 
        %
    end
    properties(Dependent)
        u; %[1x3] Vector of first axis (r.l.u.)
        v; %[1x3] Vector of second axis (r.l.u.)
        w; %[1x3] Vector of third axis (r.l.u.) - used only if third character of type is 'p'
        type; %='rrr';
        uoffset; %=[0,0,0,0];
        lab     %={'\zeta','\xi','\eta','E'};
        %
        %
    end
    properties(Access=private)
        % reference to the class, which defines the projection axis
        projaxes_=[]
        %
    end
    methods(Access = protected)
        % overloads for staitc methods which define if the projection can
        % keep pixels and have mex functions defined
        function isit= can_mex_cut_(self)
            % ortho projection have mex procedures defined
            isit = true;
        end
    end
    
    methods
        function proj=projection(varargin)
            proj = proj@aProjection();
            if nargin==0 % return defaults
                proj.projaxes_ = [];
                proj.data_lab_ = ['qx','qy','qz','en'];
            else
                if isa(varargin{1},'projaxes')
                    proj.projaxes_ = varargin{1};
                else
                    proj.projaxes_ = projaxes(varargin{:});
                end
            end
        end
        
        function u = get.u(this)
            if isempty(this.projaxes_)
                u= 'dnd-X-aligned';
            else
                u = this.projaxes_.u;
            end
        end
        function v = get.v(this)
            if isempty(this.projaxes_)
                v= 'dnd-Y-aligned';
            else
                v = this.projaxes_.v;
            end
        end
        function w = get.w(this)
            if isempty(this.projaxes_)
                w= [];
            else
                w = this.projaxes_.w;
            end
        end
        function type = get.type(this)
            if isempty(this.projaxes_)
                type = 'aaa';
            else
                type = this.projaxes_.type;
            end
        end
        function this =set.type(this,val)
            if isempty(this.projaxes_)
                error('PROJECTION:invalid_argument','define projection plains first');
            else
                this.projaxes_.type = val;
            end
        end
        
        function uoffset = get.uoffset(this)
            if isempty(this.projaxes_)
                uoffset = [0;0;0;0];
            else
                uoffset = this.projaxes_.uoffset;
            end
        end
        function lab = get.lab(this)
            if isempty(this.projaxes_)
                lab = this.data_lab_;
            else
                lab = this.projaxes_.lab;
            end
        end       
        %------------------------------------------------------------------
        % Particular implementation of aProjection abstract interface
        %------------------------------------------------------------------
        function urange_out = find_max_data_range(this,urange_in)
            % find the whole range of input data which may contribute
            % into the result.
            % urange_in -- the range of the data in the initial coordinate
            % system.
            urange_out  = find_ranges_(this,urange_in);
        end
        
        function [istart,iend,irange,inside,outside] =get_irange_proj(this,urange,varargin)
            % Get ranges of bins that partially or wholly lie inside an n-dimensional rectangle,
            % where the first three dimensions can be rotated and translated w.r.t. the
            % cuboid that is split into bins.
            [istart,iend,irange,inside,outside] = get_irange_rot(this,urange,varargin{:});
        end
        %
        function [indx,ok] = get_contributing_pix_ind(this,v)
            % get list of indexes contributing into the cut
            [indx,ok] = get_contributing_pix_ind_(this,v);
        end
        function [uoffset,ulabel,dax,u_to_rlu,ulen,title_build_class] = get_proj_param(this,data_in,pax)
            % get projection parameters, necessary for properly definind a sqw or dnd object
            %
            [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param_(this,data_in,pax);
            title_build_class = an_axis_caption();
        end
        %
        function [urange_step_pix_recent, ok, ix, s, e, npix, npix_retain,success]=...
                accumulate_cut(this,v,s,e,npix,pax,ignore_nan,ignore_inf,keep_pix,n_threads)
            %Method, used to both project data and allocate memory used by
            %sqw&dnd objects. Has to be written in close conjunction with
            %cut_sqw using deep understanding of the ways memory is allocated
            % within sqw objects
            [urange_step_pix_recent, ok, ix, s, e, npix, npix_retain,success]=...
                accumulate_cut_(this,v,s,e,npix,pax,ignore_nan,ignore_inf,keep_pix,n_threads);
        end
        
        %
    end
end
