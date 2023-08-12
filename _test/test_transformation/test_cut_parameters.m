classdef test_cut_parameters < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir = tmp_dir();
        det_dir = fileparts(fileparts(mfilename('fullpath')));
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
            det_file = fullfile(obj.det_dir,'common_data','96dets.par');
            params = {1:10,det_file,'',11,1,[2.8,2.8,2.8],[90,90,90],...
                [1,0,0],[0,1,0],10, 0, 0, 0, 0};
            sqw_4d_samp = dummy_sqw(params{:},[10,20,40,80], ...
                [0 ,-0.5,-0.1,  0; ...
                1.5,   0, 0.1, 10]);
            sqw_4d_samp  = sqw_4d_samp{1};
            obj.sample_files{1} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),...
                [0,0.1,1],[-1,0],[-0.1,0.1],[0,10]);
            obj.sample_files{2} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),...
                [0,0.1,1],[-1,0],[-0.1,0.01,0.1],[0,10]);
            obj.sample_files{3} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),...
                [-1,1],[-1,0.1,0],[-0.1,0.01,0.1],[0,10]);
            obj.sample_files{4} = sqw_4d_samp;
        end
        %==================================================================
        function test_default_spher_from_ortho(obj)
            sqw_samp = obj.sample_files{4};
            clOb = set_temporary_warning('off','HORACE:targ_range');

            img_block = sqw_samp.data;
            targ_proj = spher_proj();
            targ_range = img_block.targ_range(targ_proj);

            assertElementsAlmostEqual(targ_range(:,1)',[0,sqrt(1.5^2+0.5^2)], ...
                'absolute',1.e-2)
            assertEqual(targ_range(:,2)',[0,90])
            % exact value should be -180, but primitive search stopped
            % before that. May be search should be improved in a future to give
            % proper accuracy.
            assertElementsAlmostEqual(targ_range(:,3)',[-179.9821,180], ...
                'absolute',1.e-4)
            assertEqual(targ_range(:,4)',[0,10])

        end
        %------------------------------------------------------------------
        function test_transf_range_ortho_ortho_2D_Q(~)
            data_range = ...
                [-5, 0, 0,-5;
                5, 5,10,20];
            bin_range = [50,50,1,1];

            ax = line_axes('img_range',data_range,'nbins_all_dims',bin_range);
            proj = line_proj('alatt',1,'angdeg',90);

            dnd_obj = DnDBase.dnd(ax,proj);

            % the resulting range is divided by the length of the
            % projection vector, so we make it unit vector to avoid
            % confusion
            targ_proj = line_proj('u',[1,-1,0]/sqrt(2),'v',[1,1,0]/sqrt(2), ...
                'alatt',1,'angdeg',90);

            range = dnd_obj.targ_range(targ_proj);
            assertElementsAlmostEqual(range, ...
                [-5*sqrt(2),-5/sqrt(2),  0,   -5;...
                5/sqrt(2)  , 5*sqrt(2), 10, 20.0],...
                'absolute',5e-5)
        end

        function test_transf_range_spher_ortho_2D_Q(~)
            data_range = ...
                [0,          0,    0,   -5;...
                12.2474, 180.0, 90.0, 20.0];

            bin_range = [50,50,1,1];

            ax = spher_axes('img_range',data_range, ...
                'nbins_all_dims',bin_range);
            proj = spher_proj();

            dnd_obj = DnDBase.dnd(ax,proj);

            targ_proj = line_proj('alatt',2*pi,'angdeg',90);

            range = dnd_obj.targ_range(targ_proj);
            assertElementsAlmostEqual(range, ...
                [-12.2474,       0,       0, -5; ...
                12.2474 , 12.2474, 12.2474, 20],'absolute',5e-5)
        end

        function test_transf_range_ortho_spher_2D_Q(~)
            data_range = ...
                [-5,0, 0,-5;
                5  ,6,10,20];
            bin_range = [50,50,1,1];

            ax = line_axes('img_range',data_range,'nbins_all_dims',bin_range);
            proj = line_proj('alatt',1,'angdeg',90);

            dnd_obj = DnDBase.dnd(ax,proj);


            targ_proj = spher_proj('alatt',1,'angdeg',90);

            range = dnd_obj.targ_range(targ_proj);
            ref_range = [...
                0         0         0   -5.0000
                79.7247  180.0000   90.0000   20.0000];
            assertElementsAlmostEqual(range, ref_range,...
                'absolute',5e-5)
        end

        function test_transf_range_spher_ortho_2D_dE(~)
            data_range = ...
                [0,          0,    0,   -5;...
                79.7247, 180.0, 90.0, 20.0];

            bin_range = [1,50,1,50];

            ax = spher_axes('img_range',data_range,'nbins_all_dims', ...
                bin_range );
            proj = spher_proj();

            dnd_obj = DnDBase.dnd(ax,proj);

            targ_proj = line_proj('alatt',2*pi,'angdeg',90);

            range = dnd_obj.targ_range(targ_proj);
            ref_range = [...
                -79.7247        0         0   -5.0000;...
                79.7247   79.7247   79.7247   20.0000];
            assertElementsAlmostEqual(range, ref_range,...
                'absolute',5e-5)

        end

        function test_transf_range_ortho_spher_2D_dE(~)
            data_range = [-5,0,0,-5;5,5,10,20];
            bin_range = [1,50,1,50];

            ax = line_axes('img_range',data_range,'nbins_all_dims',bin_range);
            proj = line_proj('alatt',1,'angdeg',90);

            dnd_obj = DnDBase.dnd(ax,proj);


            targ_proj = spher_proj('alatt',1,'angdeg',90);

            range = dnd_obj.targ_range(targ_proj);
            ref_range = [...
                0         0         0         -5.0000;...
                76.9530  180.0000   90.0000   20.0000];
            assertElementsAlmostEqual(range, ref_range,...
                'absolute',5e-5)
        end
        %------------------------------------------------------------------
        function test_double_multicut_expanded3d(obj)
            sqw_samp = obj.sample_files{2};
            sqw_test = cut_sqw_tester(sqw_samp);

            [proj, pbin, opt]= cut_inputs_tester(sqw_test,true,...
                line_proj([1,0,0],[0,1,0]),...
                [-1,1],[-1,0.5,1,1],[-1,0.5,1,1],[-1,0.8,0,1]);
            op = line_proj([1,0,0],[0,1,0], ...
                'alatt',sqw_test.data.proj.alatt, ...
                'angdeg',sqw_test.data.proj.angdeg);
            assertEqual(proj,op);
            assertEqual(numel(pbin),3*25)

            pb1 = pbin{1};
            assertEqual(pb1,{[-1,1],[-1.5,-0.5],[-1.5,-0.5],[-1-0.5,-1+0.5]})
            pb2 = pbin{2};
            assertEqual(pb2,{[-1,1],[-1,0],[-1.5,-0.5],[-1-0.5,-1+0.5]})
            pb5 = pbin{5};
            assertEqual(pb5,{[-1,1],[0.5,1.5],[-1.5,-0.5],[-1-0.5,-1+0.5]})

            pb6 = pbin{6};
            assertEqual(pb6,{[-1,1],[-1.5,-0.5],[-1,0],[-1-0.5,-1+0.5]})

            pb25 = pbin{25};
            assertEqual(pb25,{[-1,1],[0.5,1.5],[0.5,1.5],[-1-0.5,-1+0.5]})

            pb75 = pbin{75};
            last_cent = -1+2*0.8;
            assertEqual(pb75,{[-1,1],[0.5,1.5],[0.5,1.5],[last_cent-0.5,last_cent+0.5]})

            assertTrue(opt.keep_pix);
            assertFalse(opt.parallel);
            assertTrue(isempty(opt.outfile));
        end

        function test_double_multicut_expanded2d(obj)
            sqw_samp = obj.sample_files{2};
            sqw_test = cut_sqw_tester(sqw_samp);

            [proj, pbin, opt]= cut_inputs_tester(sqw_test,true,...
                line_proj([1,0,0],[0,1,0]),...
                [-1,1],[-1,0.5,1,1],[-1,0.5,1,1],[]);
            op = line_proj([1,0,0],[0,1,0], ...
                'alatt',sqw_test.data.proj.alatt, ...
                'angdeg',sqw_test.data.proj.angdeg);
            assertEqual(proj,op);
            assertEqual(numel(pbin),25)

            pb1 = pbin{1};
            assertEqual(pb1,{[-1,1],[-1.5,-0.5],[-1.5,-0.5],[]})
            pb2 = pbin{2};
            assertEqual(pb2,{[-1,1],[-1,0],[-1.5,-0.5],[]})
            pb5 = pbin{5};
            assertEqual(pb5,{[-1,1],[0.5,1.5],[-1.5,-0.5],[]})

            pb6 = pbin{6};
            assertEqual(pb6,{[-1,1],[-1.5,-0.5],[-1,0],[]})

            pb25 = pbin{25};
            assertEqual(pb25,{[-1,1],[0.5,1.5],[0.5,1.5],[]})

            assertTrue(opt.keep_pix);
            assertFalse(opt.parallel);
            assertTrue(isempty(opt.outfile));
        end

        function test_single_multicut_expanded(obj)
            sqw_samp = obj.sample_files{2};
            sqw_test = cut_sqw_tester(sqw_samp);

            [proj, pbin, opt]= cut_inputs_tester(sqw_test,true,...
                line_proj([1,0,0],[0,1,0]),...
                [-1,1],[-1,0.5,1,1],[],[]);
            op = line_proj([1,0,0],[0,1,0], ...
                'alatt',sqw_test.data.proj.alatt, ...
                'angdeg',sqw_test.data.proj.angdeg);
            assertEqual(proj,op);
            assertEqual(numel(pbin),5)

            pb1 = pbin{1};
            assertEqual(pb1,{[-1,1],[-1.5,-0.5],[],[]})
            pb2 = pbin{2};
            assertEqual(pb2,{[-1,1],[-1,0],[],[]})
            pb5 = pbin{5};
            assertEqual(pb5,{[-1,1],[0.5,1.5],[],[]})
            assertTrue(opt.keep_pix);
            assertFalse(opt.parallel);
            assertTrue(isempty(opt.outfile));
        end

        function test_invalid_multicut_throws(obj)
            sqw_samp = obj.sample_files{2};
            sqw_test = cut_sqw_tester(sqw_samp);
            assertExceptionThrown(@()cut_inputs_tester(sqw_test,true,...
                line_proj([1,0,0],[0,1,0]),...
                [-1,1],[-1,0.5,-1,2],[],[]),'HORACE:cut:invalid_argument');

            assertExceptionThrown(@()cut_inputs_tester(sqw_test,true,...
                line_proj([1,0,0],[0,1,0]),...
                [-1,1],[-1,-0.5,1,2],[],[]),'HORACE:cut:invalid_argument');

            assertExceptionThrown(@()cut_inputs_tester(sqw_test,true,...
                line_proj([1,0,0],[0,1,0]),...
                [-1,1],[-1,0,1,2],[],[]),'HORACE:cut:invalid_argument');

            assertExceptionThrown(@()cut_inputs_tester(sqw_test,true,...
                line_proj([1,0,0],[0,1,0]),...
                [-1,1],[-1,0.5,1,0],[],[]),'HORACE:cut:invalid_argument');

            assertExceptionThrown(@()cut_inputs_tester(sqw_test,true,...
                line_proj([1,0,0],[0,1,0]),...
                [-1,1],[-1,0.5,1,-1],[],[]),'HORACE:cut:invalid_argument');

        end
        %------------------------------------------------------------------
        function test_cut_range_1D(obj)
            %
            sqw_samp = obj.sample_files{1};
            range = sqw_samp.data.axes.get_cut_range();
            sqw_res = cut(sqw_samp,range{:});

            assertEqualToTol(sqw_samp,sqw_res,'tol',[1.e-8,1.e-8]);
        end
        %
        function test_cut_param_2D_noproj_extracted_from_existing_cut(obj)
            %
            sqw_samp = obj.sample_files{2};
            sqw_test = cut_sqw_tester(sqw_samp);
            %sqw_test = sqw(sqw_samp);
            [proj, pbin, opt]=sqw_test.cut_inputs_tester(true,...
                [],0.01,'-nopix');
            assertTrue(iscell(pbin))
            assertEqual(numel(pbin),1)

            pbin = pbin{1};
            assertEqual(numel(pbin),4)
            assertElementsAlmostEqual(pbin{1},[-0.05,0.1,1.05])
            assertEqual(pbin{2},[-1,0])
            assertElementsAlmostEqual(pbin{3},[-0.105,0.01,0.105])
            assertEqual(pbin{4},[0,10])

            assertTrue(isa(proj,'line_proj'));
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
            assertTrue(iscell(pbin))
            assertEqual(numel(pbin),1)
            pbin = pbin{1};
            assertEqual(pbin{1},[])
            assertEqual(pbin{2},[])
            assertEqual(pbin{3},[])
            assertEqual(pbin{4},[])

            assertTrue(isa(proj,'aProjectionBase'));
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
            assertTrue(iscell(pbin))
            assertEqual(numel(pbin),1)
            pbin = pbin{1};
            assertEqual(pbin{1},[-0.1,0.01,0.1])
            assertEqual(pbin{2},[-0.2,0.02,0.2])
            assertEqual(pbin{3},[-0.3,0.03,0.3])
            assertEqual(pbin{4},[0,1,10])

            assertTrue(isa(proj,'aProjectionBase'));
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])

            assertTrue(opt.keep_pix);
            assertFalse(opt.parallel);
            assertTrue(isempty(opt.outfile));
        end
        %
        function test_cut_param_all_param_given_explicitly_1D(obj)
            %
            sqw_samp = obj.sample_files{1};
            sqw_test = cut_sqw_tester(sqw_samp);
            %sqw_test = sqw(sqw_samp);
            [proj, pbin, opt]=sqw_test.cut_inputs_tester(true,...
                struct('u',[1,0,0],'v',[0,1,0]),...
                [-0.1,0.01,0.1],[-0.2,0.02,0.2],[-0.3,0.03,0.3],[0,1,10]);
            assertTrue(iscell(pbin))
            assertEqual(numel(pbin),1)
            pbin = pbin{1};
            assertEqual(pbin{1},[-0.1,0.01,0.1])
            assertEqual(pbin{2},[-0.2,0.02,0.2])
            assertEqual(pbin{3},[-0.3,0.03,0.3])
            assertEqual(pbin{4},[0,1,10])

            assertTrue(isa(proj,'aProjectionBase'));
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])

            assertTrue(opt.keep_pix);
            assertFalse(opt.parallel);
            assertTrue(isempty(opt.outfile));
        end
        %
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
