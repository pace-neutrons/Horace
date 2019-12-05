classdef test_combine_cyl < TestCaseWithSave
    % Test combining powder cylinder sqw files
    %   >> test_combine_cyl           % Compare with previously saved results in test_combine_cyl_output.mat
    %                                 % in the same folder as this function
    %   >> test_combine_cyl().save()  % Save to test_combine_cyl_output.mat in tmp_dir (type >> help tmp_dir
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
        alatt;
    end
    methods
        function this=test_combine_cyl(varargin)
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this = this@TestCaseWithSave(name,fullfile(fileparts(mfilename('fullpath')),'test_combine_cyl_output.mat'));
            horace_root = horace_root();
            common_data_dir=fullfile(horace_root,'_test','common_data');
            test_functions_path=fullfile(horace_root,'_test/common_functions');
            addpath(test_functions_path);
            
            
            % =====================================================================================================================
            % Create spe files:
            this.par_file=fullfile(common_data_dir,'map_4to1_dec09.par');
            %spe_dir = tmp_dir(); %fileparts(mfilename('fullpath'));
            spe_dir = fileparts(mfilename('fullpath'));
            this.spe_file_1=fullfile(spe_dir,'test_combine_1.nxspe');
            this.spe_file_2=fullfile(spe_dir,'test_combine_2.nxspe');
            
            this.efix=100;
            emode=1;
            this.alatt=2*pi*[1,1,1];
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
                    this.efix, emode, this.alatt, angdeg, u, v, this.psi_1, omega, dpsi, gl, gs)
            end
            % Simulate second file, with reproducible random looking noise
            % -------------------------------------------------------------
            en=-9.5:2:95;
            this.psi_2=30;
            if ~exist(this.spe_file_2,'file')
                simulate_spe_testfunc (en, this.par_file, this.spe_file_2, @sqw_cylinder, [10,1], 0.3,...
                    this.efix, emode, this.alatt, angdeg, u, v, this.psi_2, omega, dpsi, gl, gs)
            end
            % Handle class! test files are in SVN
            %add_to_files_cleanList(this,this.spe_file_1,this.spe_file_2);
            add_to_path_cleanList(this,test_functions_path);
            
            
        end
        
        function this=test_combine_pow1(this)
            % Create sqw files, combine and check results
            % -------------------------------------------
            sqw_file_1=fullfile(tmp_dir,'test_cyl_1.sqw');
            % clean up
            cleanup_obj=onCleanup(@()this.delete_files(sqw_file_1));
            
            emode = 1;
            
            gen_sqw_cylinder_test (this.spe_file_1, this.par_file, sqw_file_1, this.efix, emode, this.alatt(3), this.psi_1, 90, 0);
            
            w2_1 = cut_sqw(sqw_file_1,0.1,0.1,[40,50],'-nopix');
            w1_1 = cut_sqw(sqw_file_1,[0,0.1,3],[2.2,2.5],[40,50],'-nopix');
            
            tol = this.tol;
            this.tol = -2.e-3;
            this=save_or_test_variables(this,w2_1,w1_1,...
                'ignore_str',1);
            this.tol = tol;
            
            %--------------------------------------------------------------------------------------------------
            % Visually inspect
            acolor k
            plot(w2_1)
            acolor b
            dd(w1_1)
            % acolor r
            % pd(w1_tot)  % does not overlay - but that is OK
            %--------------------------------------------------------------------------------------------------
            
        end
        function this=test_combine_cyl2(this)
            % Create sqw files, combine and check results
            % -------------------------------------------
            sqw_file_2=fullfile(tmp_dir,'test_cyl_2.sqw');
            % clean up
            cleanup_obj=onCleanup(@()this.delete_files(sqw_file_2));
            
            emode = 1;
            
            gen_sqw_cylinder_test (this.spe_file_2, this.par_file, sqw_file_2, this.efix, emode, this.alatt(3), this.psi_2, 90, 0);
            
            w2_2=cut_sqw(sqw_file_2,0.1,0.1,[40,50],'-nopix');
            
            w1_2=cut_sqw(sqw_file_2,[0,0.1,3],[2.2,2.5],[40,50],'-nopix');
            

            this.assertEqualToTolWithSave(w2_2,'ignore_str',true,'tol',1.e-7)
            this.assertEqualToTolWithSave(w1_2,'ignore_str',true,'tol',1.e-7)            
            
            %--------------------------------------------------------------------------------------------------
            % Visually inspect
            acolor k
            plot(w2_2)
            acolor b
            dd(w1_2)
            % acolor r
            % pd(w1_tot)  % does not overlay - but that is OK
            %--------------------------------------------------------------------------------------------------
        end
        function this=test_combine_cyl_tot(this)
            % Create sqw files, combine and check results
            % -------------------------------------------
            sqw_file_tot=fullfile(tmp_dir,'test_cyl_tot.sqw');
            % clean up
            cleanup_obj=onCleanup(@()this.delete_files(sqw_file_tot));
            
            emode = 1;
            gen_sqw_cylinder_test ({this.spe_file_1,this.spe_file_2}, this.par_file, sqw_file_tot, this.efix, emode, this.alatt(3), [this.psi_1,this.psi_2], 90, 0);
            
            w2_tot=cut_sqw(sqw_file_tot,0.1,0.1,[40,50],'-nopix');
            
            w1_tot=cut_sqw(sqw_file_tot,[0,0.1,3],[2.2,2.5],[40,50],'-nopix');
            
            
            this=save_or_test_variables(this,w2_tot,w1_tot,'ignore_str',1,...
                'tol',-2.e-3);
            
            
            %--------------------------------------------------------------------------------------------------
            % Visually inspect
            acolor k
            plot(w2_tot)
            % acolor b
            % pd(w1_2)
            acolor r
            plot(w1_tot)  % does not overlay - but that is OK
            %--------------------------------------------------------------------------------------------------
            
        end
        
    end
end
