classdef sqw_file_interface
    % Class describes interface to access sqw files. The whole public
    % interface to access files, containing sqw objects consists of
    % horace_binfile_interface and sqw_file_interface.
    %
    % Various accessors should inherit these interfaces, implement the
    % abstract methods mentioned there and define protected fields,
    % common for all sqw-file accessors.
    %
    % sqw_file_interface Methods:
    % Abstract accessors:
    % get_main_header - obtain information stored in main header
    %
    % get_exp_info    - obtain information stored in one of the
    %                   contributing file's header
    % get_detpar      - retrieve detectors information.
    % get_pix         - get PixelData object, containing pixels data
    % get_raw_pix     - get pixels array as it is stored on hdd
    % get_instrument  - get instrument information specific for a run
    % get_sample      - get sample information
    %
    % Abstract mutators:
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
    properties(Access=protected)
        % holdef for the number of contributing files contributed into sqw
        % file. Not necessary for modern file formats but was used in old
        % file formats to recover headers
        num_contrib_files_= 'undefined'
    end
    %
    properties(Dependent)
        % number of files, the sqw file was constructed from
        num_contrib_files;
        %
        % number of pixels, contributing into this file.
        npixels
        % the position of pixels information in the file. Used to organize
        % separate access to the pixel data;
        pix_position

        % size of a pixel (in bytes) stored in binary file,
        % for the loader to read
        pixel_size;
    end
    properties(Dependent,Hidden)
        % service property, necessary for proper memmapfile class
        % construction. Calculates the position of the end of pixel dataset
        % (position of the first byte after pixel data)
        pixel_data_end
        % service property, necessary for proper memmapfile class
        % construction. Calculates the actual position of sqw eof.
        eof_position;
    end
    %----------------------------------------------------------------------
    methods
        function pos = get.pix_position(obj)
            pos = get_pix_position(obj);
        end
        function nfiles = get.num_contrib_files(obj)
            % return number of run-files contributed into sqw object
            % provided as input of
            nfiles = obj.num_contrib_files_;
        end
        function obj = set.num_contrib_files(obj,val)
            % set number of run-files contributed into sqw object.
            %
            % Request serializable interface applied on new faccessor
            % format. Old faccessors have this property strictly private
            % but this contradicts the need to set up object from the
            % serializable interface
            %
            if isempty(val) || ischar(val)&&(strcmp(val,'undefined'))
                obj.num_contrib_files_ = 'undefined';
                return;
            end
            if ~(isnumeric(val)&&isscalar(val)&&val > 0)
                error('HORACE:sqw_file_inteface:invalid_argument', ...
                    'number of contriburing files have to be a single positive number. It is: %s',...
                    disp2str(val))
            end
            obj.num_contrib_files_ = round(val);
        end

        %
        function npix = get.npixels(obj)
            npix = get_npixels(obj);
        end
        function pix_size = get.pixel_size(obj)
            pix_size = get_filepix_size(obj);
        end
        %
        function pos = get.eof_position(obj)
            if isempty(obj.file_id) || obj.file_id <1
                pos = [];
            else
                fseek(obj.file_id,0,'eof');
                pos  = ftell(obj.file_id);
            end
        end
        function pos = get.pixel_data_end(obj)
            if ischar(obj.pix_position) ||isempty(obj.pix_position) || ...
                    ischar(obj.npixels)||isempty(obj.npixels)
                pos  = [];
            else
                pos = obj.pix_position+obj.npixels*obj.pixel_size;
            end
        end
        %-------------------------
        function obj = delete(obj)
            % destructor, which is not fully functioning
            % operation for normal(non-handle) Matlab classes.
            % Usually needs the class on lhs of delete expression or
            % understanding when this can be omitted
            %
            obj.num_contrib_files_ = 'undefined';
        end
        %
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    methods(Abstract)
        % retrieve different parts of sqw data
        %------------------------------------------------------------------
        main_header = get_main_header(obj,varargin);
        [exper,obj] = get_exp_info(obj,varargin);
        detpar      = get_detpar(obj,varargin);
        pix         = get_pix(obj,varargin);
        pix         = get_raw_pix(obj,varargin);
        % read pixels at the given indices
        pix         = get_pix_at_indices(obj,indices);
        % read pixels in the given index ranges
        pix         = get_pix_in_ranges(obj,pix_starts,pix_ends,skip_validation,keep_precision);
        range       = get_pix_range(obj);
        [meta,obj]  = get_pix_metadata(obj);
        [range,obj] = get_data_range(obj);
        [inst,obj]  = get_instrument(obj,varargin);
        [samp,obj]  = get_sample(obj,varargin);
        %------------------------------------------------------------------
        % common write interface;
        obj = put_main_header(obj,varargin);
        obj = put_headers(obj,varargin);
        obj = put_det_info(obj,varargin);
        obj = put_pix(obj,varargin);
        obj = put_pix_metadata(obj,varargin);
        obj = put_raw_pix(obj,pix_data,pix_idx,varargin);
        obj = put_sqw(obj,varargin);
        % extended interface:
        obj = put_instruments(obj,varargin);
        obj = put_samples(obj,varargin);

    end
    methods(Abstract,Access=protected)
        pos = get_pix_position(obj);
        npix = get_npixels(obj);
        % used in updates of old file format to file format v4
        obj = update_sqw_keep_pix(obj)
    end
    methods(Access=protected)
        function obj = put_sqw_data_pix_from_file(obj, pix_comb_info,jobDispatcher)
            % Write pixel information to file, reading that pixel information from a collection of other files
            %
            %   >> obj = put_sqw_data_pix_from_file (obj, pix_comb_info,jobDispatcher)
            %

            obj = put_sqw_data_pix_from_file_(obj, pix_comb_info,jobDispatcher);
        end

        function pix_size = get_filepix_size(~)
            % 4 bytes x 9 columns -- default pixel size in bytes when
            % stored on hdd
            %
            % May be overloaded in some new file formats, but pretty
            % stable for now
            pix_size = 4*9;
        end

        function head_struc = shuffle_fields_form_sqw_head(obj,head_struc,full_data)
            % take the head structure, obtained from dnd_head operation and
            % modify it shifting appropriate fields and adding fields,
            % specific for sqw header
            % Inputs:
            % head_struc  -- the structure obtained from head applied on
            %                 dnd object
            % full_data   -- true/false indicating if full dnd header
            %                structure is requested
            %
            % Produce head of sqw file in a standard form
            fields_req = sqw.head_form(false,full_data);
            dnd_val = struct2cell(head_struc);
            if full_data
                [~,data_fields] = DnDBase.head_form();
                data_ind = ismember(fieldnames(head_struc),data_fields);
                data_val = dnd_val(data_ind);
                dnd_val  = dnd_val(~data_ind);
            else
                data_val  = {};
            end
            sqw_val = {obj.num_contrib_files,obj.npixels,...
                   obj.get_data_range(),obj.creation_date};
            all_val = [dnd_val(1:end-1);sqw_val(:);data_val(:)];
            head_struc = cell2struct(all_val,fields_req);

        end

    end
end

