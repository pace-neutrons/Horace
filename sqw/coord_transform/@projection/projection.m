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
    % $Revision$ ($Date$)
    %
    properties
        %
    end
    properties(Dependent)
        u; %[1x3] Vector of first axis (r.l.u.)
        v; %[1x3] Vector of second axis (r.l.u.)
        w; %[1x3] Vector of third axis (r.l.u.) - used only if third character of type is 'p'
        type; %='rrr';
        
        u_to_rlu
        %
        %
    end
    properties(Access=private)
        %
        u_to_rlu_ = eye(4); %  Matrix (4x4) of projection axes in hkle representation
        %
    end
    methods(Access = protected)
    end
    
    methods
        function proj=projection(varargin)
            proj = proj@aProjection(varargin{:});
            %             if nargin==0 % return defaults
            %                 %proj.projaxes_ = [];
            %             else
            %                 if isa(varargin{1},'projaxes')
            %                     proj.projaxes_ = varargin{1};
            %                 else
            %                     proj.projaxes_ = projaxes(varargin{:});
            %                 end
            %             end
        end
        
        function u = get.u(this)
            u = this.projaxes_.u;
        end
        function v = get.v(this)
            v = this.projaxes_.v;
        end
        function w = get.w(this)
            w = this.projaxes_.w;
        end
        function type = get.type(this)
            type = this.projaxes_.type;
            
        end
        function this =set.type(this,val)
            this.projaxes_.type = val;
        end
        function tr_mat = get.u_to_rlu(this)
            tr_mat = this.u_to_rlu_;
        end
        function this= set.u_to_rlu(this,val)
            % TODO: change in projaxes type should affect the projection
            % matrix, but here we assume that the matrix is already
            % normalized correctly
            this = check_and_set_transf_matr_(this,val);
            % clear precalculate image range, as the transformation to
            % image has been changed
            this.img_range_cash_  = [];
        end
        %------------------------------------------------------------------
        function img_coord = pix_to_img(obj,pix_coord)
            % convert pixels coordinates into image coordinates expressed
            % in appropriate units.
            img_coord = convert_pix_to_img_(obj,pix_coord);
        end
        function pix_coord = img_to_pix(obj,img_coord)
            % convert array of data expressed in projection coordinate system
            % into the array of data in crystal Cartesian system (lab frame)
            pix_coord = convert_img_to_pix_(obj,img_coord);
        end
        
        
        %------------------------------------------------------------------
        % Particular implementation of aProjection abstract interface
        %------------------------------------------------------------------
        function urange_out = find_max_data_range(this,urange_in)
            % find the whole range of input data which may contribute
            % into the result.
            % urange_in -- the range of the data in initial coordinate
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
        function [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param(this,data_in,pax)
            % get projection parameters, necessary for properly defining a sqw or dnd object
            %
            [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param_(this,data_in,pax);
            
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
