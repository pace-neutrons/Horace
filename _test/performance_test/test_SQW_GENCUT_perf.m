classdef test_SQW_GENCUT_perf < TestCaseWithSave
    % Test checks performance achieved during sqw file generation and
    % different cuts, done over the test sqw files.
    %
    %
    properties(Dependent)
        %  Number of input files to use. Depending on this number the test
        %  would verify small, large or huge datasets
        n_files_to_use% = 10;
        % time to run the test which should not be substantially increase
        % on a given machine. The first time one runs the test on the
        % machine, it is ignored
        time_to_run = [];
        % performance suite name consists of the pc name and the number of
        % input files to run
        perf_test_name;
        % performance data to compare against or store current results
        perf_data
    end
    
    properties
        % directory, containing data file necessary for the tests
        source_data_dir
        % directory to keep temporary working files
        working_dir
        %
        % target file for gen_sqw command and source file for cut commands
        sqw_file = 'GenSQW_perfTest.sqw'
    end
    
    properties(Access=private)
        % list of source files to process
        test_source_files_list_
        %
        % the mat file containing the performance data for the tests run on
        % different machines. The file is located in the test folder so should
        % be write-enabled on unix when the test is run for the first time.
        %
        perf_test_res_file_ = 'SQW_GENCUT_Perf.mat'
        % performance test suite name to run/verify
        perf_suite_name_;
        % performance data to compare against or store current results
        perf_data_;
        % performance suite name consists of the pc name and the number of
        % input files to run
        perf_test_name_ ='';
        %  Number of input files to use. Depending on this number the test
        %  would verify small, large or huge datasets
        n_files_to_use_ = 10;
        % Template file name: the name of the file used as a template for
        % others. HACK. Nice version would generate test source files from
        % some scattering and instrument models.
        template_file_ = 'MER19566_22.0meV_one2one125.nxspe';
        % parameter file
        par_file = 'one2one_125.par'
        
        % time to run the test which should not be substantially increase
        % on a given machine. The first time one runs the test on the
        % machine, it is ignored
        time_to_run_ = [];
        
    end
    methods
        function obj = test_SQW_GENCUT_perf(varargin)
            % create test suite, generate source files and load existing
            % perfomance data.
            %
            obj = obj@TestCaseWithSave(varargin{:});
            obj.source_data_dir = pwd();
            % locate the test data folder
            stat = mkdir('test_SQWGEN_performance_rw_test');
            if stat == 1
                rmdir('test_SQWGEN_performance_rw_test','s');
                obj.working_dir = obj.source_data_dir;
            else
                obj.working_dir = tmpdir;
                
            end
            obj.n_files_to_use = obj.n_files_to_use_;
            obj.add_to_files_cleanList(obj.sqw_file);
            %
            tests_name = obj.perf_test_name_;
            if exist(obj.perf_test_res_file_,'file')==2
                ld = load(obj.perf_test_res_file_);
                obj.perf_data_ = ld.suite_data;
            else
                obj.perf_data_ = struct(tests_name,[]);
            end
        end
        function save_or_test_performance(obj,start_time,test_method_name)
            % save performance data if the previous version for current pc
            % does not exist or test performance against previously stored
            % performance data
            %
            % start_time -- time of the test run start measured by tic
            %               function
            
            run_time= toc(start_time);
            suite_data = obj.perf_data_;
            test_data = suite_data.(obj.perf_test_name);
            if isempty(test_data)
                test_data = struct(test_method_name,run_time);
                fprintf('*** Method %s: Run time: %3.1f min;',...
                    test_method_name,run_time/60);
                
            else
                if isfield(test_data,test_method_name)
                    old_time = test_data.(test_method_name);
                    fprintf(...
                        ['*** Method %s: Run time: %3.1f min; old time:',...
                        ' %3.1f min: run is %3.1f times faster'],...
                        test_method_name,run_time/60,old_time/60,...
                        (old_time-run_time)/old_time)
                    %assertEqualToTol(run_time,old_time,'relTol',0.1);
                end
                test_data.(test_method_name) = run_time;
            end
            obj.time_to_run_ = run_time;
            suite_data.(obj.perf_test_name) = test_data;
            save(obj.perf_test_res_file_,'suite_data')
            obj.perf_data_ = suite_data;
            
        end
        %-------------------------------------------------------------
        function tr = get.time_to_run(obj)
            tr = obj.time_to_run_;
        end
        function nf = get.n_files_to_use(obj)
            nf = obj.n_files_to_use_;
        end
        function pfn = get.perf_test_name(obj)
            pfn = obj.perf_test_name_;
        end
        function pfd = get.perf_data(obj)
            pfd = obj.perf_data_;
        end
        
        
        function set.n_files_to_use(obj,val)
            % change number of files to use and modify all related
            % internal properties which depends on this number
            %
            obj.n_files_to_use_ = floor(abs(val));
            if obj.n_files_to_use_ < 1
                obj.n_files_to_use_ = 1;
            end(
            obj.perf_test_name_ = [getComputerName(),'_nf',num2str(obj.n_files_to_use_)];
            filelist = source_nxspe_files_generator(obj.n_files_to_use,...
                obj.source_data_dir,obj.working_dir,obj.template_file_);
            % delete generated files after the test completed.
            obj.add_to_files_cleanList(filelist);
            obj.test_source_files_list_ = filelist;
            [~,fb] = fileparts(obj.sqw_file);
            obj.sqw_file = sprintf('%s_%dFiles.sqw',fb,obj.n_files_to_use_);
            
        end
        
        %------------------------------------------------------------------
        function test_gensqw_performance(obj,n_workers)
            % test performance (time spent on processing) class-defined
            % number of files using number of workers provided as input
            %
            if ~exist('n_workers','var')
                n_workers = 1;
            end
            hc = hor_config;
            
            clobset = onCleanup(@()set(hc,''))
            
            nwk = num2str(n_workers);
            efix= 22.8;%incident energy in meV
            
            emode=1;%direct geometry
            alatt=10.7488*[1 1 1];%lattice parameters [a,b,c]
            angdeg=[90,90,90];%lattice angles [alpha,beta,gamma]
            u=[1,1,0];%u=// to incident beam
            v=[0,0,1];%v= perpendicular to the incident beam, pointing towards the large angle detectors on Merlin in the horizontal plane
            omega=0;
            dpsi=-1.8464+(0.9246);
            gl=-3.1871+(-0.1634);
            gs=-1.7047+(0.0028);
            
            nfiles=numel(obj.test_source_files_list_);
            psi= 0.5*(1:nfiles);
            %psi=round(psi);
            ts = tic();
            
            gen_sqw (obj.test_source_files_list_,obj.par_file,obj.sqw_file, efix, emode, alatt, angdeg,u, v, psi, omega, dpsi, gl, gs,'replicate');
            
            obj.save_or_test_performance(ts,['gen_sqw_nWorkers',nwk]);
            
            % test small 1 dimensional cuts, non-axis aligned
            ts = tic();
            proj1 = struct('u',[1,0,0],'v',[0,1,1]);
            sqw1 = cut_sqw(obj.sqw_file,proj1,0.01,[-0.1,0.1],[-0.1,0.1],[-5,5]);
            obj.save_or_test_performance(ts,['cutH1D_Small_nw',nwk]);
            
            ts = tic();
            sqw1 = cut_sqw(obj.sqw_file,proj1,[-0.1,0.1],0.01,[-0.1,0.1],[-5,5]);
            obj.save_or_test_performance(ts,['cutK1D__Small_nw',nwk]);
            
            ts = tic();
            sqw1 = cut_sqw(obj.sqw_file,proj1,[-0.1,0.1],[-0.1,0.1],0.01,[-5,5]);
            obj.save_or_test_performance(ts,['cutL1D_Small_nw',nwk]);
            
            ts = tic();
            sqw1 = cut_sqw(obj.sqw_file,proj1,[-0.1,0.1],[-0.1,0.1],[-0.1,0.1],0.2);
            obj.save_or_test_performance(ts,['cutE__Small_nw',nwk]);
            
            % check nopix performance -- read whole file from the HDD
            ts = tic();
            proj1 = struct('u',[1,0,0],'v',[0,1,1]);
            sqw1=cut_sqw(obj.sqw_file,proj1,0.01,[],[],[],'-nopix');
            obj.save_or_test_performance(ts,['cutH1D_AllInt_fbnw',nwk]);
            
            ts = tic();
            sqw1=cut_sqw(obj.sqw_file,proj1,[],0.01,[],[],'-nopix');
            obj.save_or_test_performance(ts,['cutK1D_AllInt_npnw',nwk]);
            
            ts = tic();
            sqw1=cut_sqw(obj.sqw_file,proj1,[],[],0.01,[],'-nopix');
            obj.save_or_test_performance(ts,['cutL1D_AllInt_npnw',nwk]);
            
            ts = tic();
            sqw1=cut_sqw(obj.sqw_file,proj1,[],[],[],0.2,'-nopix');
            obj.save_or_test_performance(ts,['cutE_AllInt_npnw',nwk]);
            
            
            % test large 1 dimensional cuts, non-axis aligned, with whole
            % integration. for big input sqw files this should go to
            % file-based cuts
            fl2del = {'cutH1D_AllInt.sqw','cutK1D_AllInt.sqw',...
                'cutL1D_AllInt.sqw','cutE_AllInt.sqw'};
            clob = onCleanup(@()rm_files(obj,fl2del{:}));
            
            ts = tic();
            proj1 = struct('u',[1,0,0],'v',[0,1,1]);
            cut_sqw(obj.sqw_file,proj1,0.01,[],[],[],'cutH1D_AllInt.sqw');
            obj.save_or_test_performance(ts,['cutH1D_AllInt_fbnw',nwk]);
            
            ts = tic();
            cut_sqw(obj.sqw_file,proj1,[],0.01,[],[],'cutK1D_AllInt.sqw');
            obj.save_or_test_performance(ts,['cutK1D_AllInt_fbnw',nwk]);
            
            ts = tic();
            cut_sqw(obj.sqw_file,proj1,[],[],0.01,[],'cutL1D_AllInt.sqw');
            obj.save_or_test_performance(ts,['cutL1D_AllInt_fbnw',nwk]);
            
            ts = tic();
            cut_sqw(obj.sqw_file,proj1,[],[],[],0.2,'cutE_AllInt.sqw');
            obj.save_or_test_performance(ts,['cutE_AllInt_fbnw',nwk]);
            
        end
    end
end
