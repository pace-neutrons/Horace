classdef test_cylindrical_cuts < TestCaseWithSave
    % Test combining powder cylinder sqw files
    %   >> test_combine_pow           % Compare with previously saved results in test_combine_cyl_output.mat
    %                                 % in the same folder as this function
    %   >> test_combine_pow().save()  % Save to test_combine_pow_output.mat in tmp_dir (type >> help tmp_dir
    %                                  % for information about the system specific location returned by tmp_dir)
    %
    % Author: T.G.Perring

    properties
        spe_file_1;
        spe_file_2;
        par_file;

        sqw_file_fine;
        sqw_file_coarse;
        %
        test_helpers_path
    end
    methods

        function obj=test_cylindrical_cuts(varargin)
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this_dir = fileparts(mfilename('fullpath'));
            obj = obj@TestCaseWithSave(name,fullfile(this_dir, ...
                'test_cylindrical_cuts_output.mat'));
            pths = horace_paths;
            common_data_dir = pths.test_common;

            obj.sqw_file_fine=fullfile(tmp_dir,'test_cyl_cut_fine_grid.sqw');
            obj.sqw_file_coarse=fullfile(tmp_dir,'test_cyl_cut_coarse_grid.sqw');

            obj.test_helpers_path = fullfile(this_dir,'powder_tools');
            addpath(obj.test_helpers_path);


            % =====================================================================================================================
            % Create spe files:
            obj.par_file=fullfile(common_data_dir,'map_4to1_dec09.par');

            % test files are present
            obj.spe_file_1=fullfile(this_dir,'test_combine_1.nxspe');
            obj.spe_file_2=fullfile(this_dir,'test_combine_2.nxspe');

            efix=[100,100];
            emode=1;
            alatt=2*pi*ones(1,3);
            angdeg=[90,90,90];
            u=[1,0,0];
            v=[0,1,0];
            omega=0; dpsi=0; gl=0; gs=0;

            % Simulate first file, with reproducible random looking noise
            % -----------------------------------------------------------
            en1=-5:1:90;
            en2=-9.5:2:95;
            psi_1=0;
            psi_2=30;

            if ~is_file(obj.spe_file_1)
                simulate_spe_testfunc (en1, obj.par_file, obj.spe_file_1, @sqw_cylinder, [10,1], 0.3,...
                    efix(1), emode, alatt, angdeg, u, v, psi_1, omega, dpsi, gl, gs)
            end
            % Simulate second file, with reproducible random looking noise
            % -------------------------------------------------------------

            if ~is_file(obj.spe_file_2)
                simulate_spe_testfunc (en2, obj.par_file, obj.spe_file_2, @sqw_cylinder, [10,1], 0.3,...
                    efix(1), emode, alatt, angdeg, u, v, psi_2, omega, dpsi, gl, gs)
            end

            gen_sqw ({obj.spe_file_1,obj.spe_file_2}, obj.par_file, obj.sqw_file_coarse, efix, 1,...
                alatt, angdeg, u, v, [psi_1,psi_2],  omega, dpsi, gl, gs, ...
                [1,1,1,1]);

            gen_sqw ({obj.spe_file_1,obj.spe_file_2},obj.par_file, ...
                obj.sqw_file_fine, efix, 1,...
                alatt, angdeg, u, v,[psi_1,psi_2],  omega, dpsi, gl, gs, ...
                [50,50,50,50]);



            % test files are in svn
            obj.save();
        end
        function delete(obj)
            %delete(obj.spe_file_1);
            %delete(obj.spe_file_2);
            delete(obj.sqw_file_coarse);
            delete(obj.sqw_file_fine);
            rmpath(obj.test_helpers_path);
        end
        %------------------------------------------------------------------
        function obj = test_cyl_cut_coarse_eq_fine_2D_ThetaPhi(obj)
            spp = cylinder_proj;
            spp.type = 'aad';

            w2_fine  = cut(obj.sqw_file_fine,   spp,[0,3],[-2,0.1,6],[-180,4,180],[-10,90]);
            w2_coars = cut(obj.sqw_file_coarse, spp,[0,3],[-2,0.1,6],[-180,4,180],[-10,90]);

            assertEqualToTol(w2_fine,w2_coars,'ignore_str',true);
        end

        function test_cyl_cut_coarse_eq_fine_2D_QtrQl(obj)
            spp = cylinder_proj;
            spp.type = 'aad';

            %w2_tot=cut(sqw_a,0.1,0.1,[40,50],'-nopix');
            w2_f = cut_sqw(obj.sqw_file_fine,  spp,[0,0.1,6.5],[-1,0.1,6],[-180,180],[40,50]);
            w2_c = cut_sqw(obj.sqw_file_coarse,spp,[0,0.1,6.5],[-1,0.1,6],[-180,180],[40,50]);

            plh=plot(w2_c);
            keep_figure;
            plf= plot(w2_f);

            assertEqualToTol(w2_c,w2_f,'ignore_str',true);
            
            close(plf);
            close(plh);

        end

        function test_cyl_cut_coarse_eq_fine_1d_Qtr(obj)
            spp = cylinder_proj;
            spp.type = 'aar';

            %w1_tot=cut(sqw_a,[0,0.1,3],[2.2,2.5],[40,50],'-nopix');
            w1_c = cut_sqw(obj.sqw_file_coarse,spp,[0,0.1,3],[2.2,2.5],[-pi,pi],[40,50]);
            w1_f = cut_sqw(obj.sqw_file_fine,spp,[0,0.1,3],[2.2,2.5],[-pi,pi],[40,50]);

            plh=plot(w1_c);
            pl(w1_f);

            assertEqualToTol(w1_c,w1_f,'ignore_str',true);

            close(plh);
        end

        function test_cyl_cut_coarse_grid_2D_QtrQl(obj)
            spp = cylinder_proj;
            spp.type = 'aad';

            %w2_tot=cut(sqw_a,0.1,0.1,[40,50],'-nopix');
            w2_1 = cut_sqw(obj.sqw_file_coarse,spp,0.1,0.1,[-180,180],[40,50]);

            plh=plot(w2_1);
            obj.assertEqualToTolWithSave(w2_1,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])

            close(plh);
        end
        %
        function test_cyl_cut_coarse_grid_1d_Qtr(obj)
            spp = cylinder_proj;
            spp.type = 'aar';

            %w1_tot=cut(sqw_a,[0,0.1,3],[2.2,2.5],[40,50],'-nopix');
            w1_1 = cut_sqw(obj.sqw_file_coarse,spp,[0,0.1,3],[2.2,2.5],[-pi,pi],[40,50]);

            plh=plot(w1_1);
            obj.assertEqualToTolWithSave(w1_1,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])
            close(plh);
        end
        %------------------------------------------------------------------
        function test_cyl_cut_qube_2D_zPhi(obj)
            ax = line_axes('img_range',[-5,-5,-5,0;5,5,5,10],'nbins_all_dims',[50,50,50,10]);
            pr = line_proj;
            sq_cyl = sqw.generate_cube_sqw(ax,pr,@sqw_lin_cylinder,[2,1]);
            w1e = cut(sq_cyl,pr,[-1.01,1.01],[-5.01,0.2,5.01],[-5.01,0.2,5.01],[0,10]);
            plc = plot(w1e);

            prc = cylinder_proj;
            prc.type = 'aad';
            w1cyl = cut(sq_cyl,prc,[0,0.2,4.8],[-1.01,1.01],[-180,4,180],[0,10]);

            plot(w1cyl);
            obj.assertEqualToTolWithSave(w1e,'ignore_str',true,'tol',[1.e-7,1.e-7],'-ignore_date');
            obj.assertEqualToTolWithSave(w1cyl,'ignore_str',true,'tol',[1.e-7,1.e-7],'-ignore_date');

            close(plc);
        end

        function test_cyl_cut_qube_2D_qr(obj)
            ax = line_axes('img_range',[-5,-5,-5,0;5,5,5,10],'nbins_all_dims',[50,50,50,10]);
            pr = line_proj([0,1,0],[1,0,0]);
            sq_cyl = sqw.generate_cube_sqw(ax,pr,@sqw_lin_cylinder,[2,1]);
            w1e = cut(sq_cyl,pr,[0.1,0.2, 5.1],[0.1,0.2,5.1],[-0.15,0.15],[0,10]);
            phl = plot(w1e);

            % similarly looking cuts.
            prc = cylinder_proj;
            prc.type = 'aar';
            w1cyl = cut(sq_cyl,prc,[0.1,0.2,5.1],[0.1,0.2,5.01],[0,1.1],[0,10]);
            plot(w1cyl);
            obj.assertEqualToTolWithSave(w1e,'ignore_str',true,'tol',[1.e-7,1.e-7],'-ignore_date');
            obj.assertEqualToTolWithSave(w1cyl,'ignore_str',true,'tol',[1.e-7,1.e-7],'-ignore_date');
            close(phl);
        end

        function test_cyl_cut_qube_1D_ez(obj)
            ax = line_axes('img_range',[-5,-5,-5,0;5,5,5,10],'nbins_all_dims',[50,50,50,10]);
            pr = line_proj;
            sq_cyl = sqw.generate_cube_sqw(ax,pr,@sqw_lin_cylinder,[2,1]);
            w1e = cut(sq_cyl,pr,[-5,0.4,5],[-0.11,0.11],[-0.11,0.11],[0,10]);

            prc = cylinder_proj;
            prc.type = 'aar';
            w1cyl = cut(sq_cyl,prc,[0,0.11*sqrt(2)],[-5,0.4,5],[-pi,pi],[0,10]);
            plot(w1e);
            phc = pl(w1cyl);
            obj.assertEqualToTolWithSave(w1e,'ignore_str',true,'tol',[1.e-7,1.e-7],'-ignore_date');
            obj.assertEqualToTolWithSave(w1cyl,'ignore_str',true,'tol',[1.e-7,1.e-7],'-ignore_date');
            close(phc);
        end

        function test_cyl_cut_qube_1D_qr(obj)
            ax = line_axes('img_range',[-5,-5,-5,0;5,5,5,10],'nbins_all_dims',[50,50,50,10]);
            pr = line_proj;
            sq_cyl = sqw.generate_cube_sqw(ax,pr,@sqw_lin_cylinder,[2,1]);
            w1e = cut(sq_cyl,pr,[-0.5,0.5],[0,0.1,5],[-0.11,0.11],[0,10]);

            prc = cylinder_proj;
            prc.type = 'aar';
            w1cyl = cut(sq_cyl,prc,[0,0.1,5],[-0.11,0.11],[0,1],[0,10]);
            plot(w1e);
            phc = pl(w1cyl);
            obj.assertEqualToTolWithSave(w1e,'ignore_str',true,'tol',[1.e-7,1.e-7],'-ignore_date');
            obj.assertEqualToTolWithSave(w1cyl,'ignore_str',true,'tol',[1.e-7,1.e-7],'-ignore_date');
            close(phc);
        end

    end
end
