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
            horace_root = fileparts(fileparts(which('horace_init')));
            common_data_dir=fullfile(horace_root,'_test','common_data');
            test_functions_path=fullfile(horace_root,'_test/common_functions');
            addpath(test_functions_path);
            
            
            
            % =====================================================================================================================
            % Create spe files:
            this.par_file=fullfile(common_data_dir,'map_4to1_dec09.par');
            %spe_dir = tmp_dir(); 
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
            %add_to_files_cleanList(this,this.spe_file_1,this.spe_file_2);
            add_to_path_cleanList(this,test_functions_path);
        end
        
        function this=test_combine_pow1(this)
            % Create sqw files, combine and check results
            % -------------------------------------------
            sqw_file_1=fullfile(tmp_dir,'test_pow_1.sqw');
            % clean up
            cleanup_obj=onCleanup(@()this.delete_files(sqw_file_1));
            
            emode = 1;
            
            gen_sqw_powder_test (this.spe_file_1, this.par_file, sqw_file_1, this.efix, emode);
            
            
            w2_1 = cut_sqw(sqw_file_1,[0,0.05,8],0,'-nopix');
            w1_1 = cut_sqw(sqw_file_1,[0,0.05,3],[40,50],'-nopix');
            
            this=save_or_test_variables(this,w2_1,w1_1,'tol',-2.e-2,...
                'ignore_str',1 );
            
            %--------------------------------------------------------------------------------------------------
            % Visually inspect
            acolor k
            dd(w1_1)
            acolor b
            da(w2_1)
            close all
            %--------------------------------------------------------------------------------------------------
            
        end
        function this=test_combine_pow2(this)
            % Create sqw files, combine and check results
            % -------------------------------------------
            sqw_file_2=fullfile(tmp_dir,'test_pow_2.sqw');
            % clean up
            cleanup_obj=onCleanup(@()this.delete_files(sqw_file_2));
            
            emode = 1;
            
            gen_sqw_powder_test (this.spe_file_2, this.par_file, sqw_file_2, this.efix, emode);
            
            w2_2=cut_sqw(sqw_file_2,[0,0.05,8],0,'-nopix');
            
            w1_2=cut_sqw(sqw_file_2,[0,0.05,3],[40,50],'-nopix');
            
            this=save_or_test_variables(this,w2_2,w1_2,'tol',-9.e-2,...
                'ignore_str',1);
            
            %--------------------------------------------------------------------------------------------------
            % Visually inspect
            acolor k
            dd(w1_2)
            acolor b
            plot(w2_2)
            %--------------------------------------------------------------------------------------------------
        end
        function this=test_combine_pow_tot(this)
            % Create sqw files, combine and check results
            % -------------------------------------------
            sqw_file_tot=fullfile(tmp_dir,'test_pow_tot.sqw');
            % clean up
            cleanup_obj=onCleanup(@()this.delete_files(sqw_file_tot));
            
            emode = 1;
            gen_sqw_powder_test ({this.spe_file_1,this.spe_file_2}, this.par_file, sqw_file_tot, this.efix, emode);
            
            w2_tot=cut_sqw(sqw_file_tot,[0,0.05,8],0,'-nopix');
            
            w1_tot=cut_sqw(sqw_file_tot,[0,0.05,3],[40,50],'-nopix');
            
            this=save_or_test_variables(this,w2_tot,w1_tot,'tol',-2.e-2,...
                'ignore_str',1);
            
            %--------------------------------------------------------------------------------------------------
            % Visually inspect
            acolor k
            dd(w1_tot)
            acolor b
            plot(w2_tot)
            % acolor r
            % pd(w1_tot)  % does not overlay - but that is OK
            %--------------------------------------------------------------------------------------------------
            
        end
        
    end
end
