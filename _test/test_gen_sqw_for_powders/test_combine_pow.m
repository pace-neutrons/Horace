classdef test_combine_pow < TestCaseWithSave
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
        %
        efix;
        psi_1;
        psi_2;
    end
    methods

        function this=test_combine_pow(varargin)
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this = this@TestCaseWithSave(name,fullfile(fileparts(mfilename('fullpath')),'test_combine_pow_output.mat'));
            pths = horace_paths;
            common_data_dir = pths.test_common;


            % =====================================================================================================================
            % Create spe files:
            this.par_file=fullfile(common_data_dir,'map_4to1_dec09.par');
            spe_dir = fileparts(mfilename('fullpath'));
            % test files are present
            this.spe_file_1=fullfile(spe_dir,'test_combine_1.nxspe');
            this.spe_file_2=fullfile(spe_dir,'test_combine_2.nxspe');

            this.efix=100;
            emode=1;
            alatt=2*pi*[1,1,1];
            angdeg=[90,90,90];
            u=[1,0,0];
            v=[0,1,0];
            omega=0; dpsi=0; gl=0; gs=0;

            % Simulate first file, with reproducible random looking noise
            % -----------------------------------------------------------
            en=-5:1:90;
            this.psi_1=0;

            if ~exist(this.spe_file_1,'file')
                simulate_spe_testfunc (en, this.par_file, this.spe_file_1, @sqw_cylinder, [10,1], 0.3,...
                    this.efix, emode, alatt, angdeg, u, v, this.psi_1, omega, dpsi, gl, gs)
            end
            % Simulate second file, with reproducible random looking noise
            % -------------------------------------------------------------
            en=-9.5:2:95;
            this.psi_2=30;
            if ~exist(this.spe_file_2,'file')
                simulate_spe_testfunc (en, this.par_file, this.spe_file_2, @sqw_cylinder, [10,1], 0.3,...
                    this.efix, emode, alatt, angdeg, u, v, this.psi_2, omega, dpsi, gl, gs)
            end
            % test files are in svn
            this.save();
        end
        

        function obj=test_combine_pow_1file(obj)
            % Create sqw files, combine and check results
            % -------------------------------------------
            sqw_file_1=fullfile(tmp_dir,'test_pow_1.sqw');
            % clean up
            cleanup_obj=onCleanup(@()obj.delete_files(sqw_file_1));

            emode = 1;

            gen_sqw_powder(obj.spe_file_1, obj.par_file, sqw_file_1, obj.efix, emode);


            w2_1 = cut_sqw(sqw_file_1,[0,0.05,8],0,'-nopix');
            w1_1 = cut_sqw(sqw_file_1,[0,0.05,3],[40,50],'-nopix');

            obj.assertEqualToTolWithSave(w2_1,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])
            obj.assertEqualToTolWithSave(w1_1,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])

            %--------------------------------------------------------------------------------------------------
            % Visually inspect
            acolor k
            dd(w1_1);
            acolor b
            da(w2_1);
            close all
            %--------------------------------------------------------------------------------------------------
        end
        function obj = test_spher_cut_fine_grid(obj)
            % Create sqw files, combine and check results
            % -------------------------------------------
            sqw_file_tot=fullfile(tmp_dir,'test_spher_cut_fine_grid.sqw');
            cleanup_obj = [];
            if ~isfile(sqw_file_tot)
                alatt=[2*pi,2*pi,2*pi];
                angdeg=[90,90,90];
                psi = [0,0];
                u=[1,0,0];
                v=[0,1,0];
                
                gen_sqw ({obj.spe_file_1,obj.spe_file_2},obj.par_file, ...
                    sqw_file_tot, obj.efix, 1,...
                    alatt, angdeg, u, v, psi, 0, 0, 0, 0);

                % clean up
                cleanup_obj=onCleanup(@()obj.delete_files(sqw_file_tot));                
            end
            w2_tot = cut_sqw(sqw_file_tot,spher_proj,[0,0.05,8],[-pi,pi],[-pi,pi],1,'-nopix');
            w1_tot = cut_sqw(sqw_file_tot,spher_proj,[0,0.05,3],[-pi,pi],[-pi,pi],[40,50],'-nopix');


            obj.assertEqualToTolWithSave(w2_tot,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])
            obj.assertEqualToTolWithSave(w1_tot,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])

            %--------------------------------------------------------------------------------------------------
            % Visually inspect
            acolor k
            dd(w1_tot);
            acolor b
            plot(w2_tot);
            % acolor r
            % pd(w1_tot)  % does not overlay - but that is OK
            %--------------------------------------------------------------------------------------------------

        end
        
        function test_spher_cut_coarce_grid(obj)
            sqw_file_2=fullfile(tmp_dir,'test_spher_cut_coarse_grid.sqw');
            cleanup_obj = [];
            if ~isfile(sqw_file_2)
                alatt=[2*pi,2*pi,2*pi];
                angdeg=[90,90,90];
                u=[1,0,0];
                v=[0,1,0];
                gen_sqw (obj.spe_file_1, obj.par_file, sqw_file_2, obj.efix, 1,...
                    alatt, angdeg, u, v, 0, 0, 0, 0, 0);

                % clean up
                cleanup_obj=onCleanup(@()obj.delete_files(sqw_file_2));                
            end

            w2_1 = cut_sqw(sqw_file_2,spher_proj,[0,0.05,8],[-pi,pi],[-pi,pi],1,'-nopix');
            plot(w2_1);
            w1_1 = cut_sqw(sqw_file_2,spher_proj,[0,0.05,3],[-pi,pi],[-pi,pi],[40,50],'-nopix');
            plot(w1_1);            

            obj.assertEqualToTolWithSave(w2_1,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])
            obj.assertEqualToTolWithSave(w1_1,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])


        end
        function this=test_combine_pow2(this)
            % Create sqw files, combine and check results
            % -------------------------------------------
            sqw_file_2=fullfile(tmp_dir,'test_pow_2.sqw');
            % clean up
            cleanup_obj=onCleanup(@()this.delete_files(sqw_file_2));

            emode = 1;

            gen_sqw_powder(this.spe_file_2, this.par_file, sqw_file_2, this.efix, emode);

            w2_2=cut_sqw(sqw_file_2,[0,0.05,8],0,'-nopix');

            w1_2=cut_sqw(sqw_file_2,[0,0.05,3],[40,50],'-nopix');

            this.assertEqualToTolWithSave(w2_2,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5]);
            this.assertEqualToTolWithSave(w1_2,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5]);

            %--------------------------------------------------------------------------------------------------
            % Visually inspect
            acolor k
            dd(w1_2);
            acolor b
            plot(w2_2);
            %--------------------------------------------------------------------------------------------------
        end
        function this = test_combine_pow_tot(this)
            % Create sqw files, combine and check results
            % -------------------------------------------
            sqw_file_tot=fullfile(tmp_dir,'test_pow_tot.sqw');
            % clean up
            cleanup_obj=onCleanup(@()this.delete_files(sqw_file_tot));

            emode = 1;
            gen_sqw_powder({this.spe_file_1,this.spe_file_2}, this.par_file, sqw_file_tot, this.efix, emode);

            w2_tot=cut_sqw(sqw_file_tot,[0,0.05,8],0,'-nopix');

            w1_tot=cut_sqw(sqw_file_tot,[0,0.05,3],[40,50],'-nopix');

            this.assertEqualToTolWithSave(w2_tot,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])
            this.assertEqualToTolWithSave(w1_tot,'ignore_str',true, ...
                'tol',[1.e-7,1.e-5])

            %--------------------------------------------------------------------------------------------------
            % Visually inspect
            acolor k
            dd(w1_tot);
            acolor b
            plot(w2_tot);
            % acolor r
            % pd(w1_tot)  % does not overlay - but that is OK
            %--------------------------------------------------------------------------------------------------

        end

    end
end
