classdef SQW_GENCUT_perf_tester < TestPerformance
    % Class-base for tests, which verify the performance of main
    % Horace algorithms
    % during sqw file generation and
    % different cuts, done over the test sqw files.
    %
    % The performance results (in second) are stored in a Matlab binary file
    % combining results for all hosts where the tests were run
    % The format of the file is as follows:
    % -host_name1_testClassName...
    %            ->test_name1(nworkers)->test_time(sec)
    %           |->test_name2(nworkers)->test_time(sec)
    %           |->test_name3(nworkers)->test_time(sec)
    % -host_name2_testClassName...
    %            ->test_name1(nworkers)->test_time(sec)
    %           |->test_name2(nworkers)->test_time(sec)
    %           |->test_name3(nworkers)->test_time(sec)
    %
    % where nworkers is the number of parallel workers used to process the
    % data  and the test_name is the name, specified as input to
    % save_or_test_performance method
    % The host_name is the variable combined from the prefix containing the
    % output of Herbert getHostName function
    % and the suffix containing the number of files used as the input for
    % the test.
    %
    %
    properties(Dependent)
        %  Number of input files to use. Depending on this number the test
        %  would verify small, large or huge datasets
        n_files_to_use% ;
        % the byte-size of the sample file, used to estimate the
        % performance in Gb/sec
        sample_data_size
        % The size of generated data (in GB (giga bytes))
        data_size
        % The names of the tests, used as the fields of the database
        % (test_nameN(nWorkergs) above)
        default_test_names
    end

    properties
        % if true, generate source nxspe files
        generate_nxspe_files  = true;
        % if true, delete resulting test sqw file after completeon
        delete_resulting_sqw_file = true;
        % delete nxspe files used for generation after gen_sqw is completed
        delete_generated_nxspe_files = true;

        % if true, when number of test files changes, (n_files_to_use)
        % build sqw file directly, writing and combining tmp files,
        % not building contributing nxspe files for testing gen_sqw performance
        % Also keep this file for future usage
        build_sqw_file_directly = false;
        % directory, containing data file necessary for the tests
        source_data_dir
        % directory to keep temporary working files
        working_dir
        %
        % target file for gen_sqw command and source file for cut commands
        sqw_file = 'SQW_WORKFLOW_perfTest_source'
        % the par file, used in test files generation
        par_file = 'MERLIN_one2one_181.par'
        % number of energy transfer bins used by test files generation routine
        num_energy_bins = 220;
        % if replicate mode selected, run gen_sqw in replicate mode
        % and not generate source file name. gen_sqw from single source but
        % different parameters.
        replicate_mode = true;
    end

    properties(Access=protected)
        % list of source files to process
        test_source_files_list_
        %
        %  Number of input files to use. Depending on this number the test
        %  would verify small, large or huge datasets
        n_files_to_use_ = 0;
        %
        % Total size of generated data (in GB)
        data_size_
        % the byte-size of the sample file, used to estimate the
        % performance in GB/sec and equal to n_detectors*nEnerty_transfer_Bins.
        % The value is defined by the size of the reference template file
        % to use
        sample_data_size_ = 0;
        %
        default_test_names_ = containers.Map();
        %
        % format of the filenames used as the source of the test data
        template_name_form_ = 'MER_fake_run_N%03d';
        % Template file name: the name of the file used as a template for
        % others.
        source_template_file_ = 'MER19566_22.0meV_one2one125.nxspe';
        
    end
    methods
        %------------------------------------------------------------------
        function obj = SQW_GENCUT_perf_tester(varargin)
            % create test suite, generate source files and load existing
            % performance data.
            %
            % usage:
            % tester = test_SQW_GENCUT_perf([test_name,['previous test results file name']])
            %
            if nargin > 0
                if nargin> 1
                    argi = varargin;
                else
                    argi = {'SQW_GENCUT_perf',varargin{1}};
                end
            else
                argi = {'SQW_GENCUT_perf',...
                    TestPerformance.default_PerfTest_fname(mfilename('fullpath'))};
            end
            obj = obj@TestPerformance(argi{:});
            %
            % define the list of the tests available to run
            obj.tests_available_ = {'gen_sqw','combine_sqw','small_cut',...
                'big_cut_nopix','big_cut_filebased'};
            %
            obj.source_data_dir = pwd();
            % locate the test data folder
            stat = mkdir('test_SQWGEN_performance_rw_test');
            clob = onCleanup(@()rmdir('test_SQWGEN_performance_rw_test','s'));
            if stat == 1
                clear clob;
                obj.working_dir = obj.source_data_dir;
            else
                obj.working_dir = tmpdir;
            end
            % set up the default number of files to use and prepare all
            % dependent properties to work with them.
            obj.n_files_to_use = obj.n_files_to_use_;
            % add target sqw files to cleanList to delete it after test is
            % completed if the file is not requested any more
            if obj.delete_resulting_sqw_file
                obj.add_to_files_cleanList(obj.sqw_file);
            end
        end

        %------------------------------------------------------------------
        % Interface defining existing perfornance tests
        %
        [perf,varargout]=gen_sqw_task_performance(obj,field_names_map,combine_only)
        [perf,varargout]=small_cut_task_performance(obj,field_names_map);
        [perf,varargout]=large_cut_nopix_task_performance(obj,field_names_map);
        [perf,varargout]=large_cut_pix_fbased_task_perfornance(obj,field_names_map);
        %
        [perf,varargout]=combine_task_performance(obj,varargin);

        %------------------------------------------------------------------
        function nf = get.n_files_to_use(obj)
            % number of test files, used in performance tests
            nf = obj.n_files_to_use_;
        end
        %
        function [psi,efix,alatt,angdeg,u,v,omega,dpsi,gl,gs,...
                en,par_file,alatt_true,angdeg_true,qfwhh,efwhh,rotvec]=...
                gen_sqw_parameters(obj)
            pths = horace_paths;
            % return list of the parameters, used for sqw file generation
            % set up the exactly the same parameters as defined below
            % in test_gensqw_performance method.
            efix= 22.8;%incident energy in meV
            alatt=10.7488*[1 1 1];%lattice parameters [a,b,c]
            angdeg=[90,90,90];%lattice angles [alpha,beta,gamma]
            u=[1,1,0];%u=// to incident beam
            v=[0,0,1];%v= perpendicular to the incident beam, pointing towards the large angle detectors on Merlin in the horizontal plane
            omega=0;
            dpsi=-1.8464+(0.9246);
            gl=-3.1871+(-0.1634);
            gs=-1.7047+(0.0028);

            nfiles=obj.n_files_to_use_;
            %psi angles (in degrees). Should be the same number of these as there are runs
            %also the first element of irun must correspond to the first element of psi, and so on.
            psi= 0.5*(1:nfiles);

            %  parameters, used at fake sqw files generation
            step = (21+1)/obj.num_energy_bins;
            en=-1:step:21;
            par_file = fullfile(pths.test_common,obj.par_file);

            alatt_true=[10.5,10.5,10.5];
            angdeg_true=[90,90,90];
            qfwhh=0.1;                  % Spread of Bragg peaks
            efwhh=1;                    % Energy width of Bragg peaks
            rotvec=[10,10,0]*(pi/180);  % orientation of the true lattice w.r.t reference lattice
        end
        %-------------------------------------------------------------

        function set.n_files_to_use(obj,val)
            % change number of files to use and modify all related
            % internal properties which depends on this number
            %
            obj.n_files_to_use_ = floor(abs(val));
            if obj.n_files_to_use_ < 0
                obj.n_files_to_use_ = 0;
            end
            % change performance suite name as different number of input
            % files has different impact on performance, so tests keys to
            % store performance results should be different
            %
            perf_test_name = obj.build_test_suite_name(['nf',num2str(obj.n_files_to_use_)]);
            obj.perf_suite_name = perf_test_name;
            %
            pc = parallel_config;
            if pc.wkdir_is_default
                pc.working_directory = obj.source_data_dir;
            end
            [~,fb] = fileparts(obj.sqw_file);
            [~,fb] = fileparts(fb);
            obj.sqw_file = fullfile(obj.source_data_dir,sprintf('%s.%dFiles.sqw',fb,obj.n_files_to_use_));

            %
            if obj.generate_nxspe_files
                [filelist,smpl_data_size] = obj.generate_source_test_files();
                obj.sample_data_size_ = smpl_data_size;

                obj.test_source_files_list_ = filelist;
                if obj.delete_generated_nxspe_files && ~obj.replicate_mode
                    % delete generated files after the test completed.
                    obj.add_to_files_cleanList(filelist);
                end
            else % use existing nxspe files and default sample data size
                obj.test_source_files_list_ = obj.generate_source_file_names();
                smpl_data_size = obj.sample_data_size_;
            end
            %

            obj.data_size_ = obj.n_files_to_use_*smpl_data_size*(4*9)/ ... %numWords*word_size = bytes
                (1024*1024*1024); %Convert to GB
        end
        %
        function comb_meth_name = combine_method_name(obj,varargin)
            % method returns name constructed from parameters of a tmp-files
            % combine method used during sqw file generation.
            % Inputs:
            % Read hpc config and constructs method name from this config
            % Optional:
            % addinfo  -- if provided, some additional string, to be
            %             appended to the combine name, generated from hpc
            %             settings
            %
            comb_meth_name = combine_method_name_(obj,varargin{:});
        end
        %--------------------------------------------------------------------------
        function filelist = generate_source_file_names(obj,file_name_form)
            n_files = obj.n_files_to_use;

            if obj.replicate_mode
                filelist = arrayfun(@(i)obj.source_template_file_,1:n_files,'UniformOutput',false);
            else
                if nargin<2
                    file_name_form = [obj.template_name_form_,'.nxspe'];
                end
                filelist = cell(n_files,1);            
                for i=1:n_files
                    filelist{i} = sprintf(file_name_form,i);
                end
            end
        end
        function [filelist,smpl_data_size] = generate_source_test_files(obj,varargin)
            % create source files, used for generation of sqw files or
            % directly build sqw file
            %
            [filelist,smpl_data_size] = generate_source_test_files_(obj,varargin{:});
        end
        function delete_tmp_files(obj)
            % delete temporary source files crated during gen_sqw phase
            delete_tmp_files_(obj);
        end
        %------------------------------------------------------------------
        function perf_res= workflow_performance(obj,varargin)
            % test performance (time spent on processing) class-defined
            % number of files using number of workers provided as input
            %
            % Usage:
            % tob.combine_performance_test([n_workers],[tests_to_run])
            % where n_workers, if present, specify the number of parallel
            % workers to run the test routines with.
            %
            % n_workers>1 sets up parallel file combining.
            % if n_workers==0 or absent the class does not change the
            % number of workers defined by current Horace configuration.
            clob_par_config = set_temporary_config_options(parallel_config, 'working_directory', pwd);

            if nargin <= 2
                n_workers = 0;
            else
                n_workers = varargin{1};
            end
            [clob_wk,~,nwk] = check_and_set_workers_(obj,n_workers);
            if nargin >= 3 && ~isempty(varargin{2})
                test_names_to_run = varargin{2};
                tests_to_run  = ismember(obj.tests_available,test_names_to_run);
            else
                tests_to_run = true(1,numel(obj.tests_available));
            end
            if nargin>3
                field_names_map = varargin{3};
                if numel(test_field_names) ~= sum(tests_to_run)
                    error('HORACE:performance_tests:invalid_argument',...
                        'number of test field names differs from the numner of tests to run')
                end
            else
                obj.build_default_test_names(nwk);
                field_names_map = obj.default_test_names;
            end
            %psi=round(psi);
            % define location of the sqw file to be the same as working
            % directory
            fp = fileparts(obj.sqw_file);
            if isempty(fp)
                targ_file = fullfile(obj.working_dir,obj.sqw_file);
                obj.sqw_file = targ_file;
            end

            % define location of the sqw file to be the same as working
            % directory
            fp = fileparts(obj.sqw_file);
            if isempty(fp)
                targ_file = fullfile(obj.working_dir,obj.sqw_file);
                obj.sqw_file = targ_file;
            end

            if obj.delete_resulting_sqw_file
                obj.add_to_files_cleanList(obj.sqw_file)
            end
            if tests_to_run(1) || tests_to_run(2)
                perf_res=obj.gen_sqw_task_performance(field_names_map,~(tests_to_run(2)&&tests_to_run(1)));
            end

            if tests_to_run(3)
                perf_res = obj.small_cut_task_performance(field_names_map);
            end

            % check nopix performance -- read and integrate the whole file from the HDD
            if tests_to_run(4)
                perf_res = obj.large_cut_nopix_task_performance(field_names_map);
            end

            if tests_to_run(5)
                perf_res = obj.large_cut_pix_fbased_task_perfornance(field_names_map);
            end

            % spurious check to ensure the cleanup object is not deleted
            % before the end of the test
            assertTrue(isa(clob_wk,'onCleanup'))
        end
        %
        function names = build_default_test_names(obj,nwk,varargin)
            % generate default test names to use as keys for performance
            % database structure

            % Inputs:
            % nwk      -- Number of parallel workers used to run the algorithm
            % addinfo  -- char array, describing other properties of the algorithm.

            % Returns:
            % map in the form key=test name, value -- cellarray of subtests
            % to run for the given test.
            %
            % this map is also set as the value of the property:
            % obj.default_test_names
            names = build_default_test_names_(obj,nwk,varargin{:});
        end
        %------------------------------------------------------------------
        function ds = get.data_size(obj)
            ds = obj.data_size_;
        end
        %
        function sds = get.sample_data_size(obj)
            sds  = obj.sample_data_size_;
        end
        function names_map = get.default_test_names(obj)
            names_map = obj.default_test_names_;
        end
    end
    methods(Access=private)
        function [clob,hc,nwkc] = check_and_set_workers_(~,n_workers)
            % function verifies and sets new number of MPI workers
            %
            % returns cleanup object which returns the number of temporary
            % workers to its initial value on destruction
            %  if input n_workers == 0, current number of parallel
            % workers remains unchanged
            %
            hc = hpc_config;
            bsp = hc.build_sqw_in_parallel;

            if n_workers <= 0 % keep existing number of workers unchanged
                % Because caller demands onCleanup object is returned, return null op
                clob = onCleanup(@()(0));

                if bsp
                    nwkc = num2str(hc.parallel_workers_number);
                else
                    nwkc = '0';
                end
                return;
            end

            nwkc = num2str(n_workers);
            clob = set_temporary_config_options(hpc_config, ...
                'build_sqw_in_parallel', true, ...
                'parallel_workers_number', n_workers);
        end  %function
    end %Methods
end
