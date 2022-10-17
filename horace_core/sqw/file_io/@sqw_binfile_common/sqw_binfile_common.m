classdef sqw_binfile_common < sqw_file_interface
    % Class contains common logic and code used to access binary sqw files
    %
    %  Binary sqw-file accessors inherit this class, use common method,
    %  defined in this class, implement remaining abstract methods,
    %  inherited from sqw_file_interface and overload the methods, which
    %  have different data access requests.
    %
    % sqw_file_interface Methods:
    % Implemented accessors:
    % get_main_header - obtain information stored in main header
    %
    % get_exp_info      - obtain information stored in one of the
    %                   contributing file's header
    % get_detpar      - retrieve detectors information.
    % get_pix         - get PixelData object, containing pixels data
    % get_raw_pix     - get pixels array as it is stored on hdd
    % get_instrument  - get instrument information specific for a run
    % get_sample      - get sample information
    %
    % Implemented mutators:
    %
    % Common for all faccess_sqw_* classes:
    % put_main_header    - store main sqw file header.
    % put_headers        - store all contributing sqw file headers.
    % put_det_info       - store detectors information
    % put_pix            - store pixels information
    % put_sqw            - store whole sqw object, which involves all
    %                      put methods mentioned above
    %
    % extended, version specific interface:
    % put_instruments   -  store instruments information
    % put_samples       -  store sample's information
    %
    % upgrade_file_format - upgrade current sqw file to recent file format.
    %                       May change the sqw file and always opens it in
    %                       write or upgrade mode.
    %
    properties(Access=protected,Hidden=true)
        % position (in bytes from start of the file of the appropriate part
        % of Horace data information and the size of this part.
        % 0 means unknown/uninitialized or missing.
        main_header_pos_=26;
        main_head_pos_info_ =[];
        header_pos_=0;
        header_pos_info_ =[];
        detpar_pos_=0;
        detpar_pos_info_ =[];
        img_db_range_pos_ = 0;
        %
        pix_pos_=  'undefined';
        %
        eof_pix_pos_=0;
        %
        % identify the format of the data file.If true, filenames stored
        % with headers are mangled with run_id-s. If false, they are clean
        % filenames. Stored in file
        contains_runid_in_header_ =[];
    end
    properties(Dependent)
        % the position of pixels information in the file. Used to organize
        % separate access to pixel data;
        pix_position
    end
    properties(Constant)
        % size of a pixel (in bytes) written on HDD
        FILE_PIX_SIZE = 4*9;
    end
    %
    methods(Access = protected)
        function obj=init_from_sqw_obj(obj,varargin)
            % initialize the structure of sqw file using sqw object as input
            %
            % method should be overloaded or expanded by children if more
            % complex then common logic is used
            if nargin < 2
                error('HORACE:sqw_binfile_common:runtime_error',...
                    'init_from_sqw_obj method should be invoked with an existing sqw object as first input argument');
            end
            if ~(isa(varargin{1},'sqw') || is_sqw_struct(varargin{1}))
                error('HORACE:sqw_binfile_common:invalid_argument',...
                    'init_from_sqw_obj method should be initiated by an sqw object');
            end
            %
            [obj,sqw_obj] = init_headers_from_sqw_(obj,varargin{1});
            % initialize data fields
            % assume max data type which will be reduced if some fields are
            % missing (how they when initialized from sqw?)
            obj.data_type_ = 'a'; % should it always be 'a'?
            obj = init_from_sqw_obj@binfile_v2_common(obj,varargin{:});
            obj.sqw_holder_ = sqw_obj;

            obj = init_pix_info_(obj);            
        end
        %
        function obj=init_from_sqw_file(obj,varargin)
            % initialize the structure of faccess class using sqw file as input
            %
            % method should be overloaded or expanded by children if more
            % complex then common logic is used
            obj= init_sqw_structure_field_by_field_(obj,varargin{:});
        end
        %
        function [sub_obj,external] = extract_correct_subobj(obj,obj_name,varargin)
            % auxiliary function helping to extract correct subobject from
            % input or internal object
            [sub_obj,external]  = extract_correct_subobj_(obj,obj_name,varargin{:});
        end
        %
        %
        function bl_map = const_blocks_map(obj)
            bl_map  = obj.const_block_map_;
        end
        %
        function [obj,missinig_fields] = copy_contents(obj,other_obj,keep_internals,varargin)
            % the main part of the copy constructor, copying the contents
            % of the one class into another.
            %
            % Copied of binfile_v2_common to support overloading as
            % private properties are not accessible from parents
            %
            % keep_internals -- if true, do not overwrite service fields
            %                   not related to position information
            %
            if ~exist('keep_internals','var') || ischar(keep_internals)
                keep_internals = false;
            end
            [obj,missinig_fields] = copy_contents_(obj,other_obj,keep_internals);
        end
        %
        function obj = check_header_mangilig(obj,head_pos)
            % verify if the filename stored in the header is mangled with
            % run_id information or is it stored without this information.

            fn_size = head_pos(1).filepath_pos_ - head_pos(1).filename_pos_;
            do_fseek(obj.file_id_,head_pos(1).filename_pos_,'bof');
            [mess,res] = ferror(obj.file_id_);
            if res ~= 0
                error('HORACE:sqw_binfile_common:io_error',...
                    '%s: Reason:  Error moving to the header filename location',mess)
            end

            bytes = fread(obj.file_id_,fn_size,'char');
            fname = char(bytes');
            mangle_pos = strfind(fname,'$id$');
            if isempty(mangle_pos) %contains is available from 16b only
                obj.contains_runid_in_header_ = false;
            else
                obj.contains_runid_in_header_ = true;
            end
        end
        %
        function varargout = init_v3_specific(~)
            % Initialize position information specific for sqw v3.1 object.
            % Interface function here. Generic is not implemented and
            % actual implementation in faccess_sqw_v3
            error('SQW_FILE_IO:runtime_error',...
                'init_v3_specific: generic method is not implemented')
        end
        %
        function is_sqw = get_sqw_type(~)
            % Main part of get.sqw_type accessor
            % return true if the loader is intended for processing sqw file
            % format and false otherwise
            is_sqw = true;
        end
        function   obj_type = get_format_for_object(~)
            % main part of the format_for_object getter, specifying for
            % what class saving the file format is intended
            obj_type = 'sqw';
        end        
        
    end % end protected
    %
    methods % defined by this class
        % ---------   File Accessors:
        % get main sqw header
        main_header = get_main_header(obj,varargin);
        % get header of one of contributed files
        [header,pos] = get_exp_info(obj,varargin);
        % Read the detector parameters from properly initialized binary file.
        det = get_detpar(obj);
        %
        function img_db_range = get_img_db_range(obj,data_str)
            % get [2x4] array of min/max ranges of the image, representing
            % DND object.
            %
            %
            if nargin == 1 %read ge information form file (better accuracy)
                img_db_range = read_img_range(obj);
            else % calculate image range from axes
                img_db_range = axes_block.calc_img_db_range(data_str);
                if any(isinf(img_db_range(:)))
                    img_data_range = read_img_range(obj);
                    undef = isinf(img_db_range);
                    img_db_range(undef) = img_data_range(undef);
                end
            end
        end
        %
        function img_data_range = read_img_range(obj)
            % read real data range from disk
            do_fseek(obj.file_id_,obj.img_db_range_pos_,'bof');
            [mess,res] = ferror(obj.file_id_);
            if res ~= 0
                error('HORACE:sqw_binfile_common:io_error',...
                    'Can not move to the pix_range start position, Reason: %s',mess);
            end
            img_data_range = fread(obj.file_id_,[2,4],'float32');

        end
        %
        % read main sqw data  from properly initialized binary file.
        [sqw_data,obj] = get_data(obj,varargin);

        function pix_range = get_pix_range(~)
            % get [2x4] array of min/max ranges of the pixels contributing
            % into an object. Empty for DND object
            %
            pix_range = PixelDataBase.EMPTY_RANGE_;
        end

        % read pixels information
        pix = get_pix(obj,varargin);
        pix = get_raw_pix(obj,varargin);
        % read pixels at the given indices
        pix = get_pix_at_indices(obj,indices);
        % read pixels in the given index ranges
        pix = get_pix_in_ranges(obj,pix_starts,pix_ends,skip_validation,keep_precision);
        % retrieve the whole sqw object from properly initialized sqw file
        [sqw_obj,varargout] = get_sqw(obj,varargin);
        % ---------   File Mutators:
        % save or replace main file header
        obj = put_main_header(obj,varargin);
        %
        obj = put_headers(obj,varargin);
        %
        obj = put_det_info(obj,varargin);
        %
        obj = put_pix(obj,varargin);
        % Save new or fully overwrite existing sqw file
        obj = put_sqw(obj,varargin);
        %
        function obj = put_instruments(obj,varargin)
            error('HORACE:sqw_binfile_common:runtime_error',...
                'put_instruments is not implemented for faccess_sqw %s',...
                obj.file_version);
        end
        %
        function obj = put_samples(obj,varargin)
            error('HORACE:sqw_binfile_common:runtime_error',...
                'put_samples is not implemented for faccess_sqw %s',...
                obj.file_version);

        end
        %
        function pix_pos = get.pix_position(obj)
            % the position of pixels information in the file. Used to organize
            % class independent binary access to pixel data;
            pix_pos = obj.pix_pos_;
        end
        %
        %
        % return structure, containing position of every data field in the
        % file (when object is initialized)
        function   pos_info = get_pos_info(obj)
            % return structure, containing position of every data field in the
            % file (when object is initialized) plus some auxiliary information
            % used to fully describe this file
            %
            fields2save = obj.saveableFields();
            pos_info  = struct();
            for i=1:numel(fields2save)
                fld = fields2save{i};
                pos_info.(fld) = obj.(fld);
            end
        end
        %
        % ------- Interface stubs and helpers:
        function [inst,obj] = get_instrument(obj,varargin)
            % get instrument, stored in a file. If no instrument is
            % defined, return empty structure.
            inst = IX_null_inst();
        end
        %
        function [samp,obj] = get_sample(obj,varargin)
            % get sample, stored in a file. If no sample is defined, return
            % empty structure.
            samp = IX_samp();
        end
        %
        function pix_form = get_pix_form(~)
            %   data.img_range     The range of the data along each axis.
            %                      Belongs to image, but written only when
            %                      pixels are written
            %   data.dummy         4-byte field kept for compartibility
            %                      with old data formats
            %   data.pix_block     A field containing information about
            %                      contents of PixelData object. npixels
            %                      and PixelData.data array are usually
            %                      written here, which gives the size of
            %                      block: 8+npixels*9*4

            pix_form= struct('img_range',single([2,4]),...
                'dummy',field_not_in_structure('img_range'),...
                'pix_block',field_pix());
        end
        function img_db_range_pos = get_img_db_range_pos(obj)
            % returns byte-position from the start of the file
            % where pix range is stored
            img_db_range_pos  = obj.img_db_range_pos_;
        end
    end
    %
    methods(Static,Hidden=true)
        %
        function header = get_main_header_form(varargin)
            % Return the structure of the main header in the form it
            % is written on hdd.
            %
            % Usage:
            % >>header = obj.get_main_header_form();
            % >>header = obj.get_main_header_form('-const');
            %
            % Second option returns only the fields which do not change if
            % filename or title changes
            %
            % Fields in file are:
            % --------------------------
            %   main_header.filename   Name of sqw file that is being read, excluding path
            %   main_header.filepath   Path to sqw file that is being read, including terminating file separator
            %   main_header.title      Title of sqw data structure
            %   main_header.nfiles     Number of spe files that contribute
            %
            % The value of the fields define the number of dimensions of
            % the data except strings, which defined by the string length
            header = get_main_header_form_(varargin{:});
        end
        %
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
            %   header.efix         Fixed energy (ei or ef depending on emode)
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
            %   header.label       Labels of the projection axes [1x4 cell array of character strings]
            %
            header = get_header_form_(varargin{:});
        end
        %
        function detpar_form = get_detpar_form(varargin)
            % Return structure of the contributing file header in the form
            % it is written on hdd.
            % Usage:
            % header = obj.get_detpar_form();
            % header = obj.get_detpar_form('-const');
            %
            % Second option returns only the fields which do not change if
            % filename or title changes
            %
            %
            % Fields in the structure are:
            %
            % --------------------------
            %   det.filename    Name of file excluding path
            %   det.filepath    Path to file including terminating file separator
            %   det.group       Row vector of detector group number
            %   det.x2          Row vector of secondary flightpath (m)
            %   det.phi         Row vector of scattering angles (deg)
            %   det.azim        Row vector of azimuthal angles (deg)
            %                  (West bank=0 deg, North bank=90 deg etc.)
            %   det.width       Row vector of detector widths (m)
            %   det.height      Row vector of detector heights (m)
            %
            % one field of the file 'ndet' is written to the file but not
            % present in the structure, so has format: field_not_in_structure
            % group,x2,phi,azim,width and height array sizes are defined by
            % this structure size
            detpar_form = get_detpar_form_(varargin{:});
        end

        function sq = make_pseudo_sqw(nfiles)
            % generate pseudo-contents for sqw file, for purpose of
            % calculating fields positions while upgrading file format
            sq = make_pseudo_sqw_(nfiles);
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    properties(Constant,Access=private,Hidden=true)
        % list of field names to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        data_fields_to_save_ = {'main_header_pos_';'main_head_pos_info_';'header_pos_';...
            'header_pos_info_';'detpar_pos_';'detpar_pos_info_'};
        pixel_fields_to_save_ = {'img_db_range_pos_';...
            'pix_pos_';'eof_pix_pos_'};
    end
    %----------------------------------------------------------------------
    methods
        function strc = to_bare_struct(obj,varargin)
            base_cont = to_bare_struct@sqw_file_interface(obj,varargin{:});
            flds = [obj.data_fields_to_save_(:);obj.pixel_fields_to_save_(:)];

            cont = cellfun(@(x)obj.(x),flds,'UniformOutput',false);

            base_flds = fieldnames(base_cont);
            base_cont = struct2cell(base_cont);
            flds  = [base_flds(:);flds(:)];
            cont = [base_cont(:);cont(:)];
            %
            strc = cell2struct(cont,flds);
        end

        function obj=from_bare_struct(obj,indata)
            obj = from_bare_struct@sqw_file_interface(obj,indata);
            %
            flds = [obj.data_fields_to_save_(:);obj.pixel_fields_to_save_(:)];
            for i=1:numel(flds)
                name = flds{i};
                obj.(name) = indata.(name);
            end
        end

        function flds = saveableFields(obj)
            % return list of fileldnames to save on hdd to be able to recover
            % all substantial parts of appropriate sqw file.
            flds = saveableFields@sqw_file_interface(obj);
            flds = [obj.data_fields_to_save_(:);...
                obj.pixel_fields_to_save_(:);...
                flds(:)];
        end
    end
    methods(Static)
        function obj = loadobj(inputs,varargin)
            inobj = sqw_binfile_common();
            obj = loadobj@serializable(inputs,inobj,varargin{:});
        end
    end

end
