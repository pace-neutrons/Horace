classdef spher_proj<aprojection
    % Class defines spherical coordinate projection, used by cut_sqw
    % to make spherical cuts
    %
    %
    % $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
    %
    properties(Dependent)
        ex; %[1x3] Vector of axis in spherical coordinate system,
        % where azimuthal angle phi is caunted from (r.l.u.)
        ez; %[1x3] Vector of axis in spherical coordinate system
        % where polar angle theta is caunted from (r.l.u.)
        ucentre; % [3x1] vector,defining of the centre of spherical projection
        type; %='r' units of r;
        lab     %={'\ro','\theta','\phi','E'};
        %
    end
    properties(Access=private)
        %
        ex_ = 'u-aligned'
        ez_ = 'w-aligned'
        ucentre_ = [0;0;0]
        type_ = 'rdd' % rlu, degree, degree
        %------------------------------------
    end
    
    methods
        function proj=spher_proj(varargin)
            proj = proj@aprojection();
            if nargin>0
                proj.ucentre = varargin{1};
            end
            proj.data_lab_ = {'\theta','\phi','\ro','En'};
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
            if all(size(value) == [1,3])
                this.ucentre_ = value';
            else
                this.ucentre_ = value;
            end
            
        end
        
        
        function type = get.type(this)
            type = this.type_;
        end
        
        function lab = get.lab(this)
            lab = this.data_lab_;
        end
        
        %------------------------------------------------------------------
        % Particular implementation of aprojection abstract interface
        %------------------------------------------------------------------
        function urange_out = find_max_data_range(this,urange_in)
            % find the whole range of input data which may contribute
            % into the result.
            % urange_in -- the range of the data in initial coordinate
            % system.
            urange_out  = find_ranges_(this,urange_in);
        end
        function [istart,iend,irange,inside,outside] =get_irange_proj(this,urange,varargin)
            % Get range of grid bin indexes, which may contribute into the final
            % cut.
            [istart,iend,irange,inside,outside] = get_irange_proj_(this,urange,varargin{:});
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
