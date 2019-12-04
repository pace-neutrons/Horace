classdef test_gen_sqw_cylinder < TestCaseWithSave
    % Test combining powder cylinder sqw files
    %   >> test_gen_sqw_cylinder           % Compare with previously saved results in test_combine_cyl_output.mat
    %                                 % in the same folder as this function
    %   >> test_gen_sqw_cylinder().save()  % Save to test_gen_sqw_cylinder_output.mat in tmp_dir (type >> help tmp_dir
    %                                  % for information about the system specific location returned by tmp_dir)
    %
    % Author: T.G.Perring
    
    properties
        spe_file;
        par_file;
        %
        efix;
        %
    end
    methods
        function this=test_gen_sqw_cylinder(varargin)
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this = this@TestCaseWithSave(name,fullfile(fileparts(mfilename('fullpath')),'test_gen_sqw_cylinder_output.mat'));
            horace_root = fileparts(fileparts(which('horace_init')));
            common_data_dir=fullfile(horace_root,'_test','common_data');
            test_functions_path=fullfile(horace_root,'_test/common_functions');
            addpath(test_functions_path);
            
            
            % =====================================================================================================================
            % Create spe file:
            this.par_file=fullfile(common_data_dir,'map_4to1_dec09.par');
            
            
            spe_dir = fileparts(mfilename('fullpath'));
            this.spe_file=fullfile(spe_dir,'test_gen_sqw_for_powder.nxspe');
            
            this.efix=100;
            emode=1;
            alatt=[5,5,5];
            angdeg=[90,90,90];
            u=[1,0,0];
            v=[0,1,0];
            omega=0; dpsi=0; gl=0; gs=0;
            
            % Simulate first file, with reproducible random looking noise
            % -----------------------------------------------------------
            en=0:1:90;
            psi=20;
            
            ampl=10; SJ=8; gap=5; gamma=5; bkconst=0;
            scale=0.1;
            
            if ~exist(this.spe_file,'file')
                warning('TEST_GEN_SQW_CYLINDER:runtime_error','re-generating input nxspe files for tests');
                simulate_spe_testfunc (en, this.par_file, this.spe_file, @sqw_sc_hfm_testfunc, [ampl,SJ,gap,gamma,bkconst], scale,...
                    this.efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
                
            end
            
            %add_to_files_cleanList(this,this.spe_file);
            add_to_path_cleanList(this,test_functions_path);
        end
        
        function this=test_gen_sqw_cyl(this)
            
            sqw_cyl_file=fullfile(tmp_dir,'test_cyl_4to1.sqw');
            % clean up
            cleanup_obj=onCleanup(@()this.delete_files(sqw_cyl_file));
            
            emode=1;
            %--------------------------------------------------------------------------------------------------
            % Perform a cylinder average in Horace
            gen_sqw_cylinder_test (this.spe_file, this.par_file, sqw_cyl_file, this.efix, emode, 1.5, 0, 0, 0);
            
            %--------------------------------------------------------------------------------------------------
            % Visual inspection
            % Plot the cylinder averaged sqw data
            wcyl=read_sqw(sqw_cyl_file);
            
            w2 = cut_sqw(wcyl,[4,0.03,6],[-0.15,0.35],0,'-nopix');
            w1 = cut_sqw(wcyl,[2,0.03,6.5],[-0.7,0.2],[53,57],'-nopix');
            
            % dd(w1)
            %--------------------------------------------------------------------------------------------------
            this.assertEqualToTolWithSave(w2,'ignore_str',true,'reltol',1.e-5)
            this.assertEqualToTolWithSave(w1,'ignore_str',true,'reltol',1.e-5)
        end
    end
end


