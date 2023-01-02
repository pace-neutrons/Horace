classdef faccess_dnd_v4 < binfile_v4_common
    % Class to access Horace dnd files written by Horace v4
    %
    % Main of class properties and methods are inherited from
    % <a href="matlab:help('binfile_v4_common');">binfile_v4_common</a>
    % class but this class provides classical faccess interface.
    %
    % Usage:
    % 1)
    %>>dnd_access = faccess_dnd_v4(filename)
    % or
    % 2)
    %>>dnd_access = faccess_dnd_v4(sqw_dnd_object,filename)
    %---------------------------------------------------------------
    %
    % 1)------------------------------------------------------------
    % First form initializes accessor to existing dnd file where
    % filename  :: the name of existing dnd file.
    %
    % Throws if file with filename is missing or is not written in dnd v4
    % format.
    %
    % To avoid attempts to initialize this accessor using incorrect sqw file,
    % access to existing sqw files should be organized using sqw format factory
    % namely:
    %
    % >> accessor = sqw_formats_factory.instance().get_loader(filename)
    %
    % If the sqw file with filename is dnd v1 or v2 sqw file, the sqw format factory will
    % return instance of this class, initialized for reading the file.
    % The initialized object allows to use all get/read methods described by horace_binfile_interface.
    %
    % 2)------------------------------------------------------------
    % Second form used to initialize the operation of writing new or updating existing dnd file.
    % where:
    % sqw_dnd_object:: existing fully initialized sqw or dnd object in memory.
    % filename      :: the name of a new or existing dnd object on disc
    %
    % Update mode is initialized if the file with name filename exists and can be updated,
    % i.e. has the same number of dimensions, binning and  axis. In this case you can modify
    % dnd metadata.
    %
    % if existing file can not be updated, it will be open in write mode.
    % If file with filename does not exist, the object will be open in write mode.
    %
    % Initialized faccess_dnd_v4 object allows to use write/update methods of dnd_format_interface
    % and all read methods if the proper information already exists in the file.
    %
    %
    %
    properties(Dependent)
        % interfaces to binary access outside of this class:
        % initial location of npix fields
        npix_position;
    end
    properties(Dependent,Hidden)
        % old data type, not relevant any more. Always b+ for dnd and ? for
        % sqw
        data_type
    end
    properties(Constant,Access=protected)
        % list of data blocks, this class maintains
        dnd_blocks_list_ = {data_block('data','metadata'),...
            dnd_data_block()}
    end
    methods
        function obj=faccess_dnd_v4(varargin)
            % constructor, to build sqw reader/writer version 4
            %
            % Usage:
            % ld = faccess_dnd_v4() % initialize empty sqw reader/writer
            %                       version 4.
            %                       The class should be initialized later
            %                       using init method
            % ld = faccess_dnd_v4(filename) % initialize sqw reader/writer
            %                       version 4  to load sqw file version 4.
            %                       Throw error if the file version is not
            %                       sqw version 4.
            % ld = faccess_dnd_v4(dnd_object) % initialize sqw
            %                       reader/writer version 4
            %                       to save dnd object provided. The name
            %                       of the file to save the object should
            %                       be provided separately or as the second
            %                       argument of the constructor in this
            %                       form.
            %
            obj = obj@binfile_v4_common(varargin{:});
        end
        %
    end
    %======================================================================
    % Define old interface, still relevant and usefule
    methods
        function pos = get.npix_position(obj)
            if isempty(obj.bat_) || ~obj.bat_.initialized
                pos = [];
                return
            end
            bl = obj.bat_.get_data_block(faccess_dnd_v4.dnd_blocks_list{2});
            pos = bl.npix_position;
        end
        %
        %---------------------------------------------------------
        % equivalent to get_dnd_data but returning dnd_data structure,
        % rather then
        [dnd_dat,obj]  = get_dnd_data(obj,varargin);
        [dnd_info,obj] = get_dnd_metadata(obj,varargin);

        [dnd_obj,obj]  = get_dnd(obj,varargin); % retrieve any sqw/dnd object as dnd object

        %
        % ----------------------------------------------------------------
        % save sqw/dnd object stored in memory into binary sqw file as dnd object.
        % it always reduced data in memory into dnd object on hdd
        obj = put_dnd(obj,varargin);
        % write indofmation, describing dnd object
        obj = put_dnd_metadata(obj,varargin);
        % write dnd image data, namely s, err and npix
        obj = put_dnd_data(obj,varargin);

        %
        function [obj,file_exist,old_ldr] = set_file_to_update(obj,filename)
            if ~exist('filename','var')
                filename = obj.full_filename;
            end
            [obj,file_exist,old_ldr] = set_file_to_update@horace_binfile_interface(obj,filename,nargout);
            if file_exist && old_ldr.faccess_version ~= obj.faccess_version
                dnd_obj = old_ldr.get_dnd();
                obj.sqw_holder = dnd_obj;
                obj = obj.put_dnd();
            else
                old_ldr.delete();
            end
        end
    end
    %----------------------------------------------------------------------
    % Old, partially redundant interface
    methods
        function dt = get.data_type(obj)
            dt = get_data_type(obj);
        end
        [inst,obj]  = get_instrument(obj,varargin); % return instrument stored with sqw file or empty structure if
        %                                             nothing is stored. Always empty for dnd objects.
        [samp,obj]  = get_sample(obj,varargin);   % return sample stored with sqw file or empty structure if
        %                                           nothing is stored. Always empty for dnd objects.
        function [sqw_obj,varargout] = get_sqw(obj,varargin)
            % retrieve the whole sqw or dnd object from properly initialized sqw file
            if nargout > 1
                [sqw_obj,varargout{1}] = obj.get_dnd(varargin{:});
            else
                sqw_obj = obj.get_dnd(varargin{:});
            end
        end
        function  [data,obj] =  get_data(obj,varargin)
            % equivalend to get_dnd('-noclass)
            is_key = cellfun(@(x)(ischar(x)||isstring(x))&&startsWith(x,'-'), ...
                varargin);
            if any(is_key)
                is_noclass = ismember('-noclass',varargin(is_key));
                if is_noclass
                    argi = varargin;
                else
                    argi = [varargin(:);'-noclass'];
                end
            else
                argi = varargin;
            end
            [data,obj] = obj.get_dnd(argi{:});
        end
        % -----------------------------------------------------------------
        function pix_range = get_pix_range(~)
            % get [2x4] array of min/max ranges of the pixels contributing
            % into an object. Empty for DND object
            pix_range = double.empty(0,4);
        end

        %
        function obj = put_sqw(obj,varargin)
            % save sqw object stored in memory into binary sqw file as dnd
            % file
            obj = obj.put_dnd(obj,varargin{:});
        end
        function img_db_range = get_img_db_range(obj,varargin)
            % get [2x4] array of min/max ranges of the image where pixels
            % are rebinned into
            ds = obj.get_dnd_metadata();
            img_db_range  = ds.img_range;
        end
        function [data_str,obj] = get_se_npix(obj,varargin)
            % get only dnd image data, namely s, err and npix
            data_dnd = obj.get_dnd_data(varargin{:});
            data_str = struct('s',data_dnd.signal,'e',data_dnd.error, ...
                'npix',data_dnd.npix);
        end
    end
    %----------------------------------------------------------------------
    methods(Access=protected)
        function  dt = get_data_type(~)
            % overloadable accessor for the class datatype function
            dt  = 'b+';
        end
        function bll = get_data_blocks(~)
            % Return list of data blocks, defined on this class
            % main bat of data_blocks getter. Protected for possibility to
            % overload
            bll = faccess_dnd_v4.dnd_blocks_list_;
        end
        function is_sqw = get_sqw_type(~)
            % Main part of get.sqw_type accessor
            % return true if the loader is intended for processing sqw file
            % format and false otherwise
            is_sqw = false;
        end
        %
        obj = do_class_dependent_changes(obj,other_obj)
    end
    %======================================================================
    % SERIALIZABLE INTERFACE FULLY INHERITED FROM binfile_v4_common    
end
