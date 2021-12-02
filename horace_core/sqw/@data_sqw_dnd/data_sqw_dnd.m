classdef data_sqw_dnd < axes_block
    % Class defines structure of the data, used by sqw&dnd objects
    %
    % Trivial implementation, wrapping around a structure
    
    % Original author: T.G.Perring
    %
    properties(Dependent)
        pix;
    end
    properties
        %
        alatt   =[2*pi,2*pi,2*pi] % Lattice parameters for data field (Ang^-1)
        angdeg  =[90,90,90]% Lattice angles for data field (degrees)
        uoffset=[0;0;0;0]  %   Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
        u_to_rlu=eye(4)    %   Matrix (4x4) of projection axes in hkle representation
        %                   u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
        s=[]          %Cumulative signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
        e=[]          %Cumulative variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
        npix=[]       %No. contributing pixels to each bin of the plot axes.
        %             [size(data.pix)=(length(data.p1)-1, length(data.p2)-1, ...)]
        % The pixels are rebinned on this grid
        img_db_range=PixelData.EMPTY_RANGE_ % [Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf] -- convention if no pixels
        %
        % returns number of pixels, stored within the PixelData class
        num_pixels
    end
    properties(Constant)
        % the size of the border, used in gen_sqw. The img_db_range in gen_sqw
        % exceeds real pix_range (or input pix_range) by this value.
        border_size = -4*eps
    end
    properties(Constant,Access=private)
        fields_to_save_ = {'alatt','angdeg','uoffset',...
            'u_to_rlu','s','e','npix','img_db_range','pix'};
    end
    properties(Access=protected)
        pix_ = PixelData()      % Object containing data for each pixel
    end
    %
    methods
        function flds = indepFields(obj)
            % get independent fields, which fully define the state of a
            % serializable object.
            
            flds = indepFields@axes_block(obj);
            flds = [flds(:);data_sqw_dnd.fields_to_save_(:)];
        end
        
        %------------------------------------------------------------------
        % Determine data type of the data field of an sqw data structure
        data_type = data_structure_type(data);
        % Extract projection, used to build sqw file from full data_sqw_dnd
        % object (full-- containing pixels)
        proj = get_projection(obj)
         %------------------------------------------------------------------
        function obj = data_sqw_dnd(varargin)
            % constructor || copy-constructor:
            % Builds valid data_sqw_dnd object from various data structures
            %
            % Simplest constructor
            %   >> [data,mess] = data_sqw_dnd          % assumes ndim=0
            %   >> [data,mess] = data_sqw_dnd (ndim)   % sets dimensionality
            %
            % Old style syntax:
            %   >> [data,mess] = data_sqw_dnd (u1,p1,u2,p2,...,un,pn)  % Define plot axes
            %   >> [data,mess] = data_sqw_dnd (u0,...)
            %   >> [data,mess] = data_sqw_dnd (lattice,...)
            %   >> [data,mess] = data_sqw_dnd (lattice,u0,...)
            %   >> [data,mess] = data_sqw_dnd (...,'nonorthogonal')    % permit non-orthogonal axes
            %
            % New style syntax:
            %   >> [data,mess] = data_sqw_dnd (proj, p1_bin, p2_bin, p3_bin, p4_bin)
            %   >> [data,mess] = data_sqw_dnd (lattice,...)
            %
            %
            % Input:
            % -------
            %   ndim            Number of dimensions
            %
            % **OR**
            %   lattice         [Optional] Defines crystal lattice: [a,b,c,alpha,beta,gamma]
            %                  Assumes to be [2*pi,2*pi,2*pi,90,90,90] if not given.
            %
            %   u0              [Optional] Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
            %                  that defines an origin point on the manifold of the dataset.
            %                   If en0 omitted, then assumed to be zero.
            %
            %   u1              Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
            %                  not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
            %                  [0,0,0,1] are valid; [1,0,0,1] is not.
            %
            %   p1              Vector of form [plo,delta_p,phi] that defines bin centres
            %                  and step size in multiples of u1.
            %
            %   u2,p2           For next plot axis
            %    :                  :
            %
            %   'nonorthogonal' Keyword that permits the projection axes to be non-orthogonal
            %
            % **OR**
            %   lattice         [Optional] Defines crystal lattice: [a,b,c,alpha,beta,gamma]
            %                  Assumes to be [2*pi,2*pi,2*pi,90,90,90] if not given.
            %
            %   proj            Projection structure or object.
            %
            %   p1_bin,p2_bin.. Binning descriptors, that give bin boundaries or integration
            %                  ranges for each of the four axes of momentum and energy. They
            %                  each have one fo the forms:
            %                   - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
            %                   - [pint_lo,pint_hi]         (pint_lo<=pint_hi)
            %                   - [pint]                    (interpreted as [pint,pint]
            %                   - [] or empty               (interpreted as [0,0]
            %                   - scalar numeric cellarray  (interpreted as bin boundaries)
            %
            % Output:
            % -------
            %
            %   data        Output data structure which must contain the fields listed below
            %                       type 'b+'   fields: uoffset,...,s,e,npix
            %               [The following other valid structures are not created by this function
            %                       type 'b'    fields: uoffset,...,s,e
            %                       type 'a'    uoffset,...,s,e,npix,img_db_range,pix
            %                       type 'a-'   uoffset,...,s,e,npix,img_db_range         ]
            %
            %   mess        Message; ='' if no problems, otherwise contains error message
            %
            %  A valid output structure contains the following fields
            %
            %   data.filename   Name of sqw file that is being read, excluding path
            %   data.filepath   Path to sqw file that is being read, including terminating file separator
            %   data.title      Title of sqw data structure
            %   data.alatt      Lattice parameters for data field (Ang^-1)
            %   data.angdeg     Lattice angles for data field (degrees)
            %   data.uoffset    Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
            %   data.u_to_rlu   Matrix (4x4) of projection axes in hkle representation
            %                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
            %   data.ulen       Length of projection axes vectors in Ang^-1 or meV [row vector]
            %   data.ulabel     Labels of the projection axes [1x4 cell array of character strings]
            %   data.iax        Index of integration axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
            %   data.iint       Integration range along each of the integration axes. [iint(2,length(iax))]
            %                       e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
            %   data.pax        Index of plot axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
            %                                       2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
            %   data.p          Cell array containing bin boundaries along the plot axes [column vectors]
            %                       i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
            %   data.dax        Index into data.pax of the axes for display purposes. For example we may have
            %                  data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
            %                  the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
            %                  the display axes to be permuted but without the contents of the fields p, s,..pix needing to
            %                  be reordered [row vector]
            %   data.s          Cumulative signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.e          Cumulative variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.npix       No. contributing pixels to each bin of the plot axes.
            %                  [size(data.pix)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.img_db_range  The range of the data along each axis, defining the size of the
            %                    grid, the pixels are rebinned into [img_db_range(2,4)]
            %   data.pix        A PixelData object
            
            
            obj = obj@axes_block();
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        %
        function obj = init(obj,varargin)
            if isa(varargin{1},'data_sqw_dnd') % handle shallow copy constructor
                obj =varargin{1};                          % its COW for Matlab anyway
            elseif nargin==2 && isstruct(varargin{1})
                obj = from_class_struct(obj,varargin{1});
            else
                [obj,uoffset_,remains] = init@axes_block(obj,varargin{:});
                obj.uoffset = uoffset_;
                obj=make_sqw_data_(obj,uoffset_,remains{:});
            end
        end
        %
        function isit=dnd_type(obj)
            if isempty(obj.pix) || isempty(obj.img_db_range)
                isit = true;
            else
                isit = false;
            end
        end
        %
        %TODO: Is it still needed? Remove after refactoring
        function type= data_type(obj)
            % compatibility function
            %   data   Output data structure which must contain the fields listed below
            %          type 'b+'   fields: uoffset,...,s,e,npix
            %          [The following other valid structures are not created by this function
            %          type 'b'    fields: uoffset,...,s,e
            %          type 'a'    uoffset,...,s,e,npix,img_db_range,pix
            %          type 'a-'   uoffset,...,s,e,npix,img_db_range
            if isempty(obj.npix)
                type = 'b';
            else
                type = 'b+';
                if ~isempty(obj.img_db_range)
                    type = 'a-';
                end
                if ~isempty(obj.pix)
                    type = 'a';
                end
            end
        end
        
        function dnd_struct=get_dnd_data(obj,varargin)
            %function retrieves dnd structure from the sqw_dnd_data class
            % if additional argument provided (+), the resulting structure  also includes
            % img_db_range.
            dnd_struct = obj.get_dnd_data_(varargin{:});
        end
        %
        function obj=clear_sqw_data(obj)
            obj.pix = PixelData();
        end
        function pix = get.pix(obj)
            pix = obj.pix_;
        end
        function obj = set.pix(obj,val)
            if isa(val,'PixelData') || isa(val,'pix_combine_info')
                obj.pix_ = val;
            else
                obj.pix_ = PixelData(val);
            end
        end
        
        %
        function [type,obj]=check_sqw_data(obj, type_in, varargin)
            % old style validator for consistency of input data.
            %
            % only 'a' and 'b+' types are possible as inputs and outputs
            % varargin may contain 'field_names_only' which in fact
            % disables validation
            %
            [type,obj]=check_sqw_data_(obj,type_in);
        end
        %
        function npix= get.num_pixels(obj)
            if isa(obj.pix,'PixelData')
                npix = obj.pix.num_pixels;
            else
                npix  = [];
            end
        end
        
        
    end
    methods(Access=protected)
        function obj = from_old_struct(obj,inputs)
            % restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            if isfield(inputs,'urange')
                %      do check for previous versions
                %      and add appropriate code to convert the old data into
                %      the modern data
                inputs.img_db_range = inputs.urange;
                inputs = rmfield(inputs,'urange');
            elseif isfield(inputs,'img_range')
                inputs.img_db_range = inputs.img_range;
                inputs = rmfield(inputs,'img_range');
            end
            if any(any(inputs.img_db_range==PixelData.EMPTY_RANGE_)) %
                % assume that img_db_range can be restored from axis range.
                % This is not always possible and correct, but may be
                % correct for majority of old data
                inputs.img_db_range = obj.calc_img_db_range(inputs);
            end
            if ~isfield(inputs,'nonorthogonal')
                inputs.nonorthogonal = false;
            end
            obj = obj.from_class_struct(inputs);
        end
    end
    methods(Static)
        %
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = data_sqw_dnd();
            obj = loadobj@serializable(S,obj);
        end
        %
        function [ind_range,ind_en,proj]=...
                get_projection_from_pbin_inputs(ndim,uoffset,nonorthogonal,varargin)
            % Parce binning inputs and try to guess some u_to_rlu from them.
            % Ugly. Try to remove from here. Makes artificial dependence
            % between axes_block and projection. Probably need not be here
            %
            nout = nargout;
            [ind_range,ind_en,proj]=...
                get_projection_from_pbin_inputs_(nout,ndim,uoffset,nonorthogonal,...
                varargin{:});
        end
        
    end
end
