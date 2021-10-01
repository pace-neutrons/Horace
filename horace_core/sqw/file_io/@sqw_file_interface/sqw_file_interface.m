classdef sqw_file_interface < dnd_binfile_common
    % Class describes interface to access sqw files. The whole public
    % interface to access files, containing sqw objects consists of
    % dnd_file_interface and sqw_file_interface.
    %
    % Various accessors should inherit these interfaces, implement the
    % abstract methods mentioned there and define protected fields,
    % common for all sqw-file accessors.
    %
    % sqw_file_interface Methods:
    % Abstract accessors:
    % get_main_header - obtain information stored in main header
    %
    % get_header      - obtain information stored in one of the
    %                   contributing file's header
    % get_detpar      - retrieve detectors information.
    % get_pix         - get pixels info
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
    % upgrade_file_format - upgrade current sqw file to recent file format.
    %                       May change the sqw file and always opens it in
    %                       write or upgrade mode.
    
    %
    %
    properties(Access=protected,Hidden=true)
        %
        num_contrib_files_= 'undefined'
        %
        npixels_ = 'undefined';
    end
    %
    properties(Dependent)
        % number of files, the sqw file was constructed from
        num_contrib_files;
        %
        % number of pixels, contributing into this file.
        npixels

        % size of a pixel (in bytes) stored in binary file, 
        % for the loader to read
        pixel_size;        
    end
    properties(Constant,Access=private,Hidden=true)
        % list of field names to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        fields_to_save_ = {'num_contrib_files_';'npixels_'};
    end
    methods(Access = protected,Hidden=true)
        function obj=init_from_structure(obj,obj_structure_from_saveobj)
            % init file accessors using structure, obtained for object
            % serialization (saveobj method);
            obj = init_from_structure@dnd_binfile_common(obj,obj_structure_from_saveobj);
            flds = obj.fields_to_save_;
            for i=1:numel(flds)
                if isfield(obj_structure_from_saveobj,flds{i})
                    obj.(flds{i}) = obj_structure_from_saveobj.(flds{i});
                end
            end
        end
        %
        function flds = fields_to_save(obj)
            % return list of fileldnames to save on hdd to be able to recover
            % all substantial parts of appropriate sqw file.
            flds = fields_to_save@dnd_binfile_common(obj);
            flds = [obj.fields_to_save_(:);flds(:)];
        end 
    end
    
    %----------------------------------------------------------------------
    methods
        function nfiles = get.num_contrib_files(obj)
            % return number of run-files contributed into sqw object
            % provided
            nfiles = obj.num_contrib_files_;
        end
        %
        function npix = get.npixels(obj)
            npix = obj.npixels_;
        end
        function pix_size = get.pixel_size(~)
            % 4 bytes x 9 columns -- default pixel size.
            %
            % TODO:
            % No other size is currently supported by loaders. If this, one
            % day, changes, the class hierarchy should be tinkered with.
            pix_size = 4*9;
        end
        %-------------------------
        function obj = delete(obj)
            % destructor, which is not fully functioning
            % operation for normal(non-handle) Matlab classes.
            % Usually needs the class on lhs of delete expression or
            % understanding when this can be omitted
            %
            obj.num_contrib_files_ = 'undefined';
            obj.npixels_ = 'undefined';
            obj = delete@dnd_binfile_common(obj);
            % its still sqw loader
            obj.sqw_type_ = true;
        end
        %
        function struc = saveobj(obj)
            % method used to convert object into structure
            % for saving it to disc.
            struc = saveobj@dnd_binfile_common(obj);
            flds = obj.fields_to_save_;
            for i=1:numel(flds)
                struc.(flds{i}) = obj.(flds{i});
            end
            %struc = structIndep(obj);
            % dynamic fields, containing special information generated on
            % % construction. Should not be stored
            % caches = {'sqw_serializer_','file_closer_','sqw_holder_'};
            % struc = rmfield(struc,caches);
        end        
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    methods(Abstract)
        % retrieve different parts of sqw data
        %main_header = get_main_header(obj,['-verbatim']);
        main_header = get_main_header(obj,varargin);
        %
        [header,pos]= get_header(obj,varargin);
        detpar      = get_detpar(obj,varargin);
        pix         = get_pix(obj,varargin);
        range       = get_pix_range(obj);        
        [inst,obj]  = get_instrument(obj,varargin);
        [samp,obj]  = get_sample(obj,varargin);
        
        % common write interface;
        obj = put_main_header(obj,varargin);
        obj = put_headers(obj,varargin);
        obj = put_det_info(obj,varargin);
        obj = put_pix(obj,varargin);
        obj = put_sqw(obj,varargin);
        % extended interface:
        obj = put_instruments(obj,varargin);
        obj = put_samples(obj,varargin);
        % upgrade current sqw file to recent file format. May change the
        % sqw file and always opens it in write mode.
        new_obj = upgrade_file_format(obj,varargin);
    end
end

