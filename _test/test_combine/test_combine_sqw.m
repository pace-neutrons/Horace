classdef test_combine_sqw < TestCase
    % Test for combining sqw objects
    %
    %---------------------------------------------------------------------
    % Usage:
    %
    %>>runtests test_combine_sqw
    % run all unit tests class contains
    % or
    %>>runtests test_combine_sqw:test_combine1D
    %run the particular test
    % or
    %>>tc = test_combine_sqw();
    %>>tc.test_combine1D()
    % -- Runs particular test saving construction time.
    properties
        working_dir
        % test parameters file, used in dummy_sqw calculations
        par_file
        % sample sqw object, used as source for tests with non-orthogonal
        % coordinate system
        sqw_sample_gen
        %
        sqw_sample_ortho
        %
        u
        v
        % the random parameters for the transformation
        %   {      emode efix,   alatt,     angdeg,         u,               v,            psi,
        gen_sqw_par = {1,35,[4.4,5.5,6.6],[100,105,110],[1.02,0.99,0.02],[0.025,-0.01,1.04],80,...
            10,0.1,3,2.4}; %omega, dpsi, gl, gs};
        % generate orthogonal projection matrix.
        gen_sqw_par_ortho = {1,35,[2,3,4],[90,90,90],[1,0,0],[0,0,1],80,...
            0,0,0,0}; %omega, dpsi, gl, gs};
        
    end
    
    methods
        function obj=test_combine_sqw(test_class_name)
            % The constructor dummy_sqw class
            
            if ~exist('test_class_name','var')
                test_class_name = 'test_combine_sqw';
            end
            
            obj = obj@TestCase(test_class_name);
            obj.working_dir = tmp_dir;
            
            common_data = fullfile(fileparts(fileparts(mfilename('fullpath'))),'common_data');
            %this.par_file=fullfile(this.results_path,'96dets.par');
            obj.par_file=fullfile(common_data,'gen_sqw_96dets.nxspe');
            obj.u = obj.gen_sqw_par{5};
            obj.v = obj.gen_sqw_par{6};
            tsqw = dummy_sqw(-0.5:1:obj.gen_sqw_par{2}-5, obj.par_file, '',...
                obj.gen_sqw_par{2},obj.gen_sqw_par{1},...
                obj.gen_sqw_par{3:end});
            obj.sqw_sample_gen = tsqw{1};
            
            tsqw = dummy_sqw(-0.5:1:obj.gen_sqw_par_ortho{2}-5, obj.par_file, '',...
                obj.gen_sqw_par_ortho{2},obj.gen_sqw_par_ortho{1},...
                obj.gen_sqw_par_ortho{3:end});
            obj.sqw_sample_ortho = tsqw{1};
            
        end
        %
        function test_combine1D(obj)
            % The test for combining in non-orthogonal coordinate system
            %
            % TODO:
            % original sqw format has issues with nonorhtogonal system,
            % so the format (and test) need to be modified to fix this issue
            
            img_db_range = obj.sqw_sample_gen.data.img_db_range;
            %TODO: this is issue to resolve on refactoring.
            %  img_db_range generated with non-orthogonal lattice is equal
            %  to pix_range, when in fact it should be diffetent
            % (see cut_source_range below).
            proj = ortho_proj([1,0,0],[0,1,0]);
            proj.alatt = obj.sqw_sample_gen.data.alatt;
            proj.angdeg = obj.sqw_sample_gen.data.angdeg;
            pr = obj.sqw_sample_gen.data.pix.pix_range;
            full_pix_range = expand_box(pr(1,:), pr(2,:));
            img_range = proj.transform_pix_to_img(full_pix_range);
            cut_source_range = [min(img_range,[],2),max(img_range,[],2)]';
            %
            cut_range = [min(img_db_range(1,:),cut_source_range(1,:));...
                max(img_db_range(2,:),cut_source_range(2,:))];
            %
            npix0 = obj.sqw_sample_gen.data.num_pixels;
            
            range1 = cut_range (:,1);
            dR = range1(2)-range1(1);
            bin_range = [range1(1),dR/100,range1(2)];
            cut1 = cut_sqw(obj.sqw_sample_gen,proj,...
                bin_range,cut_range(:,2),cut_range(:,3) ,cut_range(:,4));
            n_pix = cut1.data.num_pixels;
            
            assertEqual(npix0,n_pix)
            
            cut2 = copy(cut1);
            cut2.data.pix.signal = 2*cut2.data.pix.signal;
            comb_res = combine_sqw(cut1,cut2);
            npix2 = comb_res.data.num_pixels;
            assertEqual(2*n_pix,npix2);
        end
        %
        function test_combine1D_ortho(obj)
            
            img_db_range = obj.sqw_sample_ortho.data.img_db_range;
            npix0 = obj.sqw_sample_ortho.data.num_pixels;
            range1 = img_db_range(:,1);
            dR = range1(2)-range1(1);
            bin_range = [range1(1)*1.01,dR/100,range1(2)*1.01];
            cut1 = cut_sqw(obj.sqw_sample_ortho,struct('u',[1,0,0],'v',[0,1,0]),...
                bin_range,[-inf,inf],[-inf,inf],[-inf,inf]);
            n_pix = cut1.data.num_pixels;
            
            assertEqual(npix0,n_pix)
            
            cut2 = copy(cut1);
            cut2.data.pix.signal = 2*cut2.data.pix.signal;
            comb_res = combine_sqw(cut1,cut2);
            npix2 = comb_res.data.num_pixels;
            assertEqual(2*n_pix,npix2);
        end
        %
        function test_combine1D_ortho_2ranges(obj)
            
            img_db_range = obj.sqw_sample_ortho.data.img_db_range;
            
            
            range3 = img_db_range(:,3);
            dist3 = range3(2)-range3(1);
            
            cut1 = cut_sqw(obj.sqw_sample_ortho,struct('u',[1,0,0],'v',[0,1,0]),...
                [-inf,inf],[-inf,inf],[range3(1),range3(1)+0.4*dist3],[0,1,29]);
            n_pix1 = cut1.data.num_pixels;
            assertTrue(n_pix1>0);
            cut2 = cut_sqw(obj.sqw_sample_ortho,struct('u',[1,0,0],'v',[0,1,0]),...
                [-inf,inf],[-inf,inf],[range3(2)-0.4*dist3,range3(2)],[0,1,29]);
            n_pix2 = cut2.data.num_pixels;
            assertTrue(n_pix2>0);
            
            comb_res = combine_sqw(cut1,cut2);
            npix_tot = comb_res.data.num_pixels;
            assertEqual(npix_tot,n_pix1+n_pix2);
        end
        %
        function test_combine4D_gen(obj)
            
            n_pix = obj.sqw_sample_gen.data.num_pixels;
            sqw2 = copy(obj.sqw_sample_gen);
            sqw2.data.pix.signal = 2*sqw2.data.pix.signal;
            comb_res = combine_sqw(obj.sqw_sample_gen,sqw2);
            npix2 = comb_res.data.num_pixels;
            assertEqual(2*n_pix,npix2);
        end
        %
        function test_combine4D_ortho(obj)
            %
            n_pix = obj.sqw_sample_ortho.data.num_pixels;
            sqw2 = copy(obj.sqw_sample_ortho);
            sqw2.data.pix.signal = 2*sqw2.data.pix.signal;
            comb_res = combine_sqw(obj.sqw_sample_ortho,sqw2);
            npix2 = comb_res.data.num_pixels;
            assertEqual(2*n_pix,npix2);
        end
        
        
    end
end
