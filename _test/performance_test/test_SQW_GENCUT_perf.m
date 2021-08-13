classdef test_SQW_GENCUT_perf < SQW_GENCUT_perf_tester
    % Test checks performance achieved during sqw file generation and
    % different cuts, done over the test sqw files using template file as
    % the source file
    %
    %
    % this test uses large real nxspe file specified as value
    % of the property template_file_. The file size is large then the whole
    % Horace codebase, so there are no point of keeping it in SVN. Currently
    % this file should be distributed manually or randomly chosen from the
    % files available to user In a future, such file should be auto-generated.
    %
    %
    
    properties(Access=private)
        % Template file name: the name of the file used as a template for
        % others.
        source_template_file_ = 'MER19566_22.0meV_one2one125.nxspe';
    end
    methods
        
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
            %
            obj = obj@SQW_GENCUT_perf_tester(argi{:});
            %
            % the byte-size of the sample file, used to estimate the
            % performance in GB/sec = n_detectors*nEnerty_transfer_Bins.
            % The value is defined by the size of the reference template file
            % template_file_
            obj.sample_data_size_ = 20262912;
        end
        function [filelist,smpl_data_size] = generate_source_test_files(obj,varargin)
            % create source files, used for generation
            %
            filelist = source_nxspe_files_generator_(obj);
            smpl_data_size = obj.sample_data_size_;
        end
        
    end %Methods
    methods(Access=protected)
        function  spe_filelist = source_nxspe_files_generator_(obj)
            % Generate test of source files to use in further tests
            %
            %Input: number of files to generate
            %Output: list of filenames to use in test
            %
            % This is simplified version which involes copying the source file.
            % more advanced version would generate appropriate
            %
            %Horace requires cell arrays telling it the names and locations of the spe files:
            n_files = obj.n_files_to_use_;
            data_dir = obj.source_data_dir;
            working_dir = obj.working_dir;
            
            spe_filelist=cell(1,n_files);
            %
            source_file = fullfile(data_dir,obj.source_template_file_);
            
            template_name_form = obj.template_name_form_;
            %
            for i=1:n_files
                fname =sprintf([template_name_form,'.nxspe'],i);
                spe_filelist{i} = fullfile(working_dir,fname);
                if ~(exist(spe_filelist{i},'file')==2)
                    copyfile(source_file,spe_filelist{i},'f');
                end
            end
        end
    end
    
end
