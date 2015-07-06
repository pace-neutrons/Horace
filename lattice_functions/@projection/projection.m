classdef projection<aprojection
    %  Class defines coordinate projections necessary to make horace cuts 
    %  in crystal coordinate system (orthogonal or non-orthogonal)
    %
    %  Uses projection axis and projection logic, defined by projaxis class
    %  and works as interface to this class for defining projection
    %
    %  Defines coordinate transformations, used by cut_sqw when making
    %  horace cuts
    %
    % $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
    %   
    properties %(SetAccess=protected)
        %
        usteps = [1,1,1,1]
        % data ranges in new coordinate system in units of steps in each
        % direction
        urange_step =zeros(2,4);
        urange_offset = zeros(1,4);
    end
    properties(Dependent)
        u; %[1x3] Vector of first axis (r.l.u.)
        v; %[1x3] Vector of second axis (r.l.u.)
        w; %[1x3] Vector of third axis (r.l.u.) - used only if third character of type is 'p'
        type; %='rrr';
        uoffset; %=[0,0,0,0];
        lab     %={'\zeta','\xi','\eta','E'};
        %
        alatt
        angdeg
    end
    properties(Access=private)
        % reference to the class, which defines the projection axis
        projaxes_=[]
        %
        alatt_=[1,1,1];
        angdeg_= [90,90,90];
        %------------------------------------
        data_u_to_rlu_ = eye(3);
        data_uoffset_  = [0;0;0;0]
        data_ulen_     = [1,1,1,1];
        data_upix_to_rlu_ = eye(3);
        data_upix_offset_ = [0;0;0;0] %upix_offset;
        data_lab_ = ['qx','qy','qz','en'];
    end
    methods(Access = protected)
        % overloads for staitc methods which define if the projection can
        % keep pixels and have mex functions defined
        function isit= can_mex_cut_(self)
            % ortho projection have mex procedures defined
            isit = true;
        end
        function isit= can_keep_pixels_(self)
            % ortho projection can keep pixels allowing cuts from cuts
            isit = true;
        end
    end
    
    methods
        function proj=projection(varargin)
            proj = proj@aprojection();
            if nargin==0 % return defaults
                proj.projaxes_ = [];
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
        
        function alat = get.alatt(this)
            alat = this.alatt_;
        end
        function angl = get.angdeg(this)
            angl = this.angdeg_;
        end
        %-----------------------------------------------------------------
        function this=init_tranformation(this,data)
            % Retrieve all parameters, necessary to define a transformation
            % from sqw data
            this = set_data_transf_(this,data);
        end
        function urange_out = find_maximal_data_range(this,urange_in)
            % find the whole range of input data which may contribute
            % into the result.
            % urange_in -- the range of the data in initial coordinate
            % system.
            urange_out  = find_ranges_(this,urange_in);
        end
        
        function this = set_proj_ranges(this,ustep,urange_step,urange_offset)
            % urange_step -- number of bin in every cut direction
            % ustep -- step size in each cut direction
            this.usteps = ustep;
            this.urange_step = urange_step;
            this.urange_offset = urange_offset;
            
        end
        function [nbinstart,nbinend] = get_bin_range(this,urange,nelmts,varargin)
            % Get range of grid bin indexes, which may contribute into the final
            % cut.
            [nbinstart,nbinend] = get_nrange_rot_section_(this,urange,nelmts,varargin{:});
        end
        %
        function [indx,ok] = get_contributing_pix_ind(this,v)
            % get list of indexes contributing into the cut
            [indx,ok] = get_contributing_pix_ind_(this,v);
        end
        function [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param(this,data_in,pax)
            % get projection parameters, necessary for properly definind a sqw or dnd object
            %
            [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param_(this,data_in,pax);
        end
        %
        function [urange_step_pix_recent, ok, ix, s, e, npix, npix_retain,success]=...
                accumulate_cut(this,v,s,e,npix,pax,ignore_nan,ignore_inf,keep_pix,n_threads)
            %Method, used to both project data and allocate memory used by
            %sqw&dnd objects. Has to be written in close cunjunction with
            %cut_sqw using deep understanding of the ways memory is allocated
            % within sqw objects
            [urange_step_pix_recent, ok, ix, s, e, npix, npix_retain,success]=...
                accumulate_cut_(this,v,s,e,npix,pax,ignore_nan,ignore_inf,keep_pix,n_threads);
        end
        
        %
    end
end
