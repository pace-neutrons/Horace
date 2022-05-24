classdef test_data_sqw_dnd < TestCaseWithSave
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir=tmp_dir();
        ref_sqw
        par_file = 'map_4to1_dec09.par'
    end

    methods
        function obj=test_data_sqw_dnd(varargin)
            if nargin<1
                name = 'test_data_sqw_dnd';
            else
                name = varargin{1};
            end
            % second parameter describes the source of the reference data
            % currently it is uses as input for assertEqualWithSave, but
            % when data_sqw_dnd_changes, these data should be used as input
            % to support loading the previous version
            obj = obj@TestCaseWithSave(name,'data_sqw_dnd_V1_ref_data.mat');

            root_dir = horace_root();
            data_dir = fullfile(root_dir,'_test','common_data');
            obj.par_file =  fullfile(data_dir,obj.par_file);
            ref_sqw = fake_sqw(-80:8:760, obj.par_file, '', 800,...
                1, [2,2.5,2], [95,110,90],...
                [1,0,0], [0,1,0], 5,...
                0, 0, 0, 0);
            obj.ref_sqw = ref_sqw{1};
            % does nothing unless called with -save key as input
            obj.save();
        end
        %
        function test_fresh_sqw_ranges_consistent(obj)
            %
            proj0 =  obj.ref_sqw.data.get_projection();
            pix_range = obj.ref_sqw.data.pix.pix_range;
            img_range = obj.ref_sqw.data.img_db_range;
            full_pix_range = expand_box(pix_range(1,:),pix_range(2,:));
            eval_img_range = proj0.transform_pix_to_img(full_pix_range);
            full_img_range = expand_box(img_range(1,:),img_range(2,:));

            assertElementsAlmostEqual(eval_img_range,full_img_range);

            full_img_range = expand_box(img_range(1,:),img_range(2,:));
            eval_pix_range = proj0.transform_img_to_pix(full_img_range);
            assertElementsAlmostEqual(eval_pix_range,full_img_range);
        end
        %
        function test_loadobj_v0_v1(obj)
            proj.u = [1,0,0];
            proj.v = [0,1,0];
            ref_obj = data_sqw_dnd(proj,[1,0.01,2],[-1,1],[0,1],[0,1,10]);
            % why did empty old objects contain npix == 1?
            ref_obj.npix = ones(size(ref_obj.npix));

            % check modern loader (if saved)
            obj.assertEqualToTolWithSave(ref_obj,'tol',[1.e-15,1.e-16]);

            ld = load('data_sqw_dnd_V0_ref_data.mat');
            loaded_v0_obj = ld.obj;
            assertEqual(ref_obj,loaded_v0_obj);

            % Here we are preparing to restore data_sqw_dnd stored as common
            % object when it is split to projection and axes_block
            %ld = load('data_sqw_dnd_V1_ref_data.mat');
            %loaded_v1_obj = ld.test_loadobj_v0.ref_obj;
            %assertEqual(ref_obj,loaded_v1_obj);

        end


        function test_get_proj_hkl_from_cut(obj)
            proj = ortho_proj([1,1,0],[1,-1,0]);
            proj.type='rrr';
            % Be sure that cut is within the ranges of the real pixel range
            % and cuts some pixels from all sides for the cut limits to be
            % around real pix limits
            source_cut = cut_sqw(obj.ref_sqw,proj,[-1,0.02,3],[-2,0.02,2],[-1,1],[-4,4]);
            % Check projection 0;
            proj_0 =  source_cut.data.get_projection();
            assertTrue(isa(proj_0 ,'aProjection'));
            img_range = source_cut.data.img_range;
            ref_img_range = [ -1.0100   -2.0100   -1.0000   -4.0000;
                3.0100    2.0100    1.0000    4.0000]; % actually look at cut ranges
            assertElementsAlmostEqual(ref_img_range,img_range,'absolute',9.e-5);

            full_img_range = expand_box(img_range(1,:),img_range(2,:));
            full_pix_img_range = proj_0.transform_img_to_pix(full_img_range);
            eval_pix_range = [min(full_pix_img_range,[],2),max(full_pix_img_range,[],2)]';
            ref_eval_range =  [-7.1945   -7.6191   -3.1416   -4.0000;...
                14.0451   12.6648    3.1416    4.0000];
            assertElementsAlmostEqual(ref_eval_range,eval_pix_range,'absolute',9.e-5);
            real_pix_range = source_cut.data.pix.pix_range;
            pix_ref_range = [-0.1238   -6.7724   -3.0949   -4.0000;...
                5.6506   11.9775    3.0949    4.0000];
            assertElementsAlmostEqual(pix_ref_range,real_pix_range,'absolute',9.e-5);

            %             %
            %             % visualise correct image ranges if requested .
            %             co = source_cut.data.pix.q_coordinates;
            %             figure
            %             scatter3(co(1,:),co(2,:),co(3,:),'.')
            %             hold on
            %             scatter3(full_pix_img_range(1,:),full_pix_img_range(2,:),full_pix_img_range(3,:),'go')
            %             full_pix_range = expand_box(real_pix_range(1,:),real_pix_range(2,:));
            %             scatter3(full_pix_range(1,:),full_pix_range(2,:),full_pix_img_range(3,:),'ro')



            proj1 = ortho_proj([1,0,0],[0,0,1]);
            proj.type='rrr';
            % Cut in the data within existing image ranges to make new
            % pixels range correspond to transformed pixels range
            ref_cut = cut_sqw(source_cut,proj1,[0,0.01,0.15],[-0.8,0.01,0.8],[-1,1],[-8,8]);

            proj_r =  ref_cut.data.get_projection();
            assertTrue(isa(proj,'aProjection'));
            img_range = ref_cut.data.img_range;
            full_img_range = expand_box(img_range(1,:),img_range(2,:));

            full_pix_img_range = proj_r.transform_img_to_pix(full_img_range);
            pix_img_range = [min(full_pix_img_range,[],2),max(full_pix_img_range,[],2)]';
            ref_imgpix_range = [  -0.0167   -2.7250   -2.7480   -8.0000;...
                0.5185    2.7250    2.7480    8.0000];
            assertElementsAlmostEqual(pix_img_range,ref_imgpix_range,'absolute',9.e-5);

            real_pix_range = ref_cut.data.pix.pix_range;
            ref_pix_range = [  -0.0167   -2.6820   -2.7235   -4.0000;...
                0.5172    2.7111    2.7227    4.0000];
            assertElementsAlmostEqual(real_pix_range,ref_pix_range,'absolute',9.e-5);

            %assertElementsAlmostEqual(real_pix_range,eval_pix_range);
            %             % visualise correct image ranges if requested.
            %             figure
            %             co = ref_cut.data.pix.q_coordinates;
            %
            %             scatter3(co(1,:),co(2,:),co(3,:),'.')
            %             hold on
            %             scatter3(full_pix_img_range(1,:),full_pix_img_range(2,:),full_pix_img_range(3,:),'go')
            %             full_pix_range = expand_box(real_pix_range(1,:),real_pix_range(2,:));
            %             scatter3(full_pix_range(1,:),full_pix_range(2,:),full_pix_img_range(3,:),'ro')



            same_cut = cut_sqw(source_cut ,proj_r,[0,0.01,0.15],[-0.8,0.01,0.8],[-1,1],[-8,8]);

            assertEqualToTol(ref_cut,same_cut,'tol',1.e-9);
        end

        function test_proj_hkl_3D_45deg_old_and_extracted_proj_cut_equals(obj)
            proj = ortho_proj([1,1,0],[1,-1,0]);
            
            ref_cut = cut_sqw(obj.ref_sqw,proj,[],[],[],[-8,8]);

            proj1 =  ref_cut.data.get_projection();
            % To avoid round-off errors on the edge of the ranges
            % which give different cut ranges using proj and proj1,
            % we rounding the projections to 9 significant digits
            proj1.u = round(proj1.u,9);
            proj1.v = round(proj1.v,9);            
            assertTrue(isa(proj,'aProjection'));

            same_cut = cut_sqw(obj.ref_sqw,proj1,[],[],[],[-8,8]);

            assertEqualToTol(ref_cut,same_cut,'tol',[1.e-9,1.e-9]);
        end

        function test_get_proj_hkl_3D(obj)
            proj = ortho_proj([1,0,0],[0,0,1]);
            ref_cut = cut_sqw(obj.ref_sqw,proj,[],[],[],[-8,8]);

            proj1 =  ref_cut.data.get_projection();
            assertTrue(isa(proj1,'ortho_proj'));

            same_cut = cut_sqw(obj.ref_sqw,proj1,[],[],[],[-8,8]);

            assertEqualToTol(ref_cut,same_cut,'tol',1.e-9);
        end


        function test_get_proj_crystal_cartesian(obj)
            d_sqw_dnd = obj.ref_sqw.data;
            proj =  d_sqw_dnd.get_projection();
            assertTrue(isa(proj,'aProjection'));

            same_sqw = cut_sqw(obj.ref_sqw,proj,[],[],[],[]);


            % the comparison below is incomplete, but allows the reasonable
            % initiacl crude estimation of the correctness
            assertElementsAlmostEqual(obj.ref_sqw.data.img_range,...
                same_sqw.data.img_range,'relative',1.e-16);
            assertEqual(obj.ref_sqw.data.pix.num_pixels,...
                same_sqw.data.pix.num_pixels);
            cut_size  = numel(same_sqw.data.npix);
            assertEqual(sum(reshape(obj.ref_sqw.data.npix,1,cut_size)),...
                sum(reshape(same_sqw.data.npix,1,cut_size)));
            assertEqual(sum(reshape(obj.ref_sqw.data.s,1,cut_size)),...
                sum(reshape(same_sqw.data.s,1,cut_size)));
            % This is the full comparison
            assertEqualToTol(obj.ref_sqw,same_sqw,'tol',[2.e-15,3.e-16])

            same_proj = same_sqw.data.get_projection();
            assertEqualToTol(proj,same_proj,'tol',[2.e-15,3.e-16]);
        end
    end
end
