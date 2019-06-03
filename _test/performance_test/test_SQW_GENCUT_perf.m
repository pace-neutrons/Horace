classdef test_SQW_GENCUT_perf < TestPerformance
    % Test checks performance achieved during sqw file generation and
    % different cuts, done over the test sqw files.
    %
    % The performance results (in second) are stored in a Matlab binary file
    % combining results for all hosts where the tests were run
    % The format of the file is as follows:
    % -host_name1->test_name1(nworkers)->test_time(sec)
    %           |->test_name2(nworkers)->test_time(sec)
    %           |->test_name3(nworkers)->test_time(sec)
    % -host_name2->test_name1(nworkers)->test_time(sec)
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
    % $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
    %
    properties(Dependent)
        %  Number of input files to use. Depending on this number the test
        %  would verify small, large or huge datasets
        n_files_to_use% = 10;
    end
    
    properties
        % directory, containing data file necessary for the tests
        source_data_dir
        % directory to keep temporary working files
        working_dir
        %
        % target file for gen_sqw command and source file for cut commands
        sqw_file = 'GenSQW_perfTest.sqw'
        %
        tests_availible = {'gen_sqw','small_cut',...
            'big_cut_nopix','big_cut_filebased'}
    end
    
    properties(Access=private)
        % list of source files to process
        test_source_files_list_
        %
        %  Number of input files to use. Depending on this number the test
        %  would verify small, large or huge datasets
        n_files_to_use_ = 10;
        % Template file name: the name of the file used as a template for
        % others. HACK. Nice version would generate test source files from
        % some scattering and instrument models.
        template_file_ = 'MER19566_22.0meV_one2one125.nxspe';
        % parameter file
        par_file = 'one2one_125.par'
        
    end
    methods
        %------------------------------------------------------------------
        function nf = get.n_files_to_use(obj)
            % number of test files, used in performance tests
            nf = obj.n_files_to_use_;
        end
        %------------------------------------------------------------------
        function obj = test_SQW_GENCUT_perf(varargin)
            % create test suite, generate source files and load existing
            % performance data.
            %
            % usage:
            % tester = test_SQW_GENCUT_perf(['previous test results file name'])
            %
            if nargin > 0
                argi = {'SQW_GENCUT_perf',varargin{1}};
            else
                argi = {'SQW_GENCUT_perf',...
                    TestPerformance.default_PerfTest_fname(mfilename('fullpath'))};
            end
            obj = obj@TestPerformance(argi{:});
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
        %-------------------------------------------------------------
        
        function set.n_files_to_use(obj,val)
            % change number of files to use and modify all related
            % internal properties which depends on this number
            %
            obj.n_files_to_use_ = floor(abs(val));
            if obj.n_files_to_use_ < 1
                obj.n_files_to_use_ = 1;
            end
            % change performance suite name as different number of input
            % files has different impact on performance
            perf_test = obj.build_test_suite_name(['nf',num2str(obj.n_files_to_use_)]);
            obj.perf_suite_name = perf_test;
            %
            pc = parallel_config;
            if pc.wkdir_is_default
                pc.working_directory = obj.source_data_dir;
            end
            
            %
            filelist = source_nxspe_files_generator(obj.n_files_to_use,...
                obj.source_data_dir,obj.working_dir,obj.template_file_);
            % delete generated files after the test completed.
            obj.add_to_files_cleanList(filelist);
            obj.test_source_files_list_ = filelist;
            fb = 'GenSQW_perfTest';
            obj.sqw_file = sprintf('%s_%dFiles.sqw',fb,obj.n_files_to_use_);
        end
        function method = combine_method(obj)
            % method returns name and parameters of a combine method used
            % during sqw file generation.
            hpc = hpc_config;
            method = hpc.combine_sqw_using;
            if strcmp(method,'mex_code')
                trm = hpc.mex_combine_thread_mode;
                method = sprintf('%s_MODE%d',method,trm);
            elseif strcmp(method,'mpi_code')
                pwn = hpc.parallel_workers_number;
                method = sprintf('%s_nwk%d',method,pwn);
            else
                method = sprintf('%s',method);
            end
            
        end
        %--------------------------------------------------------------------------
        function perf_val=combine_performance_test(obj,varargin)
            % this method tests tmp file combine operations only. It can be
            % deployed after test_gensqw_performance method has been run
            % with hor_config class delete_tmp option set to false. In this
            % case tmp files created by gen_sqw method are kept and this
            % method may test combine operations only.
            %
            % Usage:
            % tob.combine_performance_test([n_workers])
            % where n_workers, if present, specify the number of parallel
            % workers to run the test routines with.
            %
            % As this test method violates unit test agreement, demanding
            % test method independence on each other, it does not start
            % from the name test to avoid running it by automated test
            % suites.
            if nargin == 1
                n_workers = 0;
            else
                n_workers = varargin{1};
            end
            [clob_wk,hpc] = check_and_set_workers_(obj,n_workers);
            
            
            function fn = replace_fext(fp,fn)
                [~,fn] = fileparts(fn);
                fn = fullfile(fp,[fn,'.tmp']);
            end

            wk_dir = obj.working_dir;
            spe_files = obj.test_source_files_list_;
            tmp_files = cellfun(@(fn)(replace_fext(wk_dir,fn)),spe_files,'UniformOutput',false);
            
            % check all tmp files were generated
            f_exist = cellfun(@(fn)(exist(fn,'file')==2),tmp_files,'UniformOutput',true);
            if ~all(f_exist)
                warning('Some tmp files necessary to run the test do not exist. Generating these files which will take some time');
                % set up the exactly the same parameters as defined below
                % in test_gensqw_performance method.
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
                gen_sqw (spe_files,'','dummy_sqw', efix, emode, ...
                    alatt, angdeg,u, v, psi, omega, dpsi, gl, gs,...
                    'replicate','tmp_only');
            end
            
            combine_method = obj.combine_method();
            
            obj.add_to_files_cleanList(obj.sqw_file)
            ts = tic();
            write_nsqw_to_sqw(tmp_files,obj.sqw_file);
            %
            perf_val=obj.assertPerformance(ts,...
                ['combine_tmp_using_',combine_method],...
                'performance of the tmp-files combine procedure');
            
            % spurious check to ensure the cleanup object is not deleted
            % before the end of the test
            assertTrue(isa(clob_wk,'onCleanup'))
            
            obj.delete_files(tmp_files);
            
        end
        %------------------------------------------------------------------
        function perf_res= test_gensqw_performance(obj,varargin)
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
            if nargin == 3 && ~isempty(varargin{2})
                test_names_to_run = varargin{2};
                tests_to_run  = ismember(obj.tests_availible,test_names_to_run);
            else
                tests_to_run = true(1,numel(obj.tests_availible));
            end
            
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
            comb_metnod = obj.combine_method();
            
            obj.add_to_files_cleanList(obj.sqw_file)
            if tests_to_run(1)
                ts = tic();
                gen_sqw (obj.test_source_files_list_,'',obj.sqw_file, efix, emode, alatt, angdeg,u, v, psi, omega, dpsi, gl, gs,'replicate');
                
                perf_res=obj.assertPerformance(ts,sprintf('gen_sqw_nwk%s_comb_%s',nwk,comb_metnod),...
                    'whole sqw file generation');
            end
            
            if tests_to_run(2)
                % test small 1 dimensional cuts, non-axis aligned
                ts = tic();
                proj1 = struct('u',[1,0,0],'v',[0,1,1]);
                sqw1 = cut_sqw(obj.sqw_file,proj1,0.01,[-0.1,0.1],[-0.1,0.1],[-5,5]);
                obj.assertPerformance(ts,['cutH1D_Small_nwk',nwk,'_comb_',comb_metnod],...
                    'small memory based 1D cut in non-axis aligned direction 1');
                
                ts = tic();
                sqw1 = cut_sqw(obj.sqw_file,proj1,[-0.1,0.1],0.01,[-0.1,0.1],[-5,5]);
                obj.assertPerformance(ts,['cutK1D_Small_nwk',nwk,'_comb_',comb_metnod],...
                    'small memory based 1D cut in non-axis aligned direction 2');
                
                ts = tic();
                sqw1 = cut_sqw(obj.sqw_file,proj1,[-0.1,0.1],[-0.1,0.1],0.01,[-5,5]);
                obj.assertPerformance(ts,['cutL1D_Small_nwk',nwk,'_comb_',comb_metnod],...
                    'small memory based 1D cut in non-axis aligned direction 3');
                
                ts = tic();
                sqw1 = cut_sqw(obj.sqw_file,proj1,[-0.1,0.1],[-0.1,0.1],[-0.1,0.1],0.2);
                perf_res=obj.assertPerformance(ts,['cutE_Small_nwk',nwk,'_comb_',comb_metnod],...
                    'small memory based 1D cut along energy direction (q are not axis aligned)');
            end
            % check nopix performance -- read and integrate the whole file from the HDD
            hs = head_sqw(obj.sqw_file);
            urng = hs.urange';
            if tests_to_run(3)
                ts = tic();
                proj1 = struct('u',[1,0,0],'v',[0,1,1]);
                sqw1=cut_sqw(obj.sqw_file,proj1,0.01,urng(2,:),urng(3,:),urng(4,:),'-nopix');
                obj.assertPerformance(ts,['cutH1D_AllInt_nopix_nwk',nwk],...
                    'large 1D cut direction 1 with whole dataset integration along 3 other directions. -nopix mode');
                
                ts = tic();
                sqw1=cut_sqw(obj.sqw_file,proj1,urng(1,:),0.01,urng(3,:),urng(4,:),'-nopix');
                obj.assertPerformance(ts,['cutK1D_AllInt_nopix_nwk',nwk],...
                    'large 1D cut direction 2 with whole dataset integration along 3 other directions. -nopix mode');
                
                ts = tic();
                sqw1=cut_sqw(obj.sqw_file,proj1,urng(1,:),urng(2,:),0.01,urng(4,:),'-nopix');
                obj.assertPerformance(ts,['cutL1D_AllInt_nopix_nwk',nwk],...
                    'large 1D cut direction 3 with whole dataset integration along 3 other directions. -nopix mode');
                
                ts = tic();
                sqw1=cut_sqw(obj.sqw_file,proj1,urng(1,:),urng(2,:),urng(3,:),0.2,'-nopix');
                
                perf_res=obj.assertPerformance(ts,['cutE_AllInt_nopix_nwk',nwk],...
                    'large 1D cut along energy direction with whole dataset integration along 3 other directions. -nopix mode');
            end
            
            
            if tests_to_run(4)
                % test large 1 dimensional cuts, non-axis aligned, with whole
                % integration. for big input sqw files this should go to
                % file-based cuts
                fl2del = {'cutH1D_AllInt.sqw','cutK1D_AllInt.sqw',...
                    'cutL1D_AllInt.sqw','cutE_AllInt.sqw'};
                clob1 = onCleanup(@()obj.delete_files(fl2del));
                
                ts = tic();
                proj1 = struct('u',[1,0,0],'v',[0,1,1]);
                cut_sqw(obj.sqw_file,proj1,0.01,urng(2,:),urng(3,:),urng(4,:),'cutH1D_AllInt.sqw');
                obj.assertPerformance(ts,['cutH1D_AllInt_filebased_nwk',nwk],...
                    'large file-based 1D cut. Direction 1; Whole dataset integration along 3 other directions');
                
                ts = tic();
                cut_sqw(obj.sqw_file,proj1,urng(1,:),0.01,urng(3,:),urng(4,:),'cutK1D_AllInt.sqw');
                obj.assertPerformance(ts,['cutK1D_AllInt_filebased_nwk',nwk],...
                    'large file-based 1D cut. Direction 2; Whole dataset integration along 3 other directions');
                
                ts = tic();
                cut_sqw(obj.sqw_file,proj1,urng(1,:),urng(2,:),0.01,urng(4,:),'cutL1D_AllInt.sqw');
                obj.assertPerformance(ts,['cutL1D_AllInt_filebased_nwk',nwk],...
                    'large file-based 1D cut. Direction 3; Whole dataset integration along 3 other directions');
                
                ts = tic();
                cut_sqw(obj.sqw_file,proj1,urng(1,:),urng(2,:),urng(3,:),0.2,'cutE_AllInt.sqw');
                perf_res=obj.assertPerformance(ts,['cutE_AllInt_filebased_nwk',nwk],...
                    'large file-based 1D cut. Energy direction; Whole dataset integration along 3 other directions');
            end
            
            % spurious check to ensure the cleanup object is not deleted
            % before the end of the test
            assertTrue(isa(clob_wk,'onCleanup'))
        end
    end
    methods(Access=private)
        function [clob,hc,nwkc] = check_and_set_workers_(obj,n_workers)
            % function verifies and sets new number of MPI workers
            %
            % returns cleanup object which returns the number of temporary
            % workers to its initial value on destruction
            %  if input n_workers == 0, current number of parallel
            % workers remains unchanged
            %
            hc = hpc_config;
            if n_workers == 0 % keep existing number of workers unchanged
                clob = onCleanup(@()(0));
                nwkc = num2str(hc.parallel_workers_number);
                return;
            else
                nwkc = num2str(n_workers);
            end
            as = hc.build_sqw_in_parallel;
            an = hc.parallel_workers_number;
            if as && an > 1
                clob = onCleanup(@()set(hc,'build_sqw_in_parallel',as,'parallel_workers_number',an));
            else
                clob = onCleanup(@()(an));
            end
            if (n_workers>0 )
                hc.build_sqw_in_parallel = true;
                hc.parallel_workers_number = n_workers;
            end
            
        end
    end
end
