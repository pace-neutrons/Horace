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
    % HACK: currently the test uses large real nxspe file specified as value
    % of the property template_file_. The file size is large then the whole
    % Horace codebase, so there are no point of keeping it in SVN. Currently
    % this file should be distributed manually or randomly chosen from the
    % files available to user In a future, such file should be auto-generated.
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
        % if true, when number of test files changes, (n_files_to_use)
        % build directly sqw file, not
        build_test_sqw_file = false;
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
        % format of the filename used as test result
        template_name_form_ = 'MER_fake_run_N%03d';
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
            obj.tests_available_ = {'gen_sqw','small_cut',...
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
            % completed.
            obj.add_to_files_cleanList(obj.sqw_file);
        end
        
        %------------------------------------------------------------------
        % Interface defining existing perfornance tests
        %
        [perf,varargout]=gen_sqw_task_performance(obj,field_names_map)
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
            par_file = fullfile(horace_root,'_test','common_data',obj.par_file);
            
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
            [filelist,smpl_data_size] = obj.generate_source_test_files();
            obj.sample_data_size_ = smpl_data_size;
            %
            % delete generated files after the test completed.
            obj.add_to_files_cleanList(filelist);
            obj.test_source_files_list_ = filelist;
            
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
            pc = parallel_config;
            ds = pc.get_data_to_store();
            clob_par_config = onCleanup(@()set(pc,ds));
            pc.working_directory=pwd;
            
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
            
            obj.add_to_files_cleanList(obj.sqw_file)
            if tests_to_run(1)
                perf_res=obj.gen_sqw_task_performance(field_names_map);
            end
            
            if tests_to_run(2)
                perf_res = obj.small_cut_task_performance(field_names_map);
            end
            
            % check nopix performance -- read and integrate the whole file from the HDD
            if tests_to_run(3)
                perf_res = obj.large_cut_nopix_task_performance(field_names_map);
            end
            
            if tests_to_run(4)
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
            if n_workers == 0 % keep existing number of workers unchanged
                clob = onCleanup(@()(0));
                if bsp
                    nwkc = num2str(hc.parallel_workers_number);
                else
                    nwkc = '0';
                end
                return;
            else
                nwkc = num2str(n_workers);
            end
            
            an = hc.parallel_workers_number;
            if bsp && an > 1
                clob = onCleanup(@()set(hc,'build_sqw_in_parallel',bsp,'parallel_workers_number',an));
            else
                clob = onCleanup(@()(an));
            end
            if (n_workers>0 )
                hc.build_sqw_in_parallel = true;
                hc.parallel_workers_number = n_workers;
            end
        end  %function
    end %Methods
end
