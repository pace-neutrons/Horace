classdef faccess_sqw_v3_3 < faccess_sqw_v3
    % Class to access Horace binary files written in binary format v3.3
    % The format differs from 3.1 format as efixed can contain range of
    % energies (equal to number of detectors). This format may be necessary
    % for writing results of indirect instruments
    %
    % In addition to that, it distinguish between img_range and pix_range
    % and stores/restores both fields
    %
    %
    %
    % Usage:
    %1)
    %>>sqw_access = faccess_sqw_v3_3(filename)
    % or
    % 2)
    %>>sqw_access = faccess_sqw_v3_3(sqw_dnd_object,filename)
    %
    % 1)
    % First form initializes accessor to existing sqw file where
    % filename  :: the name of existing sqw file written
    %                     in sqw v3.3 format.
    %
    % Throws if file with filename is missing or is not written in
    % sqw v3.3 format.
    %
    % To avoid attempts to initialize this accessor using incorrect sqw file,
    % access to existing sqw files should be organized using sqw
    % formats factory namely:
    %
    % >>accessor = sqw_formats_factory.instance().get_loader(filename)
    %
    % If the sqw file with filename is sqw v3.1 sqw file, the sqw format
    % factory will return instance of this class, initialized for
    % reading this file.
    % The initialized object allows to use all get/read methods described
    % by sqw_file_interface,
    % dnd_file_interface and additional methods to read instrument and
    % sample, specific for v3.2 file format.
    %
    % 2)
    % Second form used to initialize the operation of writing new or
    % updating existing sqw file.
    % where:
    % sqw_dnd_object:: existing fully initialized sqw object in memory.
    % filename      :: the name of a new or existing sqw object on disc
    %
    % Update mode is initialized if the file with name filename exists and
    % can be updated, i.e. has the same number of dimensions, binning axis
    % and pixels.
    % In this case you can modify dnd or sqw metadata or explicitly
    % overwrite pixels.
    %
    % If existing file can not be updated, it will be open in write mode.
    % If file with filename does not exist, the object will be open in write mode.
    %
    % Initialized faccess_sqw_v3 object allows to use write/update methods of
    % dnd_file_interface, sqw_file_interface + writing instrument and sample
    % and all read methods of these interfaces if the proper information
    % already exists in the file.
    %
    %
    
    %
    properties(Access=public,Hidden=true)
        img_range_pos_= 0;
    end
    properties(Constant,Access=protected,Hidden=true)
        % list of fileldnames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        fields_to_save_3_3 = {'img_range_pos_'};
    end
    
    %
    %
    methods
        %
        %
        function obj=faccess_sqw_v3_3(varargin)
            % constructor, to build sqw reader/writer version 3
            %
            % Usage:
            % ld = faccess_sqw_v3_3() % initialize empty sqw reader/writer
            %                        version 3.3
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_sqw_v3_3(filename) % initialize sqw reader/writer
            %                       version 3.3
            %                       to load sqw file version 3.3
            %                       Throws error if the file version is not sqw
            %                       version 3.3
            % ld = faccess_sqw_v3_3(sqw_object) % initialize sqw
            %                       reader/writer version 3.3
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            % ld = faccess_sqw_v3_3(sqw_object,filename) % initialize sqw
            %                       reader/writer version 3.3
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            
            %
            % set up fields, which define appropriate file version
            
            obj = obj@faccess_sqw_v3();
            obj.file_ver_ = 3.3;
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        function is = keeps_img_range(~)
            % Returns true when the img_range is stored within a file.
            is = true;
        end
        %
        function struc = saveobj(obj)
            % method used to convert object into structure
            % for saving it to disc.
            struc = saveobj@faccess_sqw_v3(obj);
            flds = obj.data_fields_to_save_;
            for i=1:numel(flds)
                struc.(flds{i}) = obj.(flds{i});
            end
        end
        %
        function img_range = get_img_range(obj,varargin)
            % get [2x4] array of min/max ranges of the image contributing
            % into an object
            img_range = get_img_range_(obj,varargin{:});
        end
        %-------------------------------------------------------------------
        function obj = put_dnd_data(obj,varargin)
            [obj,obj_to_save] = put_dnd_data@dnd_binfile_common(obj,varargin{:});
            %
            fseek(obj.file_id_,obj.img_range_pos_,'bof');
            check_error_report_fail_(obj,'Error moving to the beginning of the img_range record');
            fwrite(obj.file_id_,obj_to_save.img_range,'float32');
            check_error_report_fail_(obj,'Error writing img_range record');
        end
        function data_form = get_dnd_form(obj,varargin)
            % Return the structure of the data file header in the form
            % it is written on hdd.
            % Usage:
            %>>df = obj.get_dnd_form();
            %>>df = obj.get_dnd_form('-head');
            %>>df = obj.get_dnd_form('-const');
            %>>df = obj.get_dnd_form('-data');
            %
            % where the options:
            % '-head' returns metadata field only and
            % '-const' returns partial methadata which do not change size on hdd
            % '-data'  returns format for data fields, namely signal, error
            %          and npix. This information may be used to identify
            %          the size, these fields occupy on hdd
            %
            % Fields in the full structure are:
            %
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
            %
            %   data.img_range the format of image range stored in the file
            %
            argi = varargin;
            if strcmp(obj.data_type,'un') % we want full data if datatype is undefined
                argi={};
            end
            data_form = get_dnd_form@dnd_binfile_common(obj,argi{:});
            if isfield(data_form,'npix')
                data_form.img_range = single([2,4]);
            end
        end
        
        
    end
    methods(Access=protected,Hidden=true)
        function flds = fields_to_save(obj)
            % returns the fields to save in the structure in sqw binfile v3 format
            head_flds = fields_to_save@faccess_sqw_v3(obj);
            insertion_ind = find(ismember(head_flds,'npix_pos_'));
            flds = [head_flds(1:insertion_ind);...
                obj.fields_to_save_3_3(:);...
                head_flds(insertion_ind+1:end)];
        end
        function obj=init_from_sqw_obj(obj,varargin)
            % initialize the structure of faccess class using opened
            % sqw file as input
            obj = init_from_sqw_obj@faccess_sqw_v3(obj,varargin{:});
            %
            obj.img_range_pos_ =obj.data_fields_locations_.img_range_pos_;
        end
        function obj=init_from_sqw_file(obj)
            % initialize the structure of faccess class using opened
            % sqw file as input
            obj=init_from_sqw_file@faccess_sqw_v3(obj);
            obj.img_range_pos_ =obj.data_fields_locations_.img_range_pos_;
        end
    end
    methods(Static,Hidden=true)
        function header = get_header_form(varargin)
            % Return structure of the contributing file header in the form
            % it is written on hdd.
            % Usage:
            % header = obj.get_header_form();
            % header = obj.get_header_form('-const');
            % Second option returns only the fields which do not change if
            % filename or title changes
            %
            % Fields in file are:
            % --------------------------
            %   header.filename     Name of sqw file excluding path
            %   header.filepath     Path to sqw file including terminating file separator
            %   header.efix         Array of fixed energies for all crystal analysers
            %   header.emode        Emode=1 direct geometry, =2 indirect geometry
            %   header.alatt        Lattice parameters (Angstroms)
            %   header.angdeg       Lattice angles (deg)
            %   header.cu           First vector defining scattering plane (r.l.u.)
            %   header.cv           Second vector defining scattering plane (r.l.u.)
            %   header.psi          Orientation angle (deg)
            %   header.omega        --|
            %   header.dpsi           |  Crystal misorientation description (deg)
            %   header.gl             |  (See notes elsewhere e.g. Tobyfit manual
            %   header.gs           --|
            %   header.en           Energy bin boundaries (meV) [column vector]
            %   header.uoffset      Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
            %   header.u_to_rlu     Matrix (4x4) of projection axes in hkle representation
            %                        u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
            %   header.ulen         Length of projection axes vectors in Ang^-1 or meV [row vector]
            %   header.ulabel       Labels of the projection axes [1x4 cell array of character strings]
            
            header = get_header_form_(varargin{:});
        end
    end
    %
end

