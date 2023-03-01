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
        test_helpers_path
    end
    methods

        function obj=test_combine_pow(varargin)
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this_dir = fileparts(mfilename('fullpath'));
            obj = obj@TestCaseWithSave(name,fullfile(this_dir,'test_combine_pow_output.mat'));
            pths = horace_paths;
            common_data_dir = pths.test_common;
            obj.test_helpers_path = fullfile(this_dir,'powder_tools');
            addpath(obj.test_helpers_path);

            % =====================================================================================================================
            % Create spe files:
            obj.par_file=fullfile(common_data_dir,'map_4to1_dec09.par');

            % test files are present
            obj.spe_file_1=fullfile(this_dir,'test_combine_1.nxspe');
            obj.spe_file_2=fullfile(this_dir,'test_combine_2.nxspe');

            obj.efix=100;
            emode=1;
            alatt=2*pi*[1,1,1];
            angdeg=[90,90,90];
            u=[1,0,0];
            v=[0,1,0];
            omega=0; dpsi=0; gl=0; gs=0;

            % Simulate first file, with reproducible random looking noise
            % -----------------------------------------------------------
            en=-5:1:90;
            obj.psi_1=0;

            if ~exist(obj.spe_file_1,'file')
                simulate_spe_testfunc (en, obj.par_file, obj.spe_file_1, @sqw_cylinder, [10,1], 0.3,...
                    obj.efix, emode, alatt, angdeg, u, v, obj.psi_1, omega, dpsi, gl, gs)
            end
            % Simulate second file, with reproducible random looking noise
            % -------------------------------------------------------------
            en=-9.5:2:95;
            obj.psi_2=30;
            if ~exist(obj.spe_file_2,'file')
                simulate_spe_testfunc (en, obj.par_file, obj.spe_file_2, @sqw_cylinder, [10,1], 0.3,...
                    obj.efix, emode, alatt, angdeg, u, v, obj.psi_2, omega, dpsi, gl, gs)
            end
            % test files are in svn
            obj.save();
        end
        function delete(obj)
            delete(obj.spe_file_1);
            delete(obj.spe_file_2);
            rmpath(obj.test_helpers_path);
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

            %--------------------------------------------------------------
            % Visually inspect
            acolor k
            dd(w1_1);
            acolor b
            da(w2_1);
            close all
            %--------------------------------------------------------------
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
