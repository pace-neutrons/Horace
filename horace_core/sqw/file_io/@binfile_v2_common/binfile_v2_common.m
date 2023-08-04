classdef binfile_v2_common < horace_binfile_interface
    % Class contains common methods and code used to access binary dnd
    % files.
    %
    % The fields, defined by class are specific to binary access to sqw
    % files
    %
    % Binary sqw/dnd-file accessors inherit this class, use common methods,
    % defined in this class, implement remaining methods, inherited from
    % horace_binfile_interface and overload the methods, which have different
    % data access requests.
    %
    % binfile_v2_common Methods:
    % ----------------------------------------------------------------
    % Properties:
    % See Property Summary chapter.
    % ----------------------------------------------------------------
    % reopen_to_write    - open new or reopen existing file in write mode
    %                      (all existing contents will be ignored, though
    %                       may be maintained if the file exists, but additional
    %                      measure to be taken)
    % set_file_to_update - open new or reopen existing file for updating
    %                      existing information in  it (where possible)
    %
    % ----------------------------------------------------------------
    % Data accessors:
    % get_data           - get all dnd data without packing them into dnd
    %                      object.
    % get_sqw            - retrieve the whole dnd object.
    % get_dnd            - retrieve dnd object as dnd object (even from an sqw file).
    % ----------------------------------------------------------------
    % Data mutators:
    % put_sqw  - save sqw/dnd object stored in memory into binary sqw file
    %            as dnd object.
    % put_dnd  - save sqw/dnd object stored in memory into binary sqw file
    %            as dnd object.
    %
    % There is also range of auxiliary methods used by the get/put_sqw/dnd
    % methods, and allowing to save/restore any part of binary sqw file
    % ----------------------------------------------------------------
    %
    %
    properties(Access=protected)
        % position (in bytes from start of the file of the appropriate part
        % of Horace data information and the size of this part.
        % 26 is standard position in modern sqw file format.
        data_pos_=26;

        % signal information location (in bytes)
        s_pos_=0;
        % error information location (in bytes)
        e_pos_=0;
        % position of the npix field
        npix_pos_='undefined';

        % end of dnd info position
        dnd_eof_pos_=0;
        % contains structure with accurate positions of all data fields
        % to use for accurate replacement of these fields during update
        % operations
        data_fields_locations_=[];
        %
        % a pointer to eof position, used to identify the state of IO
        % operations showing position where the data have actually been
        % written
        real_eof_pos_ = 0; % does it give any advantage? TODO: not currently used or consistent
        %
        upgrade_map_ = [];
        % internal parameters used to control the process of upgrading
        % headers with run_id. Should be disabled in upgrade mode
        upgrade_headers_ = true;

        %True if convert all read fields (except pixels) into double
        convert_to_double_ = true;

        % LEGACY: type of binary data stored in file
        data_type_ = 'undefined';
        % sizes of the image array, containing in
        dnd_dimensions_ = 'undefined'
    end
    %
    properties(Dependent)
        % Dimensions of the Horace image (dnd object), stored in the file.
        % (Legacy property. Use num_dim instead)
        dnd_dimensions

        % Legacy type of data written in the file, describing the information
        % stored in a sqw file
        %
        % Possible types are:
        %   type 'b'    fields: filename,...,dax,s,e
        %   type 'b+'   fields: filename,...,dax,s,e,npix
        %   type 'a'    fields: filename,...,dax,s,e,npix,img_db_range,pix
        %   type 'a-'   fields: filename,...,dax,s,e,npix,img_db_range.
        %
        % all modern data files are either b+ (dnd) or a+ (sqw data) type
        % files.
        data_type
        % Legacy field:
        % if all numeric types, read from a file to be converted to double.
        % (except pixels)
        convert_to_double

        % Legacy field: true if existing file should be upgraded false
        % -- overwritten
        upgrade_mode;
        % interfaces to binary access outside of this class:
        % initial location of dnd data fields
        data_position;
    end
    methods(Static)
        % convert all numerical types of a structure into double
        val = do_convert_to_double(val)
    end

    methods(Access = protected)
        %
        function obj=init_from_sqw_obj(obj,varargin)
            % initialize the structure of sqw file using sqw/dnd object as
            % input
            %
            % method should be overloaded or expanded by children if more
            % complex then common logic is used
            %
            % Usage:
            %>>obj = obj.init_from_sqw_obj(sqw_object)
            %>>obj = obj.init_from_sqw_obj(sqw_object,target_file_name)
            %
            % where:
            % sqw_object  - full sqw object to write into a file
            % target_file_name - file to save data in. If the file exist,
            %                    and is sqw file, the method will try to
            %                    open file in update mode. If it is not
            %                    possible, the file is open in overwrite
            %                    mode.
            % Stores the sqw object in internal field to allow put
            % methods to work.
            [obj,inobj]= obj.init_dnd_info(varargin{:});
            obj.sqw_holder_= inobj;
        end
        %
        function [obj,inobj] = init_dnd_info(obj,varargin)
            % init dnd file position information.
            %
            if nargin < 2
                error('SQW_FILE_IO:runtime_error',...
                    'binfile_v2_common:init_from_sqw_obj method should be invoked with at least an existing sqw or dnd object provided');
            end
            if isa(varargin{1},'sqw') || is_sqw_struct(varargin{1})
                inobj = obj.extract_correct_subobj('data',varargin{:});
            else % dnd (the common logic verified that it is dnd)
                inobj  = varargin{1};
            end
            obj = init_from_sqw_(obj,inobj,varargin{2:end});
        end
        %
        function obj=init_from_sqw_file(obj,varargin)
            % Initialize the structure of faccess class using sqw file as input
            %
            % method should be overloaded or expanded by children if more
            % complex then common logic is used
            %
            % Usage:
            % >>obj = obj.init_from_sqw_file(filename)
            % Where:
            % filename - the file to load data from.
            %
            obj= init_dnd_structure_field_by_field_(obj,varargin{:});
        end
        %
        %
        function [sub_obj,external] = extract_correct_subobj(obj,obj_name,varargin)
            % auxiliary function helping to extract correct sub-object from
            % input or internal object
            % Usage:
            %>>[sub_obj,external] = obj.extract_correct_subobj(obj_name,varargin)
            % Where:
            %obj_name - the name of sqw object field to extract (e.g.
            %            header, main_header, data etc...)
            %varargin - if provided, an sqw or dnd object. The field is
            %            extracted from internal object if varargin is
            %            empty.
            %Returns:
            % sub_obj - the object with the name provided
            % external - true if varargin is provided and false otherwise.
            %
            if isempty(varargin)
                inobj = obj.sqw_holder_;
                external = false;
            else
                inobj = varargin{1};
                external = true;
            end
            if isa(inobj,'sqw')
                sub_obj = inobj.(obj_name);
            else % dnd object and this has been verified in calling function
                sub_obj = inobj;
            end
        end
        %
        %
        function [obj,missinig_fields] = copy_contents(obj,other_obj,keep_internals)
            % the main part of the copy constructor, copying the contents
            % of the one class into another including opening the
            % corresponding file with the same access rights
            %
            % Copied to all children classes to support overloading as
            % private properties are not accessible from parents
            %
            % keep_internals -- if true, do not overwrite service fields
            %                   not related to position information
            %
            if ~exist('keep_internals','var')
                keep_internals = false;
            end
            [obj,missinig_fields] = copy_contents_(obj,other_obj,keep_internals);
        end
        %
        function is_sqw = get_sqw_type(~)
            is_sqw = false;
        end
        function obj_type = get_format_for_object(~)
            % main part of the format_for_object getter, specifying for
            % what class saving the file format is intended
            obj_type = 'dnd';
        end
        function new_ldr = do_class_dependent_updates(old_ldr,new_ldr,varargin)
            % Update any binary file version < 4.0 to recent file version
            % (version 4) using direct loading data into memory
            %
            % Common implementation is for dnd version. SQW version
            % overloads this
            if old_ldr.faccess_version ~= new_ldr.faccess_version
                dnd_obj = old_ldr.get_dnd();
                new_ldr.sqw_holder = dnd_obj;
                new_ldr = new_ldr.put_dnd();
                old_ldr.delete();
            end
        end
        %
        function pos = get_npix_position(obj)
            % overloadable accessor to npix position
            %
            % return the position of the npix field in the file
            pos = obj.npix_pos_;
        end
    end
    % ACCESSORS AND CONSTRUCTOR
    methods
        %------   Auxiliary methods Used in upgrade
        function type = get.upgrade_mode(obj)
            % return true if object is set up for upgrade
            type = ~isempty(obj.upgrade_map_);
        end
        %
        function obj = set.upgrade_mode(obj,mode)
            obj.upgrade_headers_ = false;
            obj = set_upgrade_mode_(obj,mode);
        end
        % -------------------------------------------
        function  pos = get.data_position(obj)
            % return the position of the start of the dnd data fields
            % in the file (usually its start of main header for sqw or  filename
            % filename for dnd file)
            pos = obj.data_pos_;
        end
        function ff=get.data_type(obj)
            ff = obj.data_type_;
        end

        function conv = get.convert_to_double(obj)
            % if true, convert all numerical values read from an sqw file
            % into double precision
            conv = obj.convert_to_double_;
        end
        %
        function obj = set.convert_to_double(obj,val)
            lval = logical(val);
            obj.convert_to_double_ = lval;
        end
        function dims = get.dnd_dimensions(obj)
            % return image binning (legacy field). Use num_dim instead
            dims = obj.dnd_dimensions_;
        end
    end
    %----------------------------------------------------------------------
    % OTHER CLASS METHODS
    methods % defined by this class
        function [obj,file_exist,old_ldr] = set_file_to_update(obj,filename)
            if ~exist('filename','var')
                filename = obj.full_filename;
            end
            [obj,file_exist,old_ldr] = set_file_to_update@horace_binfile_interface(obj,filename,nargout);
            if old_ldr == obj
                if file_exist
                    obj.upgrade_headers_ = false;
                else
                    obj.upgrade_headers_ = true;
                    return;
                end
            end
            obj=define_upgrade_map_(obj,file_exist,old_ldr);
        end
        % ----------------------------------------------------------------
        function [obj,permissions] = reopen_to_write(obj,filename)
            % Reopen existing file to overwrite or write new data to it
            % or open new target file to save data.
            if ~exist('filename','var')
                filename = '';
            end
            [obj,permissions] = reopen_to_write@horace_binfile_interface(obj,filename);
            if strcmp(permissions,'rb+')
                obj.upgrade_headers_ = false;
            else
                obj.upgrade_headers_ = true;
            end
        end
        %
        % ----------------------------------------------------------------
        % read main dnd data  from properly initialized binary file.
        [dnd_data,obj] = get_data(obj,varargin);
        % write only image signal and error data
        obj = put_image(obj, s, e);

        function [data_str,obj] = get_se_npix(obj,varargin)
            % Read signal, error and npix information and return them as
            % the fields of sqw data structure:
            %
            % Usage:
            %>>data_struct = obj.get_se_npix();
            %>>data_struct = obj.get_se_npix(data_struct);
            %
            % Where the first form creates structure with fields s,e,npix,
            % containing signal, error and npix information correspondingly
            % and the second form appends or replaces these fields in the
            % structure provided as input.
            % Notes:
            % 1) Used as part of get_data method.
            % 2) Depending on the value of the property convert_to_double,
            %    s and e are either single or double precision arrays.
            %    npix is always uint64
            data_str = get_se_npix_data_(obj,varargin{:});
        end
        %
        % retrieve the whole dnd object from properly initialized dnd file
        % and treat it like an sqw object
        [sqw_obj,varargout] = get_sqw(obj,varargin);
        % retrieve full dnd object from sqw file containing dnd or dnd and
        % sqw information
        function [dnd_obj,obj] = get_dnd(obj,varargin)
            [dnd_obj,obj] = obj.get_data(varargin{:});
        end
        function [dnd_meta,obj] = get_dnd_metadata(obj,varargin)
            ds = obj.get_data('-head');
            dnd_meta = dnd_metadata(ds);
        end

        function pix_range = get_pix_range(~)
            % get [2x4] array of min/max ranges of the pixels contributing
            % into an object. Empty for DND object

            pix_range = double.empty(0,4);
        end
        %
        function img_db_range = get_img_db_range(obj,varargin)
            % get [2x4] array of min/max ranges of the image where pixels
            % are rebinned into
            if nargin==1
                ds = obj.get_data('-head');
            else
                ds = varargin{1};
            end
            if isfield(ds,'img_db_range')
                img_db_range  = ds.img_db_range;
            else
                img_db_range = ortho_axes.calc_img_db_range(ds);
            end
        end
        function hd = head(obj,varargin)
            % the function returns standard head information about sqw/dnd file
            [ok,mess,full] = parse_char_options(varargin,'-full');
            if ~ok
                error('HORACE:binfile_v2_common:invalid_argument',mess);
            end
            if full
                data = obj.get_data('-verbatim');
            else
                data = obj.get_data('-verbatim','-head');
            end
            flds = DnDBase.head_form(full);
            cdi = ismember(flds,'creation_date');
            flds = flds(~cdi);
            hd = struct();

            % HACK. This should be dealt with some day. u_to_rlu should go
            if ~isfield(data,'u_to_rlu') && isfield(data,'u_to_rlu_legacy')
                data.u_to_rlu = data.u_to_rlu_legacy;
            end

            for i=1:numel(flds)
                fld = flds{i};
                hd.(fld) = data.(fld);
            end
            if isstruct(data)
                hd.creation_date = datetime('now');
                hd.offset = hd.offset';
                for i=1:numel(hd.p)
                    hd.p{i} = hd.p{i}';
                end
            else
                hd.creation_date = data.creation_date;
            end
        end

        %
        %------   Mutators:
        % Save new or fully overwrite existing sqw file
        obj = put_sqw(obj,varargin);
        % Consisting of:
        % 1) store or update application header
        % 2) store dnd information ('-update' option updates this
        % information within existing file)
        obj = put_dnd_metadata(obj,varargin);
        % write dnd image data, namely s, err and npix ('-update' option updates this
        % information within existing file)
        [obj,varargout] = put_dnd_data(obj,varargin);
        %
        obj = put_dnd(obj,varargin)
        %
        %
        function pos_info = get_pos_info(obj)
            % return structure, containing position of every data field in the
            % file (when object is initialized)
            pos_info = get_pos_info_(obj);
        end
        %----------------------------------------------------
        function [inst,obj] = get_instrument(obj,varargin)
            % get instrument, stored in a file. If no instrument is
            % defined, return empty structure.
            inst = struct();
        end
        %
        function [samp,obj] = get_sample(obj,varargin)
            % get sample, stored in a file. If no sample is defined, return
            % empty structure.
            samp = struct();
        end
        %
        %
        function obj=delete(obj)
            % Close existing file and clear dynamic file information
            %
            obj = delete@horace_binfile_interface(obj);
            obj.data_type_      = 'undefined';
            obj.dnd_dimensions_ = 'undefined';
            obj.real_eof_pos_ = 0;
            obj.upgrade_map_ = [];
            obj.upgrade_headers_= true;
        end
        %
        %
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
            % '-const' returns partial metadata which do not change size on hdd
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
            %   data.offset    Offset of origin of projection axes in r.l.u.
            % and energy ie. [h; k; l; en] [column vector]
            %   data.u_to_rlu_legacy   Matrix (4x4) of projection axes in hkle representation
            %                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
            %   data.ulen      Length of projection axes vectors in Ang^-1 or meV [row vector]
            %   data.label     Labels of the projection axes [1x4 cell array of character strings]
            %   data.iax       Index of integration axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                  e.g. if data is 2D, data.iax=[1,3] means
            %                  summation has been performed along u1 and u3 axes
            %   data.iint       Integration range along each of the integration axes. [iint(2,length(iax))]
            %                       e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
            %   data.pax        Index of plot axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
            %                                       2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
            %   data.p          Cell array containing bin boundaries along the plot axes [column vectors]
            %                       i.e. row cell array{data.p{1}, data.p{2} ...}
            %                   (for as many plot axes as given by length of data.pax)
            %   data.dax        Index into data.pax of the axes for display purposes. For example we may have
            %                  data.pax=[1,3,4] and data.dax=[3,1,2]
            %                  This means that the first plot axis is data.pax(3)=4,
            %                  the second is data.pax(1)=1, the third is
            %                  data.pax(2)=3. The reason for data.dax is to
            %                  allow the display axes to be permuted but
            %                  without the contents of the fields p, s,..pix
            %                  needing to be reordered [row vector]
            %   data.s          Cumulative signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.e          Cumulative variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.npix       No. contributing pixels to each bin of the plot axes.
            %                  [size(data.pix)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.img_range -- in old formats, belongs to dnd but is
            %                  written only when pixels are written
            %
            argi = varargin;
            if strcmp(obj.data_type,'un') % we want full data if datatype is undefined
                argi={};
            end

            data_form = process_format_fields_(argi{:});
        end
        %
        function sqw_obj = get_sqw_internal(obj)
            % return internal sqw object, stored within class or empty
            % string such object is not present
            %
            % internal iSQW object set up when accessor is initialized
            % by an sqw object to write data.
            % It references external sqw object to write
            sqw_obj  = obj.sqw_holder_;
        end
        %
        %
        function obj = deactivate(obj)
            % Close respective file keeping all internal information about
            % this file in memory.
            %
            % To use for MPI transfers between workers when open file can
            % not be transferred between workers but everything else can
            obj = deactivate@horace_binfile_interface(obj);
            obj.upgrade_headers_ = true;
        end
        %
    end
    %
    methods(Static)
        % function extracts first and last field in the structure pos_fields
        % correspondent to the structure form_fields
        [fn_start,fn_end,is_last] = extract_field_range(pos_fields,form_fields);

    end
    %==================================================================
    % SERIALIZABLE INTERFACE
    properties(Constant,Access=private,Hidden=true)
        % list of fileldnames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        fields_to_save_ = {'data_type_';'dnd_dimensions_';'data_pos_';'s_pos_';'e_pos_';
            'npix_pos_';'dnd_eof_pos_';'data_fields_locations_'};
    end
    %----------------------------------------------------------------------
    methods
        function strc = to_bare_struct(obj,varargin)
            base_cont = to_bare_struct@horace_binfile_interface(obj,varargin{:});
            flds = binfile_v2_common.fields_to_save_;
            cont = cellfun(@(x)obj.(x),flds,'UniformOutput',false);

            base_flds = fieldnames(base_cont);
            base_cont = struct2cell(base_cont);
            flds  = [base_flds(:);flds(:)];
            cont = [base_cont(:);cont(:)];
            %
            strc = cell2struct(cont,flds);
        end

        function obj=from_bare_struct(obj,indata)
            obj = from_bare_struct@horace_binfile_interface(obj,indata);
            %
            flds = binfile_v2_common.fields_to_save_;
            for i=1:numel(flds)
                name = flds{i};
                obj.(name) = indata.(name);
            end
        end
        function flds = saveableFields(obj)
            add_flds = binfile_v2_common.fields_to_save_;
            flds = saveableFields@horace_binfile_interface(obj);
            flds = [flds(:);add_flds(:)];
        end

    end
    methods(Static)
        function obj = loadobj(inputs,varargin)
            inobj = binfile_v2_common();
            obj = loadobj@serializable(inputs,inobj,varargin{:});
        end
    end
end
