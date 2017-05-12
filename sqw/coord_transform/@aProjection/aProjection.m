classdef aProjection
    % Abstract class, defining interface using by cut_sqw
    % when transforming pixels from original to the cut's coordinate
    % system
    %
    %
    % Also defines generic operations on sqw object, which may be useful
    % and can be used by any projection class.
    %
    % Usage:  (as part of overloaded child class, which defines abstract
    %          methods present within this class)
    % proj = aProjection(); % build empty projection
    %
    % proj = aProjection(grid_size_in,data_range,[projaxes_data])
    % grid_size_in -- Initial number of bins in each direction.
    %                 (scalar, or [1 x nd] array)
    % data_range   -- the ranges of the empty projections
    %
    % optional:
    % projaxes_data:  data necessary to define projaxes, see the
    %                 projaxes class constructor interface for the details.
    %                 By default generates orthogonal projaxes with [1,0,0]
    %                 [0,1,0] main axis.
    
    
    % $Revision: 1462 $ ($Date: 2017-04-04 13:04:12 +0100 (Tue, 04 Apr 2017) $)
    %
    properties(Dependent)
        %---------------------------------
        %         % step sizes in every projection directions
        %         usteps
        %         % data ranges in new coordinate system in units of steps in each
        %         % direction
        %         urange_step;
        %         % shift of the projection centre
        %         urange_offset;
        
        % 4D array, describing the extent of the pixels region, this projection covers;
        urange;
        % 4D array, describing the region the projection covers
        img_range
        % 4D vector providing offset of the pixels region covered by the
        % projection vrt the pixels 0 value;
        uoffset
        
        % 4-element vector describing full data binning in each direction
        grid_size
        % indexes of image' integrated axis;
        iax;
        % the integration ranges per each intergated axis
        iax_range;
        % cellarray of axis.
        p;
        %TODO: u,v,w --> may be worth displaying these vectors or their
        %orts as sighn of axis directrions above (what about non-4D cuts?)
        %
        % cellarray of labels for axis
        labels;
        
        % property specifies if 2D or 3D picture, build out of this projection
        % data, changes aspect ration according to aspect ratio
        % of the data along axes
        changes_aspect_ratio;
        
        % property, containing projaxes class instance with information on
        % q-axes directions in q space, and interface to set up these
        % directions
        proj_axes;
    end
    %----------------------------------------------------------------------
    properties(Access=protected)
        %u_to_rlu_ = eye(3);
        %alatt_=[1,1,1];
        %angdeg_= [90,90,90];
        %------------------------------------
        uoffset_  = [0;0;0;0] %Offset of origin of projection axes wrt pix data
        % in A^(-1) and energy
        % former in r.l.u. and energy ie. [h; k; l; en] [column vector]
        %  u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
        % input data projection axis
        iax_=zeros(1,0);
        pax_=zeros(1,0);
        dax_=zeros(1,0);
        iint_=zeros(2,0);
        p_=cell(1,0);
        % initial data range
        pix_urange_;
        % the size of the image grid
        grid_size_;
        %------------------------------------
        projaxes_=projaxes();
        
        % internal property, which defines if appropriate picture changes
        % aspect ratio of a 2D image.
        changes_aspect_ratio_=true;
        img_range_cash_ = [];
    end
    properties(Constant,Access=private)
        % list of transitional properties used for storing/restoring
        % projection from sqw files written in version 3.1 and lower.
        old_interf_fields_ = {'uoffset','ulen','ulabel','iax','iint',...
            'pax','p','dax','urange'};
    end
    
    methods
        function proj=aProjection(varargin)
            % Generic projection
            % usage:
            % proj = aProjection(); % build empty projection
            %
            % proj = aProjection(grid_size_in,data_range,[projaxes interface])
            % grid_size_in -- Initial number of bins in each direction.
            %                 (scalar, or [1 x nd] array)
            % data_range   -- the ranges of the empty projections
            % optional:
            % projaxes interface:  data necessary to define projaxes, see the
            %                      projaxes class interface for the details.
            
            %
            if nargin == 0
                return
            else
                proj = proj_constructor_(proj,varargin{:});
            end
        end
        %------------------------------------------------------------------
        % public interface:
        %Bin pixels expressed in orthogonal coordinate system into 4D grid,
        % defined by aProjection
        [s,e,npix,pix,pix_range] = sort_pixels_by_bins(obj,pix,varargin);
        % Get titling and caption information for the projection, specified
        [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] =...
            data_plot_titles(this,filename)
        % Calculate the range of the transformed transformed data given the
        % pixels range.
        range = calc_image_range(obj,minmax_val);
        
        %
        function flds = get_old_interface_fields(obj)
            % retrieve field names used to support old sqw object interface
            flds  = obj.old_interf_fields_;
        end
        % fill object structure from old interface data. Used for
        % restoring data stored in old data formats
        obj = set_from_old_interface(obj,old_struct)
        
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
        %
        %         function usteps = get.usteps(this)
        %             usteps = this.usteps_;
        %         end
        %         %
        %         function urange_step = get.urange_step(this)
        %             % Get limits of cut expressed in the units of bin size in each
        %             % direction
        %             urange_step = this.urange_step_;
        %         end
        %         function urange_offset= get.urange_offset(this)
        %             urange_offset = this.urange_offset_;
        %         end
        function lab  = get.labels(obj)
            lab = obj.projaxes_.lab;
        end
        %
        function pax = get.p(obj)
            pax = obj.p_(obj.pax_);
        end
        
        function obj  = set.labels(obj,val)
            if ~iscell(val) || numel(val) ~= 4
                error('APROJECTION:invalid_argument',...
                    'labels should be set up by using 4-ement cellarray of labels')
            end
            if size(val,2) == 1
                val = val';
            end
            obj.projaxes_.lab = cellfun(@num2str,val,'UniformOutput',false);
        end
        %
        function urange = get.urange(obj)
            urange = obj.pix_urange_;
        end
        function hkl_range = get.img_range(obj)
            hkl_range = obj.img_range_cash_;
        end
        function iax = get.iax(obj)
            iax  = obj.iax_;
        end
        function iax_range = get.iax_range(obj)
            iax_range= obj.urange(:,obj.iax);
        end
        function nbin = get.grid_size(obj)
            nbin = obj.grid_size_;
        end
        function change=get.changes_aspect_ratio(this)
            change = this.changes_aspect_ratio_;
        end
        function uof=get.uoffset(obj)
            uof = obj.uoffset_;
        end
        %
        function obj = set.uoffset(obj,val)
            obj = check_and_set_uoffset_(obj,val);
        end
        
        function obj = set.proj_axes(obj,val)
            if ~isa('projaxes',val)
                error('APROJECTION:invalid_argument',...
                    'proj_axes property can be assigned with projaxes object only');
            end
            obj.projaxes_ = val;
            
        end
        function prax = get.proj_axes(obj)
            prax = obj.projaxis_;
        end
        
        %-----------------------------------------------------------------
        % old (virtual?) interface support:
        function pax = get_pax(obj)
            pax = obj.pax_;
        end
        function dax = get_dax(obj)
            dax = obj.dax_;
        end
        %
    end
    %
    %    methods(Access = protected)
    %         function [nbin_in,pin]= get_input_data_binning_(this)
    %             % input data binning how data are initially binned, and full
    %             % data projection axis
    %             %
    %             % auxiliary variable derived from input data projection axis
    %             pin=cell(1,4);
    %             pin(this.data_pax_)=this.data_p_;
    %             pin(this.data_iax_)=mat2cell(this.urange_(:,this.data_iax_),2,ones(1,length(this.data_iax_)));
    %             nbin_in=zeros(1,4);
    %             for i=1:4
    %                 nbin_in(i)=length(pin{i})-1;
    %             end
    %         end
    %    end
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
        % convert array of data expressed in crystal Cartesian system (lab
        % frame) into the array of data in image coordinate system
        img_coord = pix_to_img(obj,pix_coord);
        % convert array of data expressed in projection coordinate system
        % into the array of data in crystal Cartesian system (lab frame)
        pix_coord = img_to_pix(obj,img_coord);
        
        %         urange_out = find_max_data_range(this,urange_in);
        %         % find the whole range of input data which may contribute
        %         % into the result.
        %
        %         [istart,iend,irange,inside,outside] = get_irange_proj(this,urange,varargin);
        %         % Get ranges of bins that partially or wholly lie inside an n-dimensional shape,
        %         % defined by projection limits.
        %         [indx,ok] = get_contributing_pix_ind(this,v);
        %         % get list of pixels indexes contributing into the cut
        %         %
        %         [uoffset,ulabel,dax,u_to_rlu,ulen,title_function] = get_proj_param(this,data_in,pax);
        %         % get projection parameters, necessary for properly definind a sqw
        %         % or dnd object from the projection
    end
end
