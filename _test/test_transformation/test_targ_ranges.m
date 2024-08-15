classdef test_targ_ranges < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir = tmp_dir();
        det_dir = fileparts(fileparts(mfilename('fullpath')));
        sample_files
    end

    methods

        function obj = test_targ_ranges(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_targ_ranges';
            end
            obj = obj@TestCase(name);
            det_file = fullfile(obj.det_dir,'common_data','96dets.par');
            params = {1:10,det_file,'',11,1,[2.8,2.8,2.8],[90,90,90],...
                [1,0,0],[0,1,0],10, 0, 0, 0, 0};
            sqw_4d_samp = dummy_sqw(params{:},[10,20,40,80], ...
                [0 ,-0.5,-0.1,  0; ...
                1.5,   0, 0.1, 10]);
            sqw_4d_samp  = sqw_4d_samp{1};
            obj.sample_files{4} = sqw_4d_samp;
        end
        %==================================================================
        function test_default_cylinder_from_ortho(obj)
            sqw_samp = obj.sample_files{4};
            clOb = set_temporary_warning('off','HORACE:get_targ_range','HORACE:push_warning');

            img_block = sqw_samp.data;
            targ_proj = cylinder_proj('type','aad');
            warning('HORACE:push_warning','issue warning which pushes ')
            targ_range = img_block.get_targ_range(targ_proj);
            [~,wid] = lastwarn();
            assertEqual(wid,'HORACE:get_targ_range')

            assertElementsAlmostEqual(targ_range(:,1)',[0,0.5], ...
                'absolute',1.e-2)
            assertEqual(targ_range(:,2)',[0.,1.5],'absolute',1.e-4)
            % exact value should be -180, but primitive search stopped
            % before that. May be search should be improved in a future to give
            % proper accuracy.
            assertElementsAlmostEqual(targ_range(:,3)',[-179.9641,179.9641], ...
                'absolute',1.e-4)
            assertEqual(targ_range(:,4)',[0,10])
        end

        function test_default_sphere_from_ortho(obj)
            sqw_samp = obj.sample_files{4};
            clOb = set_temporary_warning('off','HORACE:get_targ_range','HORACE:push_warning');

            img_block = sqw_samp.data;
            targ_proj = sphere_proj('type','add');
            warning('HORACE:push_warning','issue warning which pushes ')
            targ_range = img_block.get_targ_range(targ_proj);
            [~,wid] = lastwarn();
            assertEqual(wid,'HORACE:get_targ_range')


            assertElementsAlmostEqual(targ_range(:,1)',[0,sqrt(1.5^2+0.5^2)], ...
                'absolute',1.e-2)
            assertEqual(targ_range(:,2)',[0.0120,90],'absolute',1.e-4)
            % exact value should be -180, but primitive search stopped
            % before that. May be search should be improved in a future to give
            % proper accuracy.
            assertElementsAlmostEqual(targ_range(:,3)',[-179.9641,179.9641], ...
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

            range = dnd_obj.get_targ_range(targ_proj);
            assertElementsAlmostEqual(range, ...
                [-5*sqrt(2),-5/sqrt(2),  0,   -5;...
                5/sqrt(2)  , 5*sqrt(2), 10, 20.0],...
                'absolute',5e-5)
        end

        function test_transf_range_sphere_ortho_2D_Q(~)
            data_range = ...
                [0,          0,    0,   -5;...
                12.2474, 180.0, 90.0, 20.0];

            bin_range = [50,50,1,1];

            ax = sphere_axes('img_range',data_range, ...
                'nbins_all_dims',bin_range);
            proj = sphere_proj('alatt',2*pi,'angdeg',90);

            dnd_obj = DnDBase.dnd(ax,proj);

            targ_proj = line_proj();

            range = dnd_obj.get_targ_range(targ_proj);
            assertElementsAlmostEqual(range,[ ...
                -12.2474,       0,       0, -5; ...
                12.2474 , 12.2474, 12.2474, 20],'absolute',3e-4)
        end

        function test_transf_range_ortho_sphere_2D_Q(~)
            data_range = ...
                [-5,0, 0,-5;
                5  ,6,10,20];
            bin_range = [50,50,1,1];

            ax = line_axes('img_range',data_range,'nbins_all_dims',bin_range);
            proj = line_proj('alatt',2*pi,'angdeg',90);

            dnd_obj = DnDBase.dnd(ax,proj);

            targ_proj = sphere_proj();

            range = dnd_obj.get_targ_range(targ_proj);
            ref_range = [...
                0.         0.        0.      -5.0000
                12.6886  180.0000   90.0000   20.0000];
            assertElementsAlmostEqual(range, ref_range,...
                'absolute',5e-5)
        end

        function test_transf_range_sphere_ortho_2D_dE(~)
            data_range = [...
                0 ,     0,    0,   -5;...
                10, 180.0, 90.0, 20.0];

            bin_range = [1,50,1,50];

            ax = sphere_axes('img_range',data_range,'nbins_all_dims', ...
                bin_range );
            proj = sphere_proj('alatt',2*pi,'angdeg',90);

            dnd_obj = DnDBase.dnd(ax,proj);

            targ_proj = line_proj();

            range = dnd_obj.get_targ_range(targ_proj);
            ref_range = [...
                -10.000    0.      0.     -5.0000;...
                10.0000    9.9999  9.9999 20.0000];
            assertElementsAlmostEqual(range, ref_range,...
                'absolute',2e-4)

        end

        function test_transf_range_cylinder_2D_dE(~)
            data_range = [-5,-5,-5,-5;5,5,10,20];
            bin_range = [1,50,1,50];

            ax = line_axes('img_range',data_range,'nbins_all_dims',bin_range);
            proj = line_proj('alatt',2*pi,'angdeg',90);

            dnd_obj = DnDBase.dnd(ax,proj);

            targ_proj = cylinder_proj([1,1,0],[1,-1,0],'offset',[1,0,0],'type','aad');

            range = dnd_obj.get_targ_range(targ_proj);
            ref_range = [...
                0       -7.7782  -180.0   -5.0000;...
                12.6689  6.3640   180.0   20.0000];
            assertElementsAlmostEqual(range, ref_range,...
                'absolute',1e-4)
        end

        function test_transf_range_ortho_sphere_2D_dE(~)
            data_range = [-5,0,0,-5;5,5,10,20];
            bin_range = [1,50,1,50];

            ax = line_axes('img_range',data_range,'nbins_all_dims',bin_range);
            proj = line_proj('alatt',1,'angdeg',90);

            dnd_obj = DnDBase.dnd(ax,proj);


            targ_proj = sphere_proj('alatt',2*pi,'angdeg',90);

            range = dnd_obj.get_targ_range(targ_proj);
            ref_range = [...
                0         0         0         -5.0000;...
                76.9530  180.0000   90.0000   20.0000];
            assertElementsAlmostEqual(range, ref_range,...
                'absolute',5e-5)
        end

        function test_transf_range_ortho_cylinder_inside_4D(~)
            data_range = [-1,-1,-1,-5;1,1,1,20];
            bin_range = [1,50,1,50];

            ax = line_axes('img_range',data_range,'nbins_all_dims',bin_range);
            proj = line_proj('alatt',2*pi,'angdeg',90);

            dnd_obj = DnDBase.dnd(ax,proj);


            targ_proj = cylinder_proj();

            range = dnd_obj.get_targ_range(targ_proj);
            ref_range = [...
                0       -1 -180. -5.0000;...
                sqrt(2)  1  180.  20.0000];
            assertElementsAlmostEqual(range, ref_range,...
                'absolute',1e-5)
        end

        function test_transf_range_ortho_sphere_inside_4D(~)
            data_range = [-1,-1,-1,-5;1,1,1,20];
            bin_range = [1,50,1,50];

            ax = line_axes('img_range',data_range,'nbins_all_dims',bin_range);
            proj = line_proj('alatt',2*pi,'angdeg',90);

            dnd_obj = DnDBase.dnd(ax,proj);

            targ_proj = sphere_proj();

            range = dnd_obj.get_targ_range(targ_proj);
            ref_range = [...
                0         0.     -180. -5.0000;...
                sqrt(3) 180.0000  180.  20.0000];
            assertElementsAlmostEqual(range, ref_range,...
                'absolute',1e-5)
        end
        %------------------------------------------------------------------
        function test_get_dE_binning_only(~)
            ax = line_axes('nbins_all_dims',[40,40,40,100],'img_range',[-2,-2,-2,0;2,2,2,10]);
            proj = line_proj('alatt',1,'angdeg',90);
            dnd_obj =  DnDBase.dnd(ax,proj);
            cp = cylinder_proj();

            requested = [false,false,false,true];
            img_range = dnd_obj.get_targ_range(cp,requested,'-binning');
            ref_range = {[],[],[],[0.05,0.1,9.95]};

            assertEqualToTol(img_range,ref_range);
        end

        function test_get_dE_range_only(~)
            ax = line_axes('nbins_all_dims',[40,40,40,100],'img_range',[-2,-2,-2,0;2,2,2,10]);
            proj = line_proj('alatt',1,'angdeg',90);
            dnd_obj =  DnDBase.dnd(ax,proj);
            cp = cylinder_proj();

            requested = [false,false,false,true];
            img_range = dnd_obj.get_targ_range(cp,requested);
            ref_range = [-inf,-inf,-inf,0;inf,inf,inf,10];

            assertElementsAlmostEqual(img_range,ref_range);
        end
    end
end
