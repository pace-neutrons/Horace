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
        exper       = get_exp_info(obj,varargin);
        detpar      = get_detpar(obj,varargin);
        pix         = get_pix(obj,varargin);
        pix         = get_raw_pix(obj,varargin);
        % read pixels at the given indices
        pix         = get_pix_at_indices(obj,indices);
        % read pixels in the given index ranges
        pix         = get_pix_in_ranges(obj,pix_starts,pix_ends,skip_validation,keep_precision);
        range       = get_pix_range(obj);
        range       = get_data_range(obj);
        [inst,obj]  = get_instrument(obj,varargin);
        [samp,obj]  = get_sample(obj,varargin);
        %------------------------------------------------------------------
        % common write interface;
        obj = put_main_header(obj,varargin);
        obj = put_headers(obj,varargin);
        obj = put_det_info(obj,varargin);
        obj = put_pix(obj,varargin);
        obj = put_sqw(obj,varargin);
        % extended interface:
        obj = put_instruments(obj,varargin);
        obj = put_samples(obj,varargin);
    end
    methods(Abstract,Access=protected)
        pos = get_pix_position(obj);
        npix = get_npixels(obj);
    end
    methods(Access=protected)
        function pix_size = get_filepix_size(~)
            % 4 bytes x 9 columns -- default pixel size in bytes when
            % stored on hdd
            %
            % May be overloaded in some new file formats, but pretty
            % stable for now
            pix_size = 4*9;
        end
    end
end

