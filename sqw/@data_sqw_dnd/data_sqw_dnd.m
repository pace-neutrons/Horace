classdef data_sqw_dnd
    % Class defines structure of the data, used by sqw&dnd objects
    %
    % Trivial implementation, wrapping around a structure
    properties
        filename=''   % Name of sqw file that is being read, excluding path
        filepath=''   % Path to sqw file that is being read, including terminating file separator
        title   =''   % Title of sqw data structure
        alatt   =[1,1,1] % Lattice parameters for data field (Ang^-1)
        angdeg  =[90,90,90]% Lattice angles for data field (degrees)
        uoffset=[0;0;0;0]  %   Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
        u_to_rlu=eye(4)    %   Matrix (4x4) of projection axes in hkle representation
        %                   u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
        ulen=[1,1,1]            %Length of projection axes vectors in Ang^-1 or meV [row vector]
        ulabel={'','','','En'}  %Labels of the projection axes [1x4 cell array of character strings]
        iax=zeros(1,0);    %Index of integration axes into the projection axes  [row vector]
        %                  Always in increasing numerical order
        %                  e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
        iint=zeros(2,0);   %Integration range along each of the integration axes. [iint(2,length(iax))]
        %                   e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
        pax=zeros(1,0);   %Index of plot axes into the projection axes  [row vector]
        %                Always in increasing numerical order
        %                e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
        %                2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
        p=cell(1,0);  %  Cell array containing bin boundaries along the plot axes [column vectors]
        %                i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
        dax=zeros(1,0)    %Index into data.pax of the axes for display purposes. For example we may have
        %                  data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
        %                  the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
        %                  the display axes to be permuted but without the contents of the fields p, s,..pix needing to
        %                  be reordered [row vector]
        s=[]          %Cumulative signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
        e=[]          %Cumulative variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
        npix=[]       %No. contributing pixels to each bin of the plot axes.
        %             [size(data.pix)=(length(data.p1)-1, length(data.p2)-1, ...)]
        urange=[Inf,Inf,Inf,Inf;... %True range of the data along each axis [urange(2,4)]
            -Inf,-Inf,-Inf,-Inf] % [Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf] -- convention if no pixels
        pix=[]     %Array containing data for each pixel:
        % If npixtot=sum(npix), then pix(9,npixtot) contains:
        % u1      -|
        % u2       |  Coordinates of pixel in the projection axes
        % u3       |
        % u4      -|
        % irun        Run index in the header block from which pixel came
        % idet        Detector group number in the detector listing for the pixel
        % ien         Energy bin number for the pixel in the array in the (irun)th header
        % signal      Signal array
        % err         Error array (variance i.e. error bar squared)
        axis_caption=an_axis_caption(); %  Reference to class, which define axis captions
        
        % Original author: T.G.Perring
        %
        % $Revision$ ($Date$)
        %
        %
    end
    
    methods
        %------------------------------------------------------------------
        % FOLDER'S PUBLIC METHODS SIGNATURES:
        % Read the data block from an sqw file. The file pointer is left at the end of the data block.
        [mess, data, position, npixtot, data_type] = get_sqw_data (obj,fid, varargin);
        % Determine data type of the data field of an sqw data structure
        data_type = data_structure_type(data);
        % return 3 q-axis in the order they mark the dnd object
        % regardless of the integration along some qxis
        [q1,q2,q3] = get_q_axes(obj);
        % return binning range of existing data object
        range = get_bin_range(obj);
        %------------------------------------------------------------------
        function obj = data_sqw_dnd(varargin)
            % constructor || copyconstructor:
            % Builds valid data_sqw_dnd object from various data structures
            %
            % Simplest constructor
            %   >> [data,mess] = make_sqw_data          % assumes ndim=0
            %   >> [data,mess] = make_sqw_data (ndim)   % sets dimensionality
            %
            % Old style syntax:
            %   >> [data,mess] = make_sqw_data (u1,p1,u2,p2,...,un,pn)  % Define plot axes
            %   >> [data,mess] = make_sqw_data (u0,...)
            %   >> [data,mess] = make_sqw_data (lattice,...)
            %   >> [data,mess] = make_sqw_data (lattice,u0,...)
            %   >> [data,mess] = make_sqw_data (...,'nonorthogonal')    % permit non-orthogonal axes
            %
            % New style syntax:
            %   >> [data,mess] = make_sqw_data (proj, p1_bin, p2_bin, p3_bin, p4_bin)
            %   >> [data,mess] = make_sqw_data (lattice,...)
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
            %                       type 'a'    uoffset,...,s,e,npix,urange,pix
            %                       type 'a-'   uoffset,...,s,e,npix,urange         ]
            %
            %   mess        Message; ='' if no problems, otherwise contians error message
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
            %   data.urange     True range of the data along each axis [urange(2,4)]
            %   data.pix        Array containing data for each pixel:
            %                  If npixtot=sum(npix), then pix(9,npixtot) contains:
            %                   u1      -|
            %                   u2       |  Coordinates of pixel in the projection axes
            %                   u3       |
            %                   u4      -|
            %                   irun        Run index in the header block from which pixel came
            %                   idet        Detector group number in the detector listing for the pixel
            %                   ien         Energy bin number for the pixel in the array in the (irun)th header
            %                   signal      Signal array
            %                   err         Error array (variance i.e. error bar squared)
            
            if nargin>0 && isa(varargin{1},'data_sqw_dnd') % handle shalow copy constructor
                obj =varargin{1};                          % its COW for Matlab anyway
            else
                [obj,mess]=make_sqw_data(obj,varargin{:});
                if ~isempty(mess)
                    error('DATA_SQW_DND:invalid_argument',mess);
                end
            end
        end
        function isit=dnd_type(obj)
            if isempty(obj.pix) || isempty(obj.urange)
                isit = true;
            else
                isit = false;
            end
        end
        function type= data_type(obj)
            % compartibility function
            %   data   Output data structure which must contain the fields listed below
            %          type 'b+'   fields: uoffset,...,s,e,npix
            %          [The following other valid structures are not created by this function
            %          type 'b'    fields: uoffset,...,s,e
            %          type 'a'    uoffset,...,s,e,npix,urange,pix
            %          type 'a-'   uoffset,...,s,e,npix,urange
            if isempty(obj.npix)
                type = 'b';
            else
                type = 'b+';
                if ~isempty(obj.urange)
                    type = 'a-';
                end
                if ~isempty(obj.pix)
                    type = 'a';
                end
            end
        end
        function dnd_struct=get_dnd_data(obj)
            %functin retrieves dnd structure from the sqw_dnd_data class
            dnd_struct = obj.get_dnd_data_();
        end
        
        function obj=clear_sqw_data(obj)
            obj.pix=[];
            obj.urange=[];
        end
        function [ok, type, mess]=check_sqw_data(obj, type_in, varargin)
            % old style validator for consistency of imput data.
            %
            % only 'a' and 'b+' types are possible as inputs and outputs
            % varargin may contain 'field_names_only' which in fact
            % disables validation
            %
            [ok, type, mess]=obj.check_sqw_data_(type_in);
        end
        
    end
end

