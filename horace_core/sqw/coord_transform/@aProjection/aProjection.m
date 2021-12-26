classdef aProjection < serializable
    %  Abstract class, defining interface and common properties used for
    %  transforming pixels from crystal Cartesian
    %  to the coordinate system defined by sqw image (dnd-object)
    %  and vice-versa.
    %
    % Common (non-virtual) properties
    %  alatt       3-element vector, containing lattice parameters
    %  angdeg      3-element vector, containing lattice angles
    %
    %   offset     Row or column vector of offset of origin of a projection axes (rlu)
    %
    %   lab         Short labels for u1,u2,u3,u4 as cell array
    %               e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
    %                   *OR*
    %   lab1        Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
    %   lab2        Short label for u2 axis
    %   lab3        Short label for u3 axis
    %   lab4        Short label for u4 axis (e.g. 'E' or 'En')
    
    properties(Dependent)
        %---------------------------------
        % the lattice parameters
        alatt
        % angles between the lattice edges
        angdeg
        %---------------------------------
        %TODO: Will be refactored to axes_caption and transferred to axes
        %block?
        lab
        
        %Offset of origin of the projection in r.l.u. and energy ie. [h; k; l; en] [row vector]
        offset;
        %
        % the target projection, used by cut to transform from
        % source to target coordinate system
        targ_proj
    end
    properties
        pix_to_rlu
    end
    properties(Constant, Access=private)
        fields_to_save_ = {'alatt','angdeg','lab','offset'}
    end
    properties(Constant, Access=protected)    
        % minimal value of a vector norm e.g. how close couple of vectors
        % should be to be considered parallel u*v are orthogonal if u*v'<tol
        % or what vector should be consigdered a
        % null vector (e.g. abs([9.e-13,0,0,0]) will be converted to [0,0,0,0]
        % at setup
        tol_=1e-12;
    end
    %----------------------------------------------------------------------
    properties(Access=protected)
        alatt_=[1,1,1];
        angdeg_= [90,90,90];
        %------------------------------------
        %  u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
        offset_  = [0,0,0,0] %Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
        %
        labels_={'Q_h','Q_k','Q_l','En'};
        %
        % target projection holder
        targ_proj_;
    end
    
    methods
        function [obj,par]=aProjection(varargin)
            % aProjection constructor.
            %
            % Accepts any combination (including empty) of aProjection 
            % class properties containing setters in the form:
            % {property_name1, value1, property_name2, value2....}
            %
            % Returns:
            %
            % obj  -- Instance of aProjection class
            % par  -- if input arguments contains key-value pairs, which do
            %         not describe aProjection class, the output contains
            %         cellarray of such parameters. Empty, if all inputs
            %         define the projecton parameters.
            if nargin == 0
                par = {};
                return;
            end
            [obj,par] = init(obj,varargin{:});
        end
        function [obj,par] = init(obj,varargin)
            % Method to initialize empty constructor
            % Inputs:
            % A combination (including empty) of aProjection 
            % class properties containing setters in the form:
            % {property_name1, value1, property_name2, value2....}            
            % Returns:
            % obj  -- Initialized instance of aProjection class
            % par  -- if input arguments contains key-value pairs, which do
            %         not describe aProjection class, the output contains
            %         cellarray of such parameters. Empty, if all inputs
            %         define the projecton parameters.
            % 
            [obj,par] = init_(obj,varargin{:});
        end
        
        %------------------------------------------------------------------
        %
        %------------------------------------------------------------------
        function [npix,s,e,pix_data] = bin_pixels(obj,axes_block,pix_data,npix,s,e,varargin)
            % Convert pixels into the coordinate system, defined by the
            % projection and bin them into the coordinate system, defined
            % by the axes block, specified as input
            % 
            pix_transformed = obj.transform_pix_to_img(pix_data);
            [npix,s,e,pix_data]=axes_block.bin_pixels(pix_transformed,...
                npix,s,e,varargin{:});
        end
        function [bl_start,bl_size] = get_nrange(obj,npix,cur_axes_block,targ_proj,targ_axes_block)
            % return the bin numbers (from/to) which pixels may contribute
            % to the final cut
            %
            % Generic (less efficient) implementation
            
            targ_proj.targ_proj = obj;
            obj.targ_proj = targ_proj;
            % Get the hypercube, which describes the one step of binning
            % of the current coordinate axes grid
            ch_cube = cur_axes_block.get_axes_scales();
            % and convert it into the target lattice
            trans_chcube = obj.from_cur_to_targ_coord(ch_cube);
            
            % get all nodes belonging to target axes block, doing the
            % binning with the bin size, slightly smaller then the current
            % lattice size
            bin_nodes = targ_axes_block.get_bin_nodes(trans_chcube);
            % convert these notes to the coordinate system, described by
            % the existing projection
            nodes_here = targ_proj.from_cur_to_targ_coord(bin_nodes);
            % bin target nodes on the current lattice
            nbin_in_bin = cur_axes_block.bin_pixels(nodes_here);
            %
            % identify cell numbers containing nodes
            cell_num = 1:numel(nbin_in_bin);
            ncell_contrib = cell_num(nbin_in_bin>0);
            if isempty(ncell_contrib)
                bl_start  = [];
                bl_size = [];
                return;
            end
            % compress indexes of сontributing cells into bl_start:bl_start+bl_size-1 form
            % good for filebased but bad for arrays
            adjacent= ncell_contrib(1:end-1)+1==ncell_contrib(2:end);
            adjacent = [false,adjacent];
            adj_end  = [ncell_contrib(1:end-1)+1<ncell_contrib(2:end),true];
            bin_start = [0,cumsum(reshape(npix,1,numel(npix)))]+1;
            bl_start  = bin_start(ncell_contrib(~adjacent));
            bl_size   = bin_start(ncell_contrib(adj_end))-bl_start+1;
        end
        %------------------------------------------------------------------
        function pix_target = from_cur_to_targ_coord(obj,pix_origin,varargin)
            % Converts from current to target projection coordinate system.
            % Can be overloaded to optimize for a particular case to
            % improve efficiency.
            % (e.g. two orthogonal projections do shift and rotation
            % as the result, so worth combining them into one operation)
            % Inputs:
            % obj       -- current projection, describing the system of
            %              coordinates where the input pixels vector is
            %              expressed in. The target projection has to be
            %              set up
            %
            % pix_origin   4xNpix vector of pixels coordinates expressed in
            %              the coordinate system, defined by current
            %              projection
            targproj = obj.targ_proj;
            if isempty(targproj)
                error('HORACE:aProjection:runtime_error',...
                    'Target projection property has to be set up to convert to target coordinate system')
            end
            pic_cc = obj.transform_img_to_pix(pix_origin,varargin{:});
            pix_target  = targproj.transform_pix_to_img(pic_cc,varargin{:});
        end
        
        %------------------------------------------------------------------
        % Common interface to projection data
        %------------------------------------------------------------------
        % build the binning and axis for the coordinate system related to cut
        %[iax, iint, pax, p, img_db_range_out] = calc_transf_img_bins (proj,img_db_range_in,pbin, pin, en)
        % Check that the binning arguments are valid, and update the projection
        % with the current bin values
        %[proj_update,pbin_update,ndims,pin,en] = update_pbins (proj, header_ave, data, pbin)
        
        % Check binning descriptors are valid, and resolve multiple integration axes
        % using limits and bin widths from the input data.
        %[ pbin_out, ndims] = calc_pbins(proj, img_db_range_in, pbin, pin, en)
        
        %
        %         function obj=retrieve_existing_tranf(obj,data,upix_to_rlu,upix_offset)
        %             % Retrieve all parameters for transformation already
        %             % defined over sqw data and store them in projection to
        %             % use later to calculate new transformation.
        %             obj = set_data_transf_(obj,data,upix_to_rlu,upix_offset);
        %         end
        %         function obj = set_proj_binning(obj,new_img_db_range,prj_ax_ind,int_ax_ind,prj_ax_bins)
        %             %   new_range   Array of limits of data that can possibly contribute to the output data structure in the
        %             %               coordinate frame of the output structure [2x4].
        %             %   prj_ax_ind  Index of plot axes into the projection axes  [row vector]
        %             %               e.g. if data is 3D, data.pax=[1,3,4] means u1, u3, u4 axes are x,y,z in any plotting
        %             %   int_ax_ind  Index of integration axes into the projection axes  [row vector]
        %             %                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
        %             %   prj_ax_bins  Cell array containing bin boundaries along the plot axes [column vectors]
        %             %               i.e. data.p{1}, data.p{2} ... (for as many plot axes as given by length of prj_ax_ind)
        %             %
        %             %
        %             obj = obj.set_proj_binning_(new_img_db_range,prj_ax_ind,int_ax_ind,prj_ax_bins);
        %         end
        
        %------------------------------------------------------------------
        % accessors
        %------------------------------------------------------------------
        function alat = get.alatt(obj)
            alat = obj.alatt_;
        end
        function obj = set.alatt(obj,val)
            % set lattice parameters as single value, defining 3 equal
            % parameters or vector of 3 different lattice parameters
            %
            % The parameters expected to be in A
            %
            obj = check_and_set_alatt(obj,val);
        end
        %
        function angl = get.angdeg(obj)
            angl = obj.angdeg_;
        end
        function obj = set.angdeg(obj,val)
            % set lattice parameters as single value, defining 3 equal
            % lattice angles or vector of 3 different lattice angles
            %
            % All angles are in degrees.
            %
            obj = check_and_set_andgdeg(obj,val);
        end
        %
        function lab=get.lab(obj)
            lab = obj.labels_;
        end
        function obj=set.lab(obj,val)
            obj = check_and_set_labels_(obj,val);
        end
        %
        function uoffset = get.offset(this)
            uoffset = this.offset_;
        end
        function obj = set.offset(obj,val)
            obj = check_and_set_uoffset_(obj,val);
        end
        %
        function proj = get.targ_proj(obj)
            proj = obj.targ_proj_;
        end
        function obj = set.targ_proj(obj,val)
            if ~isa(val,'aProjection')
                error('HORACE:aProjection:invalid_argument',...
                    'only member of aProjection family can be set up as target projection. Attempted to use: %s',...
                    evalc('disp(type(val))'))
            end
            obj.targ_proj_ = val;
        end
        %------------------------------------------------------------------
        %
        %
        % Temporary method, here until projection is refactored
        % will belong to another projection or become a property
        % Ticket #34(https://github.com/pace-neutrons/Horace/issues/34)
        function upix_to_rlu = get_data_pix_to_rlu(obj)
            upix_to_rlu = obj.data_upix_to_rlu_;
        end
        % Temporary method, here unil projection is refactored
        % will belong to another projection or become a property
        % Ticket #34(https://github.com/pace-neutrons/Horace/issues/34)
        %         function obj = set_data_pix_to_rlu(obj,data_upix_to_rlu)
        %             obj.data_upix_to_rlu_ = data_upix_to_rlu;
        %         end
        %------------------------------------------------------------------
        % Serializable interface
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = indepFields(obj)
            flds = obj.fields_to_save_;
        end
    end
    %
    methods(Access = protected)
        %
        function isit= can_mex_cut_(~)
            isit = false;
        end
        function obj = check_and_set_alatt(obj,val)
            obj.alatt_ = check_alatt_return_standard_val_(obj,val);
        end
        function obj = check_and_set_andgdeg(obj,val)
            obj.angdeg_ = check_angdeg_return_standard_val_(obj,val);
        end
        function [nbin_in,pin]= get_input_data_binning_(obj)
            % input data binning how data are initially binned, and full
            % data projection axis
            %
            % auxiliary variable derived from input data projection axis
            pin=cell(1,4);
            pin(obj.data_pax_)=obj.data_p_;
            pin(obj.data_iax_)=mat2cell(obj.new_img_db_range_(:,obj.data_iax_),2,ones(1,length(obj.data_iax_)));
            nbin_in=zeros(1,4);
            for i=1:4
                nbin_in(i)=length(pin{i})-1;
            end
        end
    end
    methods(Static)
        %
        function [irange,inside,outside] = get_irange(urange,varargin)
            % Get ranges of bins that partially or wholly lie inside an n-dimensional rectangle
            %
            %   >> irange = get_irange(urange,p1,p2,p3,...pndim)
            %   >> [irange,inside,outside] = get_irange(urange,p1,p2,p3,...pndim)
            %
            % Works for an arbitrary number of dimensions ndim (ndim>0), and with
            % non-uniformly spaced bin boundaries.
            %
            % Input:
            % ------
            %   urange  Range to cover: array size [2,ndim] of [urange_lo; urange_hi]
            %          where ndim is the number of dimensions. It is required that
            %          urange_lo <=urange_hi for each dimension
            %   p1      Bin boundaries along first axis (column vector)
            %   p2      Similarly axis 2
            %   p3      Similarly axis 3
            %    :              :
            %   pndim   Similarly axis ndim
            %           It is assumed that each array of bin boundaries has
            %          at least two values (i.e. at least one bin), and that
            %          the bin boundaries are monotonic increasing.
            %
            % Output:
            % -------
            %   irange  Bin index range: array size [2,ndim]. If the region defined by
            %          urange lies fully outside the bins, then irange is set to zeros(0,ndim)
            %          i.e. isempty(irange)==true.
            %   inside  If the range defined by urange is fully contained within
            %          the bin boundaries, then contained==true. Otherwise,
            %          inside==false.
            %   outside If the range defined by urange is fully outside the bin
            %          boundaries i.e. there is no intersection of the two volumes,
            %          then outside=true;
            [irange,inside,outside] = get_irange_(urange,varargin{:});
        end
        %
        %         function [nstart,nend] = get_nrange(nelmts,irange)
        %             % Get contiguous ranges of an array for a section of the binning array
        %             %
        %             % Given an array containing number of points in bins, and a section of
        %             % that array, return column vectors of the start and end indicies of
        %             % ranges of contiguous points in the column representation of the points.
        %             % Works for any dimensionality 1,2,...
        %             %
        %             %   >> [nstart,nend] = get_nrange(nelmts,irange)
        %             %
        %             % Input:
        %             % ------
        %             %   nelmts      Array of number of points in n-dimensional array of bins
        %             %              e.g. 3x5x7 array such that nelmts(i,j,k) gives no. points in
        %             %              the (i,j,k)th bin. If the number of dimensions defined by irange,
        %             %              ndim=size(irange,2), is greater than the number of dimensions
        %             %              defined by nelmts, n=numel(size(nelmts)), then the excess
        %             %              dimensions required of nelmts are all assumed to be singleton
        %             %              following the usual matlab convention.
        %             %   irange      Ranges of section [irange_lo;irange_hi]
        %             %              e.g. [1,2,6;3,4,7] means bins 1:3, 2:4, 6:7 along the three
        %             %              axes. Assumes irange_lo<=irange_hi.
        %             % Output:
        %             % -------
        %             %   nstart      Column vector of starting values of contiguous blocks in
        %             %              the array of values with the number of elements in a bin
        %             %              given by nelmts(:).
        %             %   nend        Column vector of finishing values.
        %             %
        %             %               nstart and nend have column length zero if there are no
        %             %              elements i.e. have the value zeros(0,1).
        %             [nstart,nend] = get_nrange_(nelmts,irange);
        %         end
        %
        function [nstart,nend] = get_nrange_4D(nelmts,istart,iend,irange)
            % Get contiguous ranges of an array for a section of the binning array
            %
            % Given an array containing number of points in bins, contiguous bin ranges
            % for the first three dimensions and a section of the array for the
            % remaining dimensions, return column vectors of the start and end indicies of
            % ranges of contiguous points in the column representation of the points.
            % Works for any dimensionality 3,4,...
            %
            %   >> [nstart,nend] = get_nrange(nelmts,irange)
            %
            % Input:
            % ------
            %   nelmts      Array of number of points in n-dimensional array of bins
            %              e.g. 3x5x7 array such that nelmts(i,j,k) gives no. points in
            %              the (i,j,k)th bin. If the number of dimensions defined by irange,
            %              ndim=size(irange,2), is greater than the number of dimensions
            %              defined by nelmts, n=numel(size(nelmts)), then the excess
            %              dimensions required of nelmts are all assumed to be singleton
            %              following the usual matlab convention.
            %   istart      Column vector of indicies of the start of contiguous ranges
            %              within the first three dimensions.
            %   iend        Column vector of indicies of the end of contiguous ranges
            %              within the first three dimensions.
            %   irange      Ranges of section [irange_lo;irange_hi] for the 4th and higher
            %              dimensions e.g. [1,2,6;3,4,7] means bins 1:3, 2:4, 6:7 along
            %              the 3rd,4th,5th axes. Assumes irange_lo<=irange_hi. If only
            %              three axes, then irange should be empty.
            %
            % Output:
            % -------
            %   nstart      Column vector of starting values of contiguous blocks in
            %              the array of values with the number of elements in a bin
            %              given by nelmts(:).
            %   nend        Column vector of finishing values.
            %
            %               nstart and nend have column length zero if there are no
            %              elements i.e. have the value zeros(0,1).
            
            [nstart,nend] = get_nrange_4D_(nelmts,istart,iend,irange);
        end
    end
    %----------------------------------------------------------------------
    %  ABSTRACT INTERFACE
    %----------------------------------------------------------------------
    methods(Abstract)
        % find the whole range of input data which may contribute
        % into the result.
        % urange_out = find_old_img_range(obj,urange_in);
        
        
        %         % Get ranges of bins that partially or wholly lie inside an n-dimensional shape,
        %         % defined by projection limits.
        %         [istart,iend,irange,inside,outside] = get_irange_proj(obj,urange,varargin);
        %
        %         % get list of pixels indexes contributing into the cut
        %         [indx,ok] = get_contributing_pix_ind(obj,v);
        %
        %         % get projection parameters, necessary for properly definind a sqw
        %         % or dnd object from the projection        %
        %         [uoffset,ulabel,dax,u_to_rlu,ulen,title_function] = get_proj_param(obj,data_in,pax);
        %
        % Transform pixels expressed in crystal cartezian coordinate systems
        % into image coordinate system
        pix_transformed = transform_pix_to_img(obj,pix_cc,varargin);
        % Transform pixels expressed in image coordinate coordinate systems
        % into crystal cartezian system
        pix_cc = transform_img_to_pix(obj,pix_transformed,varargin);
        
    end
    
end

