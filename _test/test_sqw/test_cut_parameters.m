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
            sqw_4d_samp = fake_sqw(params{:},[10,20,40,80],[0,-0.5,-0.1,0;1.5,0,0.1,10]);
            sqw_4d_samp  = sqw_4d_samp{1};
            obj.sample_files{1} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),[],[-1,0],[-0.1,0.1],[0,10]);
            obj.sample_files{2} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),[],[-1,0],[],[0,10]);
            obj.sample_files{3} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),[-1,1],[],[],[]);
            obj.sample_files{4} = sqw_4d_samp;
        end
        %
        function test_cut_range_1D(obj)
            
            sqw_samp = obj.sample_files{1};
            range = sqw_samp.data.get_cut_range();
            sqw_res = cut(sqw_samp,range{:});
            
            assertEqualToTol(sqw_samp,sqw_res,'tol',[1.e-8,1.e-8]);
        end
        %
        function test_cut_param_2D_noproj(obj)
            %
            sqw_samp = obj.sample_files{2};
            sqw_test = cut_sqw_tester(sqw_samp);
            %sqw_test = sqw(sqw_samp);
            [proj, pbin, opt]=sqw_test.cut_inputs_tester(true,...
                [],0.01,'-nopix');
            assertEqual(numel(pbin),4)
            assertEqual(pbin{1},[0;0.15;1.5])
            assertEqual(pbin{2},[-1;0])
            assertEqual(pbin{3},[-0.1;0.01;0.1])
            assertEqual(pbin{4},[0;10])
            
            assertTrue(isa(proj,'aProjection'));
            assertElementsAlmostEqual(proj.u,[1,0,0])
            assertElementsAlmostEqual(proj.v,[0,1,0])
            
            assertFalse(opt.keep_pix);
            assertFalse(opt.parallel);
            assertTrue(isempty(opt.outfile));
        end
        %
        function test_cut_param_all_implicit_2D(obj)
            %
            
            sqw_samp = obj.sample_files{2};
            sqw_test = cut_sqw_tester(sqw_samp);
            %sqw_test = sqw(sqw_samp);
            [proj, pbin, opt]=sqw_test.cut_inputs_tester(true,...
                struct('u',[1,0,0],'v',[0,1,0]),...
                [],[],[],[],'-nopix');
            assertEqual(pbin{1},[])
            assertEqual(pbin{2},[])
            assertEqual(pbin{3},[])
            assertEqual(pbin{4},[])
            
            assertTrue(isa(proj,'aProjection'));
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            
            assertFalse(opt.keep_pix);
            assertFalse(opt.parallel);
            assertTrue(isempty(opt.outfile));
        end
        %
        function test_cut_param_all_param_given_explicitly_3D(obj)
            %
            sqw_samp = obj.sample_files{3};
            sqw_test = cut_sqw_tester(sqw_samp);
            %sqw_test = sqw(sqw_samp);
            [proj, pbin, opt]=sqw_test.cut_inputs_tester(true,...
                struct('u',[1,0,0],'v',[0,1,0]),...
                [-0.1,0.01,0.1],[-0.2,0.02,0.2],[-0.3,0.03,0.3],[0,1,10]);
            assertEqual(pbin{1},[-0.1,0.01,0.1])
            assertEqual(pbin{2},[-0.2,0.02,0.2])
            assertEqual(pbin{3},[-0.3,0.03,0.3])
            assertEqual(pbin{4},[0,1,10])
            
            assertTrue(isa(proj,'aProjection'));
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            
            assertTrue(opt.keep_pix);
            assertFalse(opt.parallel);
            assertTrue(isempty(opt.outfile));
        end
        
        
        function test_cut_param_all_param_given_explicitly_1D(obj)
            %
            sqw_samp = obj.sample_files{1};
            sqw_test = cut_sqw_tester(sqw_samp);
            %sqw_test = sqw(sqw_samp);
            [proj, pbin, opt]=sqw_test.cut_inputs_tester(true,...
                struct('u',[1,0,0],'v',[0,1,0]),...
                [-0.1,0.01,0.1],[-0.2,0.02,0.2],[-0.3,0.03,0.3],[0,1,10]);
            assertEqual(pbin{1},[-0.1,0.01,0.1])
            assertEqual(pbin{2},[-0.2,0.02,0.2])
            assertEqual(pbin{3},[-0.3,0.03,0.3])
            assertEqual(pbin{4},[0,1,10])
            
            assertTrue(isa(proj,'aProjection'));
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            
            assertTrue(opt.keep_pix);
            assertFalse(opt.parallel);
            assertTrue(isempty(opt.outfile));
        end
        
        function test_unrecognized_extra_par_throw(obj)
            %
            sqw_samp = obj.sample_files{1};
            sqw_test = cut_sqw_tester(sqw_samp);
            %sqw_test = sqw(sqw_samp);
            assertExceptionThrown(@()cut_inputs_tester(sqw_test,true,...
                struct('u',[1,0,0],'v',[0,1,0]),...
                [-0.1,0.01,0.1],[-0.2,0.02,0.2],[-0.3,0.03,0.3],[0,1,10],...
                100,200),...
                'HORACE:cut:invalid_argument');
        end
        
    end
end
