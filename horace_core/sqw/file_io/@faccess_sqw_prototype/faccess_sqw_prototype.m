classdef faccess_sqw_prototype < sqw_binfile_common
    % Class to access old legacy Horace-type files
    %
    %
    % Usage:
    %>>sqw_access = faccess_sqw_prototype(filename)
    %
    % Initializes accessor to existing sqw file where
    % @param filename  :: the name of existing sqw file written in
    %                     Horace prototype format.
    %
    % Throws if file with filename is missing or is not written in
    % sqw prototype format.
    %
    % To avoid attempts to initialize this accessor using incorrect sqw
    % file, access to existing sqw files should be organized using sqw
    % format factory namely:
    %
    % >>accessor = sqw_formats_factory.instance().get_loader(filename)
    %
    % If the sqw file with filename is sqw prototype file, the
    % sqw_formats_factory will return instance of this class,
    % initialized for reading this file.
    %
    % The initialized object allows to use all get/read methods described
    % by sqw_file_interface and dnd_file_interface
    %
    % Prototype file format does not allow writing into it. After
    % retrieving all necessary data from the file, its necessary to set
    % up correct alatt and angdeg  parameters missing in prototype
    % files and save file in one of the modern file formats.
    %
    % The recommended accessor for modern file format should be obtained
    % using sqw_formats_factory:
    %
    %>> accessor = sqw_formats_factory.instance().get_pref_access([sqw_or_dnd_object]);
    %
    % which would allow easy change the preferred accessor in a future.
    %
    % $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
    %
    %
    properties
    end
    methods(Access=protected)
        function obj=init_from_sqw_obj(obj,varargin)
            % initialize the structure of sqw file using sqw object as input
            error('SQW_FILE_IO:runtime_error',...
                'FACCESS_SQW_PROTOTYOE::init_from_sqw_obj: method is not implemented for prototype files as you can not currently write prototype files');
        end
        function obj=init_from_sqw_file(obj,varargin)
            % initialize the structure of faccess class using sqw file as input
            fseek(obj.file_id_,0,'bof');
            [mess,res] = ferror(obj.file_id_);
            if res ~= 0
                error('SQW_FILE_IO:io_error',...
                    'FACCESS_SQW_PROTOTYOE::init_from_sqw_file: IO error locating number of contributing files field: Reason %s',mess)
            end
            obj.main_header_pos_ = 0;
            
            obj = init_from_sqw_file@sqw_binfile_common(obj,varargin{:});
            obj.sqw_type_ = true;
        end
    end
    
    methods
        function obj=faccess_sqw_prototype(varargin)
            % constructor, to build sqw reader for prototype file format
            %
            % Usage:
            % ld = faccess_sqw_prototype() % initialize empty sqw reader
            %                        to access old format sqw files
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_sqw_prototype(filename) % initialize sqw reader
            %                       to access old format sqw files
            %
            %                       Throws error if the file version is not sqw
            %                       prototype version
            % ld = faccess_sqw_prototype(sqw_object) % Throws error as
            %                       saving in prototype format is not
            %                       supported
            %
            obj.file_ver_ = 0;
            obj.sqw_type_ = true;
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        %
        function [should,initob,mess] =should_load_stream(obj,header,fid)
            % Check if faccess_sqw_prototype loader should process selected
            % data file.
            %Usage:
            %
            %>> [should,objinit,mess] = obj.should_load_stream(head_struc,fid)
            % where:
            % head_struc:  structure returned by dnd_file_interface.get_file_header
            %              static method and containing sqw/dnd file info, stored in
            %              the file header.
            % fid       :: file identifier of already opened binary sqw/dnd file where
            %              head_struct has been read from
            
            %
            % Returns:
            % should  :: boolean equal to true if the loader can load these data,
            %            or false if not.
            % objinit :: initialized helper obj_init class, containing information, necessary
            %            to initialize the loader.
            % message :: if false, contains detailed information on the reason why this
            %            file should not be loaded by this loader. Empty, if should ==
            %            true.
            
            if header.version == 0 && strcmp(header.name,'horace')
                if header.uncertain
                    fseek(fid,0,'bof');
                    header = dnd_file_interface.get_file_header(fid,4098+22);
                end
            end
            
            
            [should,initob,mess]= should_load_stream@dnd_binfile_common(obj,header,fid);
            if should
                warning('SQW_FILE_IO:legacy_data',...
                    'FACCESS_SQW_PROTOTYPE::should_load_stream: trying to load legacy Horace prototype data format');
            end
        end
        %
        function data_form = get_dnd_form(obj,varargin)
            % Return the structure of the data file header in the form
            % it is written on hdd.
            % Fields in the structure are:
            %
            
            % ------------------------------
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
            %   data.pix        Array containing data for eaxh pixel:
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
            
            %
            data_form = get_dnd_form@dnd_binfile_common(obj,varargin{:});
            data_form = rmfield(data_form,{'filename','filepath','title','alatt','angdeg'});
        end
        %
        function sqw_data = get_data(obj,varargin)
            % get prototype sqw data converting it in modern file format if
            % possible
            
            %
            %   >> data = obj.get_sqw_data()
            %   >> data = obj.get_sqw_data(opt)
            %   >> data = obj.get_sqw_data(npix_lo, npix_hi)
            %
            % Input:
            % ------
            %   opt         [optional] Determines which fields to read
            %                   '-header'     header-type information only: fields read:
            %                               filename, filepath, title, alatt, angdeg,...
            %                                   uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,urange]
            %                              (If file was written from a structure of type 'b' or 'b+', then
            %                               urange does not exist, and the output field will not be created)
            %                   '-hverbatim'    Same as '-h' except that the file name as stored in the main_header and
            %                                  data sections are returned as stored, not constructed from the
            %                                  value of fopen(fid). This is needed in some applications where
            %                                  data is written back to the file with a few altered fields.
            %                   '-nopix' Pixel information not read (only meaningful for sqw data type 'a')
            %
            %               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
            %
            %   npix_lo     -|- [optional] pixel number range to be read from the file (only applies to type 'a')
            %   npix_hi     -|
            %
            
            %
            % Output:
            % -------
            
            %   data        Output data structure actually read from the file. Will be one of:
            %                   type 'h'    fields: fields: uoffset,...,dax[,urange]
            %                   type 'b'    fields: filename,...,dax,s,e
            %                   type 'b+'   fields: filename,...,dax,s,e,npix
            %                   type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
            %                   type 'a-'   fields: filename,...,dax,s,e,npix,urange
            %               The final field urange is present for type 'h' if the header information was read from an sqw-type file.
            %
            %
            %
            % Fields read from the file are:
            % ------------------------------
            %   data.filename   Name of sqw file that is being read, excluding path
            %   data.filepath   Path to sqw file that is being read, including terminating file separator
            %          [Note that the filename and filepath that are written to file are ignored; we fill with the
            %           values corresponding to the file that is being read.]
            %
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
            %   data.pix        Array containing data for eaxh pixel:
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
            %
            %
            % NOTES:
            % ======
            % Supported file Formats
            % ----------------------
            % The current sqw file format comes in two variants:
            
            % Get prototype sqw data
            if obj.data_type == 'b'
                error('SQW_FILE_IO:runtime_error',...
                    'FACCESS_SQW_PROTOTYPE:get_data File does not contain number of pixels for each bin - unable to convert old format data')
            end
            
            sqw_data = get_data@sqw_binfile_common(obj,varargin{:});
            [path,name,ext]=fileparts(fopen(obj.file_id_));
            sqw_data.filename=[name,ext];
            sqw_data.filepath=[path,filesep];
            
            sqw_data.title = '';
            sqw_data.alatt = zeros(1,3);
            sqw_data.angdeg = zeros(1,3);
            
        end
        %
        function sqw_data = get_se_npix(obj,varargin)
            % get signal,error and npix data only
            sqw_data = get_se_npix@dnd_binfile_common(obj,varargin{:});
            [sqw_data.s,sqw_data.e] = ...
                convert_signal_error_(sqw_data.s,sqw_data.e,sqw_data.npix);
        end
        
        %
        function new_obj = upgrade_file_format(obj)
            error('SQW_FILE_IO:legacy_data',...
                ['FACCESS_SQW_PROTOTYPE::upgrade_file_format: can not upgrade file from prototype to other file format.\n',...
                'Load prototype, set up correct alatt and angdeg parameters and save it into one of the new file formats']);
            
        end
    end
    
end


