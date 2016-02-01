classdef aprojection
    %  Abstract class, defining interface using by cut_sqw
    %  when transforming pixels from original to the cut's coordinate
    %  system
    %
    % Also defines generic operations on sqw object, which may be useful
    % and can be used by any projection class.
    %
    % $Revision$ ($Date$)
    %
    properties(Dependent)
        % is special mex routines, written for performance reason and as such
        % deeply embedded with cut_sqw objects  are availible for given
        % projection type
        can_mex_cut; %false
        %---------------------------------
        %
        % Convenience function, providing commin interface to projection
        % data
        % the lattice parameters
        alatt
        % angles between the lattice edges
        angdeg
        %---------------------------------
        % step sizes in every projection directions
        usteps
        % data ranges in new coordinate system in units of steps in each
        % direction
        urange_step;
        % shift of the projection centre
        urange_offset;
        % indexes of projextion axis of the target progection
        target_pax
        %number of bins in the target projection
        target_nbin
    end
    %----------------------------------------------------------------------
    properties(Access=protected)
        alatt_=[1,1,1];
        angdeg_= [90,90,90];
        %------------------------------------
        data_u_to_rlu_ = eye(4); %  Matrix (4x4) of projection axes in hkle representation
        %  u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
        data_uoffset_  = [0;0;0;0] %Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
        data_ulen_     = [1,1,1,1]; %Length of projection axes vectors in Ang^-1 or meV [row vector]
        data_upix_to_rlu_ = eye(3);
        data_upix_offset_ = [0;0;0;0] %upix_offset;
        data_lab_ = ['qx','qy','qz','en'];
        % input data projection axis
        data_iax_=zeros(1,0);
        data_pax_=zeros(1,0);
        data_iint_=zeros(2,0);
        data_p_=cell(1,0);
        % initial data range
        data_urange_;
        %------------------------------------
        % Transformed coordinates
        urange_;
        usteps_ = [1,1,1,1];
        % data ranges in new coordinate system in units of steps in each
        % direction
        urange_step_ =zeros(2,4);
        % shift of the projection centre
        urange_offset_ = zeros(1,4);
        %
        targ_pax_
        targ_iax_
        targ_p_
        
        pax_gt1_=[];
        nbin_gt1_=[];
    end
    
    methods
        function proj=aprojection(varargin)
        end
        
        function can_mex_cut = get.can_mex_cut(self)
            % generic projection can not run mex code
            can_mex_cut  = can_mex_cut_(self);
        end
        %------------------------------------------------------------------
        % Common interface to projection data
        %------------------------------------------------------------------
        function this=retrieve_existing_tranf(this,data,upix_to_rlu,upix_offset)
            % Retrieve all parameters for transformation already
            % defined over sqw data and store them in projection to
            % use later to calculate new transformation.
            this = set_data_transf_(this,data,upix_to_rlu,upix_offset);
        end
        function this = set_proj_binning(this,urange,prj_ax_ind,int_ax_ind,prj_ax_bins)
            %   urange      Array of limits of data that can possibly contribute to the output data structure in the
            %               coordinate frame of the output structure [2x4].
            %   prj_ax_ind  Index of plot axes into the projection axes  [row vector]
            %               e.g. if data is 3D, data.pax=[1,3,4] means u1, u3, u4 axes are x,y,z in any plotting
            %   int_ax_ind  Index of integration axes into the projection axes  [row vector]
            %                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
            %   prj_ax_bins  Cell array containing bin boundaries along the plot axes [column vectors]
            %               i.e. data.p{1}, data.p{2} ... (for as many plot axes as given by length of prj_ax_ind)
            %
            %
            this = this.set_proj_binning_(urange,prj_ax_ind,int_ax_ind,prj_ax_bins);
        end
        %------------------------------------------------------------------
        % accessors
        %------------------------------------------------------------------
        function alat = get.alatt(this)
            alat = this.alatt_;
        end
        %
        function angl = get.angdeg(this)
            angl = this.angdeg_;
        end
        %
        function usteps = get.usteps(this)
            usteps = this.usteps_;
        end
        %
        function urange_step = get.urange_step(this)
            % Get limits of cut expressed in the units of bin size in each
            % direction
            urange_step = this.urange_step_;
        end
        function urange_offset= get.urange_offset(this)
            urange_offset = this.urange_offset_;
        end
        function pax = get.target_pax(this)
            pax = this.pax_gt1_;
        end
        function nbin = get.target_nbin(this)
            nbin = this.nbin_gt1_;
        end
    end
    %
    methods(Access = protected)
        function isit= can_mex_cut_(self)
            isit = false;
        end
        function [nbin_in,pin]= get_input_data_binning_(this)
            % input data binning how data are initially binned, and full
            % data projection axis
            %
            % auxiliary variable derived from input data projection axis
            pin=cell(1,4);
            pin(this.data_pax_)=this.data_p_;
            pin(this.data_iax_)=mat2cell(this.urange_(:,this.data_iax_),2,ones(1,length(this.data_iax_)));
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
            %          boundaries i.e. there is no interstcion of the two volumes,
            %          then outside=true;
            [irange,inside,outside] = get_irange_(urange,varargin{:});
        end
        %
        function [nstart,nend] = get_nrange(nelmts,irange)
            % Get contiguous ranges of an array for a section of the binning array
            %
            % Given an array containing number of points in bins, and a section of
            % that array, return column vectors of the start and end indicies of
            % ranges of contiguous points in the column representation of the points.
            % Works for any dimensionality 1,2,...
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
            %   irange      Ranges of section [irange_lo;irange_hi]
            %              e.g. [1,2,6;3,4,7] means bins 1:3, 2:4, 6:7 along the three
            %              axes. Assumes irange_lo<=irange_hi.
            % Output:
            % -------
            %   nstart      Column vector of starting values of contiguous blocks in
            %              the array of values with the number of elements in a bin
            %              given by nelmts(:).
            %   nend        Column vector of finishing values.
            %
            %               nstart and nend have column length zero if there are no
            %              elements i.e. have the value zeros(0,1).
            [nstart,nend] = get_nrange_(nelmts,irange);
        end
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
    %  ABSTRACT INTERFACE -- use
    %----------------------------------------------------------------------
    methods(Abstract)
        urange_out = find_max_data_range(this,urange_in);
        % find the whole range of input data which may contribute
        % into the result.
        
        [istart,iend,irange,inside,outside] = get_irange_proj(this,urange,varargin);
        % Get ranges of bins that partially or wholly lie inside an n-dimensional shape,
        % defined by projection limits.
        [indx,ok] = get_contributing_pix_ind(this,v);
        % get list of pixels indexes contributing into the cut
        %
        [uoffset,ulabel,dax,u_to_rlu,ulen,title_function] = get_proj_param(this,data_in,pax);
        % get projection parameters, necessary for properly definind a sqw
        % or dnd object from the projection
    end
end
