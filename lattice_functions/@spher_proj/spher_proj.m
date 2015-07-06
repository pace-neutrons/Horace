classdef spher_proj<aprojection
    % Class defines spherical coordinate projection, used by cut_sqw 
    % to make spherical cuts 
    %
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
        ex; %[1x3] Vector of axis in spherical coordinate system, 
           % where azimuthal angle phi is caunted from (r.l.u.)
        ez; %[1x3] Vector of axis in spherical coordinate system 
           % where polar angle theta is caunted from (r.l.u.)
        ucentre; % [1x3] vector,defining of the centre of spherical projection
        type; %='a' units of r;
        uoffset; %=[0,0,0,0];
        lab     %={'\ro','\theta','\phi','E'};
        %
        alatt
        angdeg
    end
    properties(Access=private)
        alatt_=[1,1,1];
        angdeg_= [90,90,90];
        %
        ex_ = [1,0,0]
        ez_ = [0,0,1]   
        ucentre_ = [0,0,0]
        type_ = 'a'
        %------------------------------------
        data_u_to_rlu_ = eye(3);
        data_uoffset_  = [0;0;0;0]
        data_ulen_     = [1,1,1,1];
        data_upix_to_rlu_ = eye(3);
        data_upix_offset_ = [0;0;0;0] %upix_offset;
        data_lab_ = ['qx','qy','qz','en'];
    end
    
    methods
        function proj=spher_proj(varargin)
            proj = proj@aprojection();
            if nargin>0
                proj.ucentre = varargin{1};
            end
        end
        %
        function u = get.ex(this)
            u = this.ex_;
        end
        function v = get.ez(this)
            v=this.ez_;
        end
        %
        function cntr = get.ucentre(this)
            cntr=this.ucentre_;
        end
        function this = set.ucentre(this,value)
            if numel(value)~=3
                error('SPHER_PROJ:invalid_argument','Projection centre has to be a 3-element vector')
            end
            this.ucentre_ = value;
        end
        
        
        function type = get.type(this)
            type = this.type_;
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
        %------------------------------------------------------------------
        % Particular implementation of aprojection abstract interface
        %------------------------------------------------------------------       
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
        %
        
        %
        function this = set_proj_ranges(this,ustep,urange_step,urange_offset)
            % urange_step -- number of bin in every cut direction
            % ustep -- step size in each cut direction
            this.usteps = ustep;
            this.urange_step = urange_step;
            this.urange_offset = urange_offset;
            
        end
        %
        function [nbinstart,nbinend] = get_nbin_range(this,urange,nelmts,varargin)
            % Get range of grid bin indexes, which may contribute into the final
            % cut.
            [nbinstart,nbinend] = get_nrange_proj_section_(this,urange,nelmts,varargin{:});
        end
        %
        function [indx,ok] = get_contributing_pix_ind(this,v)
            % get list of indexes contributing into the cut
            [indx,ok] = get_contributing_pix_ind_(this,v);
        end
        %
        function [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param(this,data_in,pax)
            % get projection parameters, necessary for properly definind a sqw or dnd object
            %
            [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param_(this,data_in,pax);
        end
        %
        %
    end
end
