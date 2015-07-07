classdef aprojection
    %  Abstract class, defining interface using by cut_sqw
    %  when transforming pixels from original to cut's coordinate system
    %
    % Also defines generic operations on sqw object, which may be useful
    % for any projection classes.
    properties(Dependent)
        % is special mex routines, written for performance reason and as such
        % deeply embedded with cut_sqw objects  are availible for given
        % projection type
        can_mex_cut; %false
        % can projection retain pixels so that further cuts can be made
        % from the results of projection. E.g. one can make subsequent cuts
        % from a
        can_keep_pixels; %false;
        %
        % Convenience function, providing commin interface to projection
        % data
        alatt
        angdeg
        
    end
    properties(Access=protected)
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
    
    methods
        function proj=aprojection(varargin)
        end
        
        function can_mex_cut = get.can_mex_cut(self)
            % generic projection can not run mex code
            can_mex_cut  = can_mex_cut_(self);
        end
        function can_retain_pixels = get.can_keep_pixels(self)
            % generic projection can not apply one cut after another, so
            % keeping pixels is prohibited by default
            can_retain_pixels = can_keep_pixels_(self);
        end
        %------------------------------------------------------------------
        % Common interface to projection data
        %------------------------------------------------------------------
        function this=retrieve_existing_tranf(this,data)
            % Retrieve all parameters for transformation already
            % defined over sqw data
            this = set_data_transf_(this,data);
        end
        function alat = get.alatt(this)
            alat = this.alatt_;
        end
        function angl = get.angdeg(this)
            angl = this.angdeg_;
        end
    end
    %
    methods(Access = protected)
        function isit= can_mex_cut_(self)
            isit = false;
        end
        function isit= can_keep_pixels_(self)
            isit = false;
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
    methods(Abstract)
        this = set_proj_ranges(this,ustep,urange_step,urange_offset);
        % urange_step -- number of bin in every cut direction
        % ustep -- step size in each cut direction
        urange_out = find_maximal_data_range(this,urange_in);
        %
        [istart,iend,irange,inside,outside] = get_irange_proj(this,urange,varargin);
        % Get ranges of bins that partially or wholly lie inside an n-dimensional rectange,
        % where the first three dimensions can be rotated and translated w.r.t. the
        % cuboid that is split into bins.       
        [indx,ok] = get_contributing_pix_ind(this,v);
        % get list of indexes contributing into the cut
        [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param(this,data_in,pax);
        % get projection parameters, necessary for properly definind a sqw or dnd object
        %
    end
end
