classdef hor_config < config_base
    % Create the Horace configuration that sets memory options and some other defaults.
    %
    % To see the list of current configuration option values:
    %   >> hor_config
    %
    % To set values:
    %   >> hc = hor_config();
    %   >> hc.name1=val1;
    % or
    %   >> set(hor_config,'name1',val1,'name2',val2,...)
    %
    %
    % To fetch values:
    % >> val1 = hor_config.name1;
    %or
    % >>[val1,val2,...]=get(hor_config,'name1','name2',...)
    %
    %
    % hor_config properties are:
    % -----------
    %   mem_chunk_size    - Maximum length of buffer array to accumulate pixels
    %                       from an input file.
    %   ignore_nan        - Ignore NaN data when making cuts
    %   ignore_inf        - Ignore Inf data when making cuts.
    %   log_level         - Set verbosity of informational output.
    %   use_mex           - Use mex files for time-consuming operation, if available
    %   delete_tmp        - Automatically delete temporary files after generating sqw files
    %   working_directory - The folder to write tmp files.
    %   --
    %   high_perf_config_info - helper/compatibility property to access high performance
    %                       computing settings. Use hpc_config to modify hpc
    %                       settings itself.
    %
    %   force_mex_if_use_mex - Fail if mex can not be used. Used in mex files debugging
    %--
    %   high_perf_config_info  - an interface, displaying high performance computing settings.
    %                       Use hpc_config class directly to modify these
    %                       settings.
    %   init_tests          Enable the unit test functions
    %
    %
    properties(Dependent)
        % Maximum number of pixels that are processed at one go during cuts
        % on usual machine with 16Gb of RAM it is 10^7  (higher value does
        % not provide obvious performance benefits) but on older machines
        % with ~4Gb it has to be reduced to 10^6
        mem_chunk_size

        % ignore NaN values if pixels have them.  %  (default --true)
        ignore_nan

        % ignore inf values if pixels have them. %  (default --false)
        ignore_inf

        % The verbosity of the log messages
        %      The larger the value, the more information is printed, e.g.:
        %  -1  No information messages printed
        %   0  Major information messages printed
        %   1  Minor information messages printed in addition
        %   2  Time of the run measured and printed as well.
        log_level

        % use mex-code for time-consuming operations
        % default -- true if mex files are compiled
        use_mex

        % automatically delete temporary files after generating sqw files
        % by default its true, but you may set it to false to keep files
        % for later operations.
        delete_tmp

        % the folder where tmp files should be stored.
        % by default gen_sqw sets this value to place where spe files are
        % located.  If you never did gen_sqw on a given machine,
        % system tmp directory is used.
        % Change this value to point to a fast&large disk or to a
        % parallel file system.
        % Assign empty value to restore it to default (system tmp
        % directory)
        working_directory

        % testing and debugging option -- fail if mex can not be used
        % By default if mex file fails, program tries to use Matlab, but
        % if this option is set to true, the whole operation may fail.
        force_mex_if_use_mex

        % the property, related to high performance computing settings.
        % Here it provided for information only while changes to this
        % property should be made through hpc_config class setters directly.
        high_perf_config_info

        % add unit test folders to search path (option for testing)
        init_tests;
    end

    properties(Dependent,SetAccess=private)
        % location of the folder with unit tests
        unit_test_folder;

    end

    properties(Dependent,Hidden)
        % old implementation of log_level property
        % set horace_info_level method indicating how verbose Horace would be.
        %      The larger the value, the more information is printed.
        % See log_level for more details.
        horace_info_level

        %   pixel_page_size   - Maximum memory size of pixel data array in
        %                       file-backed algorithms (units of bytes).
        % PixelData page size in bytes. Overrides mem_chunk_size for
        % filebased PixelData if pixel_page_size is smaller then
        % appropriate mem_chunk_size expressed in bytes.
        pixel_page_size

        % Information field:
        % true, if working directory has not ever been set
        wkdir_is_default;
    end

    properties(Access=protected, Hidden=true)
        % private properties behind public interface
        mem_chunk_size_ = 10000000;

        ignore_nan_ = true;
        ignore_inf_ = false;

        use_mex_ = true;
        delete_tmp_ = true;

        force_mex_if_use_mex_ = false;
        log_level_ = 1;
        init_tests_ = false;
    end

    properties(Constant, Access=private)
        % change this list if saveable fields have changed or redefine
        % get_storage_field_names function below
        saved_properties_list_ = {...
            'mem_chunk_size', ...
            'ignore_nan',...
            'ignore_inf', ...
            'use_mex',...
            'delete_tmp', ...
            'force_mex_if_use_mex', ...
            'log_level', ...
            'init_tests'}
    end

    methods
        function obj=hor_config()
            obj=obj@config_base(mfilename('class'));
        end

        %-----------------------------------------------------------------
        % overloaded getters

        function use = get.mem_chunk_size(obj)
            use = get_or_restore_field(obj,'mem_chunk_size');
        end

        function page_size = get.pixel_page_size(obj)
            chunk_size = obj.mem_chunk_size;
            page_size = chunk_size*sqw_binfile_common.FILE_PIX_SIZE;
        end

        function use = get.ignore_nan(obj)
            use = get_or_restore_field(obj,'ignore_nan');
        end

        function use = get.ignore_inf(obj)
            use = get_or_restore_field(obj,'ignore_inf');
        end

        function level = get.log_level(obj)
            level = get_or_restore_field(obj,'log_level');
        end

        function level = get.horace_info_level(obj)
            % overloaded to use the same log_level real property
            level = obj.log_level;
        end

        function use = get.use_mex(obj)
            use = get_or_restore_field(obj,'use_mex');
        end

        function force = get.force_mex_if_use_mex(obj)
            force = get_or_restore_field(obj,'force_mex_if_use_mex');
        end

        function delete = get.delete_tmp(obj)
            delete = get_or_restore_field(obj,'delete_tmp');
        end

        function work_dir = get.working_directory(~)
            work_dir  = config_store.instance().get_config_field('parallel_config','working_directory');
            if isempty(work_dir)
                work_dir = tmp_dir;
            end
        end

        function doinit = get.init_tests(this)
            doinit = get_or_restore_field(this,'init_tests');
        end

        function is = get.wkdir_is_default(~)
            % return true if working directory has not been set and refers
            % to default (system tmp) directory
            % Usage
            %>>is = hor_config_instance.wkdir_is_default;
            %
            work_dir  = config_store.instance().get_config_field('parallel_config','working_directory');
            is = isempty(work_dir);
        end

        function hpcc = get.high_perf_config_info(~)
            hpcc = hpc_config;
        end

        %-----------------------------------------------------------------
        % overloaded setters
        function obj = set.mem_chunk_size(obj,val)

            % Don't allow non-integer values, may cause weird effects
            val = ceil(val);
            if val<1000
                warning('HOR_CONFIG:set_mem_chunk_size',...
                    ' mem chunk size should not be too small at least 1M is recommended');
            end
            size = sys_memory();

            if val*sqw_binfile_common.FILE_PIX_SIZE >= size/3
                if val <= size*0.8
                    warning('HORACE:invalid_argument', ...
                        'Buffer chunk size exceeds 1/3 of available physical memory. HORACE may got unstable, trying to use such chunk in calculations')
                else
                    error('HORACE:hor_config:invalid_argument', ...
                        'attempt to set up mem_chunk_size exceeding 0.8 of total physical memory available (Evaluated to: %dkB). This would not work',...
                        floor(size/1024))

                end
            end
            config_store.instance().store_config(obj,'mem_chunk_size',val);
        end

        function obj = set.ignore_nan(obj,val)
            ignore = val>0;
            config_store.instance().store_config(obj,'ignore_nan',ignore);
        end

        function obj = set.ignore_inf(obj,val)
            ignore = val>0;
            config_store.instance().store_config(obj,'ignore_inf',ignore);
        end

        function obj = set.log_level(obj,val)
            if ~isnumeric(val)
                error('HOR_CONFIG:set_log_level',' log level must be a number')
            end
            config_store.instance().store_config(obj,'log_level',val);
        end

        function obj = set.horace_info_level(obj,val)
            obj.log_level = val;
        end

        function obj = set.use_mex(obj,val)
            use = val>0;
            if use
                % Configure mex usage
                % --------------------
                [~, n_errors, can_combine_with_mex] = check_horace_mex();
                if n_errors>0
                    use = false;
                    warning('HOR_CONFIG:set_use_mex',...
                        ' mex files can not be initiated, Use mex set to false');
                end
                if ~can_combine_with_mex
                    config_store.instance().store_config(obj,'combine_sqw_using','matlab');
                end

            end
            config_store.instance().store_config(obj,'use_mex',use);

        end

        function obj=set.init_tests(obj,val)
            init = val > 0;
            path = process_unit_test_path(init,'set_path');
            if (init && ~isempty(path)) || ~init
                config_store.instance().store_config(obj,'init_tests',init);
            end
        end

        function obj = set.force_mex_if_use_mex(obj,val)
            use = val>0;
            config_store.instance().store_config(obj,'force_mex_if_use_mex',use);
        end

        function obj = set.delete_tmp(obj,val)
            del = val>0;
            config_store.instance().store_config(obj,'delete_tmp',del);
        end

        function obj = set.working_directory(obj,val)
            hc = parallel_config;
            hc.working_directory = val;
        end

        function folder=get.unit_test_folder(obj)
            % getter for dependent property unit_test_folder;
            init = get_or_restore_field(obj,'init_tests');
            if init
                folder = process_unit_test_path(init);
            else
                folder =[];
            end
       end

        function obj = set_unit_test_path(obj)
            % add Herbert unit test path to Matlab search path
            %
            % (overwrite Matlab's version of unit tests functions which
            % come with Matlab 2017b and have the interface different from
            % the classical unit tests.
            process_unit_test_path(true,'set_path');
        end

        %--------------------------------------------------------------------

        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function fields = get_storage_field_names(obj)
            % helper function returns the list of the public names of the fields,
            % which should be saved
            fields = obj.saved_properties_list_;
        end

        function value = get_internal_field(obj,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface.
            % Relies on assumption, that each public
            % field has a private field with name different by underscore
            value = obj.([field_name,'_']);
        end

    end
end
