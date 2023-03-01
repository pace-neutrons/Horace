classdef test_spherical_cuts < TestCaseWithSave
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

        function obj=test_spherical_cuts(varargin)
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this_dir = fileparts(mfilename('fullpath'));
            obj = obj@TestCaseWithSave(name,fullfile(this_dir, ...
                'test_spherical_cuts_output.mat'));
            pths = horace_paths;
            common_data_dir = pths.test_common;

            obj.sqw_file_fine=fullfile(tmp_dir,'test_spher_cut_fine_grid.sqw');
            obj.sqw_file_coarse=fullfile(tmp_dir,'test_spher_cut_coarse_grid.sqw');

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

            if ~exist(obj.spe_file_1,'file')
                simulate_spe_testfunc (en1, obj.par_file, obj.spe_file_1, @sqw_cylinder, [10,1], 0.3,...
                    efix(1), emode, alatt, angdeg, u, v, psi_1, omega, dpsi, gl, gs)
            end
            % Simulate second file, with reproducible random looking noise
            % -------------------------------------------------------------

            if ~exist(obj.spe_file_2,'file')
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

        function obj = test_spher_cut_2D_QdE_fineEqCoarse(obj)
            % Create sqw files, combine and check results
            % -------------------------------------------

            spp = spher_proj;
            spp.type = 'add';

            w2_fine = cut_sqw(obj.sqw_file_fine,spp,[0,0.05,8],[-180,180],[-360,360],1);
            w2_coars = cut_sqw(obj.sqw_file_coarse,spp,[0,0.05,8],[0,180],[-180,180],1);


            assertEqualToTol(w2_fine,w2_coars,'ignore_str',true);
        end

        function obj = test_spher_cut_2D_ThetaPhi_fineEqCoarse(obj)
            % Create sqw files, combine and check results
            % -------------------------------------------

            spp = spher_proj;
            spp.type = 'add';

            w2_fine = cut_sqw(obj.sqw_file_fine,spp,[0,8],[0,1,180],[-180,1,180],[-10,90]);
            w2_coars = cut_sqw(obj.sqw_file_coarse,spp,[0,8],[0,1,180],[-180,1,180],[-10,90]);

            assertEqualToTol(w2_fine,w2_coars,'ignore_str',true);
        end


        function obj = test_spher_cut_fine_grid_2D_ThetaPhi(obj)
            % Create sqw files, combine and check results
            % -------------------------------------------

            spp = spher_proj;
            spp.type = 'add';

            w2_tot = cut_sqw(obj.sqw_file_fine,spp,[0,8],[0,1,180],[-180,1,180],[-10,90],'-nopix');
            acolor b
            plh = da(w2_tot);


            obj.assertEqualToTolWithSave(w2_tot,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])

            %--------------------------------------------------------------
            close(plh);
        end

        function obj = test_spher_cut_fine_grid_2D_QdE(obj)
            % Create sqw files, combine and check results
            % -------------------------------------------

            spp = spher_proj;
            spp.type = 'add';

            w2_tot = cut_sqw(obj.sqw_file_fine,spp,[0,0.05,8],[0,180],[-180,180],1,'-nopix');
            acolor b
            plh = da(w2_tot);


            obj.assertEqualToTolWithSave(w2_tot,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])

            %--------------------------------------------------------------
            close(plh);
        end
        function obj = test_spher_cut_fine_grid_1d_Phi(obj)
            % Create sqw files, combine and check results
            % -------------------------------------------

            spp = spher_proj;
            spp.type = 'add';

            w1_tot = cut_sqw(obj.sqw_file_fine,spp,[0,3],[0,180],[-180,1,180],[40,50],'-nopix');
            % Visually inspect
            acolor k
            plh=dd(w1_tot);

            obj.assertEqualToTolWithSave(w1_tot,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])

            %--------------------------------------------------------------
            close(plh);
        end

        function obj = test_spher_cut_fine_grid_1d_Q(obj)
            % Create sqw files, combine and check results
            % -------------------------------------------

            spp = spher_proj;
            spp.type = 'add';

            w1_tot = cut_sqw(obj.sqw_file_fine,spp,[0,0.05,3],[0,180],[-180,180],[40,50],'-nopix');
            % Visually inspect
            acolor k
            plh=dd(w1_tot);

            obj.assertEqualToTolWithSave(w1_tot,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])

            %--------------------------------------------------------------
            close(plh);
        end

        function test_spher_cut_coarse_grid_1d_Theta(obj)
            spp = spher_proj;
            spp.type = 'arr';
            w1_1 = cut_sqw(obj.sqw_file_coarse,spp,[0,3],[0,0.1,pi],[-pi,pi],[40,50],'-nopix');
            plh = plot(w1_1);

            obj.assertEqualToTolWithSave(w1_1,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])
            close(plh);
        end

        function test_spher_cut_coarse_grid_1d_Q(obj)
            spp = spher_proj;
            spp.type = 'arr';
            w1_1 = cut_sqw(obj.sqw_file_coarse,spp,[0,0.05,3],[0,pi],[-pi,pi],[40,50],'-nopix');
            plh=plot(w1_1);

            obj.assertEqualToTolWithSave(w1_1,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])

            close(plh);
        end

        function test_spher_cut_coarse_grid_2D_ThetaPhi(obj)
            spp = spher_proj;
            spp.type = 'arr';
            w2_1 = cut_sqw(obj.sqw_file_coarse,spp,[0,8],[0,0.1,pi],[-pi,0.1,pi],[-10,90],'-nopix');
            plh=plot(w2_1);

            obj.assertEqualToTolWithSave(w2_1,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])
            close(plh);
        end

        function test_spher_cut_coarse_grid_2D_qdE(obj)
            spp = spher_proj;
            spp.type = 'arr';
            w2_1 = cut_sqw(obj.sqw_file_coarse,spp,[0,0.05,8],[0,pi],[-pi,pi],1,'-nopix');
            plh=plot(w2_1);

            obj.assertEqualToTolWithSave(w2_1,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])
            close(plh);
        end
    end
end
