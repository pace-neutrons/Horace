classdef test_cut_parameters < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        out_dir = tmp_dir();
        root_dir = fileparts(mfilename('fullpath'));
        sample_files
    end
    
    methods

        function obj = test_cut_parameters(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_cut_parameters';
            end
            obj = obj@TestCase(name);
            det_file = fullfile(obj.root_dir,'96dets.par');
            params = {1:10,det_file,'',11,1,[2.8,2.8,2.8],[90,90,90],...
                [1,0,0],[0,1,0],10, 0, 0, 0, 0};
            sqw_4d_samp = fake_sqw(params{:},[5,5,5,5]);
            sqw_4d_samp  = sqw_4d_samp{1};
            obj.sample_files{1} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),[],[-1,1],[-1,1],[0,10]);
            obj.sample_files{2} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),[],[],[-1,1],[0,10]);
            obj.sample_files{3} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),[],[],[],[0,10]);
            obj.sample_files{4} = sqw_4d_samp;
        end
        
        function test_cut_param_all_param_given_explicitly(obj)
            %
            skipTest('This test is incompleted part of the ticket #716')
            sqw_samp = obj.sample_files{1};
            sqw_test = cut_sqw_tester(sqw_samp);
            %sqw_test = sqw(sqw_samp);
            [proj, pbin, opt]=sqw_test.cut_inputs_tester(true,1,...
                struct('u',[1,0,0],'v',[0,1,0]),...
                [-0.1,0.01,0.1],[-0.2,0.02,0.2],[-0.3,0.03,0.3],[0,1,10]);
            
        end
        
    end
end
