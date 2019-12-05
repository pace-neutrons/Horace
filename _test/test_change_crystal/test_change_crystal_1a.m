classdef test_change_crystal_1a < TestCase
    % Test crystal refinement functions change_crytstal and refine_crystal
    %
    %
    properties
        %
        dir_out
        nxs_file % list of generated auxiliary nxs files
        misaligned_sqw_file
        %
        %
        % Data for creation of test sqw file
        % ----------------------------------
        efix = 45;
        emode = 1;
        en=-0.75:0.5:0.75;
        alatt=[5,5,5];
        par_file
        angdeg=[90,90,90];
        u=[1,0,0];
        v=[0,1,0];
        psi=0:2:10;
        omega=0; dpsi=2; gl=3; gs=-3;
    end
    properties(Access=private)
        clob % cleanup object
    end
    methods
        function obj = test_change_crystal_1a(varargin)
            if nargin == 0
                name = 'test_change_crystal_1a';
            else
                name =varargin{1};
            end
            obj= obj@TestCase(name);
            %
            global test_change_crystal_1a_n_calls;
            if isempty(test_change_crystal_1a_n_calls)
                test_change_crystal_1a_n_calls= 1;
            else
                test_change_crystal_1a_n_calls= test_change_crystal_1a_n_calls+1;
            end
            hpc = hpc_config;
            dat2recover = hpc.get_data_to_store;
            hpc_restore = onCleanup(@()set(hpc,dat2recover));
            hpc.build_sqw_in_parallel=0;
            % -----------------------------------------------------------------------------
            % Add common functions folder to path, and get location of common data
            horace_root = horace_git_root();
            cof_path= fullfile(horace_root,'_test','common_functions');
            addpath(cof_path);
            
            
            common_data_dir=fullfile(horace_root,'_test','common_data');
            % -----------------------------------------------------------------------------
            % generate shifted sqw file
            obj.par_file=fullfile(common_data_dir,'9cards_4_4to1.par');
            % Parameters for generation of reference sqw file
            obj.dir_out=tmp_dir;
            
            sim_sqw_file=fullfile(obj.dir_out,'test_change_crystal_1a_sim.sqw'); % output file for simulation in reference lattice
            obj=obj.build_misaligned_source_file(sim_sqw_file);
            %
            % class is deleted on cleanup, but local variables are stored
            % withon lambda function, so to run proper cleanup operation
            % one needs to assign class variables to clean to
            nxs_file_s = obj.nxs_file;
            clearner = @(files,sqw_file,cl_path)(...
                test_change_crystal_1a.change_crystal_1a_cleanup(...
                files ,sqw_file,cl_path));
            obj.clob = {onCleanup(@()clearner(nxs_file_s,sim_sqw_file,cof_path)),hpc_restore};
            
        end
        function test_u_alighnment_tf_way(obj)
            % Fit Bragg peak positions
            % ------------------------
            proj.u=obj.u;
            proj.v=obj.v;
            
            
            %bp=[0,-1,-1; 0,-1,0; 1,2,0; 2,3,0; 0,-1,1;0,0,1];
            % bp=   [0,-1,0;  3,  1,   0; 2  ,0,0];  %;0,0,1
            bp=[0,-1,0; 1,2,0; 0,-1,1]; %;0,0,1
            
            half_len=0.5; half_thick=0.25; bin_width=0.025;
            
            [rlu_real,width,wcut,wpeak]=bragg_positions(obj.misaligned_sqw_file,...
                bp, 1.5, 0.02, 0.4, 1.5, 0.02, 0.4, 2, 'gauss');
            %[rlu0,width,wcut,wpeak]=bragg_positions(read_sqw(sim_sqw_file), proj, rlu, half_len, half_thick, bin_width);
            %bragg_positions_view(wcut,wpeak)
            
            
            % Get correction matrix from the 3 peak positions:
            % ------------------------------------------------
            [rlu_corr,alatt1,angdeg1,rotmat_fit] = refine_crystal(rlu_real,...
                obj.alatt, obj.angdeg, bp,...
                'fix_angdeg','fix_alatt_ratio');
            %'fix_lattice');
            
            
            
            % Apply to a copy of the sqw object to see that the alignment is now OK
            % ---------------------------------------------------------------------
            sim_sqw_file_corr=fullfile(obj.dir_out,'test_change_crystal_1sima_corr.sqw'); % output file for correction
            copyfile(obj.misaligned_sqw_file,sim_sqw_file_corr)
            cleanup_obj=onCleanup(@()delete(sim_sqw_file_corr));
            
            change_crystal_sqw(sim_sqw_file_corr,rlu_corr)
            rlu0_corr=get_bragg_positions(read_sqw(sim_sqw_file_corr), proj,...
                bp, half_len, half_thick, bin_width);
            
            % problem in
            assertElementsAlmostEqual(bp,rlu0_corr,'absolute',half_thick);
            %
            [alatt_c, angdeg_c, dpsi_deg, gl_deg, gs_deg] = ...
                crystal_pars_correct (obj.u, obj.v, obj.alatt, obj.angdeg, ...
                0, 0, 0, 0, rlu_corr);
            %
            %
            assertElementsAlmostEqual(alatt_c,obj.alatt,'absolute',0.01)
            assertElementsAlmostEqual(angdeg_c,obj.angdeg,'absolute',0.01)
            %
            realigned_sqw_file=fullfile(obj.dir_out,'test_change_crystal_1sima_realigned.sqw'); % output file for correction
            cleanup_obj1=onCleanup(@()delete(realigned_sqw_file));
            
            % Generate re-aligned crystal
            gen_sqw (obj.nxs_file, '', realigned_sqw_file, ...
                obj.efix, obj.emode, alatt_c, obj.angdeg,...
                obj.u, obj.v, obj.psi, 0, dpsi_deg, gl_deg, gs_deg);
            
            rlu1_corr=get_bragg_positions(read_sqw(realigned_sqw_file), ...
                proj, bp, half_len, half_thick, bin_width);
            assertElementsAlmostEqual(bp,rlu1_corr,'absolute',half_thick);
            assertElementsAlmostEqual(rlu0_corr,rlu1_corr,'absolute',0.01);
            
        end
        %
        function xest_u_alighnment(obj)
            % have not been finished, does not work
            % Test is disabled
            %
            % Fit Bragg peak positions
            % ------------------------
            proj.u=obj.u;
            proj.v=obj.v;
            
            
            %bp=[0,-1,-1; 0,-1,0; 1,2,0; 2,3,0; 0,-1,1;0,0,1];
            %bp=[0,-1,0; 1,2,0; 0,-1,1]; %;0,0,1
            %bp=[1,3,0;0,0,1;0,-1,0; 0,-1,-1;0,0,-1]; %;0,0,1
            bp=[1,3,0;0,0,1; 0,-1,-1;0,0,-1]; %;0,0,1
            half_len=0.5; half_thick=0.25; bin_width=0.025;
            
            rlu_real=get_bragg_positions(obj.misaligned_sqw_file, proj,...
                bp, half_len, half_thick, bin_width);
            
            %[rlu_real,width,wcut,wpeak]=bragg_positions(obj.misaligned_sqw_file,...
            %    bp, 1.5, 0.02, 0.4, 1.5, 0.02, 0.4, 2, 'gauss');
            %[rlu0,width,wcut,wpeak]=bragg_positions(read_sqw(sim_sqw_file), proj, rlu, half_len, half_thick, bin_width);
            %bragg_positions_view(wcut,wpeak)
            
            
            % Get correction matrix from the 5 peak positions:
            % ------------------------------------------------
            [rlu_corr,alatt,angdeg,rotmat_fit]=orient_crystal(bp,rlu_real,bp,obj.alatt,obj.angdeg);
            %[rlu_corr,alatt1,angdeg1,rotmat_fit] = refine_crystal(rlu_real,...
            %    obj.alatt, obj.angdeg, bp,'fix_angdeg','fix_alatt_ratio');
            
            
            
            % Apply to a copy of the sqw object to see that the alignment is now OK
            % ---------------------------------------------------------------------
            sim_sqw_file_corr=fullfile(obj.dir_out,'test_change_crystal_1sima_corr.sqw'); % output file for correction
            copyfile(obj.misaligned_sqw_file,sim_sqw_file_corr)
            cleanup_obj=onCleanup(@()delete(sim_sqw_file_corr));
            
            change_crystal_sqw(sim_sqw_file_corr,rlu_corr)
            rlu0_corr=get_bragg_positions(read_sqw(sim_sqw_file_corr), proj,...
                bp, half_len, half_thick, bin_width);
            
            % problem in
            assertElementsAlmostEqual(bp,rlu0_corr,'absolute',half_thick);
            %
            %[alatt_c, angdeg_c, dpsi_deg, gl_deg, gs_deg] = ...
            %    crystal_pars_correct (obj.u, obj.v, obj.alatt, obj.angdeg, ...
            %    0, 0, 0, 0, rlu_corr);
            %
            %
            %assertEqual(alatt_c,obj.alatt)
            %assertEqual(angdeg_c,obj.angdeg)
            %
            realigned_sqw_file=fullfile(obj.dir_out,'test_change_crystal_1sima_realigned.sqw'); % output file for correction
            cleanup_obj1=onCleanup(@()delete(realigned_sqw_file));
            
            % Generate re-aligned crystal
            gen_sqw (obj.nxs_file, '', realigned_sqw_file, ...
                obj.efix, obj.emode, alatt_c, angdeg_c,...
                obj.u, obj.v, obj.psi, 0, dpsi_deg, gl_deg, gs_deg);
            
            rlu1_corr=get_bragg_positions(read_sqw(realigned_sqw_file), ...
                proj, bp, half_len, half_thick, bin_width);
            assertElementsAlmostEqual(bp,rlu1_corr,'absolute',half_thick);
            
        end
    end
    methods(Access=private)
        %
        function  obj=build_misaligned_source_file(obj,sim_sqw_file)
            % generate sqw file misaligned according to wrong gl, gs,dpsi.
            %
            
            hpc = hpc_config;
            hpc_ds = hpc.get_data_to_store;
            clob2 = onCleanup(@()set(hpc_config,hpc_ds));
            hpc.combine_sqw_using = 'matlab';
            hpc.build_sqw_in_parallel = 0;            
            
            qfwhh=0.1;                % Spread of Bragg peaks
            efwhh=1;                  % Energy width of Bragg peaks
            rotvec=[0,0,0]*(pi/180);  % orientation of the true lattice w.r.t reference lattice
            
            obj.nxs_file =cell(size(obj.psi));
            nxs_file_exist = true;
            for i=1:numel(obj.psi)
                obj.nxs_file{i}=fullfile(obj.dir_out,['dummy_test_change_crystal_1a_',num2str(i),'.nxspe']);
                if ~(exist(obj.nxs_file{i},'file')==2)
                    nxs_file_exist = false;
                end
            end
            
            if ~nxs_file_exist
                
                % Create sqw file for refinement testing
                % --------------------------------------
                urange = calc_sqw_urange (obj.efix, obj.emode,...
                    obj.en(1), obj.en(end), obj.par_file, obj.alatt, obj.angdeg,...
                    obj.u, obj.v, obj.psi, obj.omega, obj.dpsi, obj.gl, obj.gs);
                
                for i=1:numel(obj.psi)
                    sqw_obj = fake_sqw (obj.en, obj.par_file, '', obj.efix,...
                        obj.emode, obj.alatt, obj.angdeg,...
                        obj.u, obj.v, obj.psi(i), obj.omega, ...
                        obj.dpsi, obj.gl, obj.gs, [1,1,1,1], urange);
                    % Simulate cross-section on every the sqw file: place blobs at Bragg positions of the true lattice
                    sqw_obj=sqw_eval(sqw_obj{1},@make_bragg_blobs,...
                        {[qfwhh,efwhh],[obj.alatt,obj.angdeg],...
                        [obj.alatt,obj.angdeg],rotvec});
                    % mainly to propagate errors as sqw_eval nullified errors?
                    npix = size(sqw_obj.data.pix,2);
                    sqw_obj.data.pix(9,:) = ones(1,npix);
                    sqw_obj=recompute_bin_data_tester(sqw_obj);
                    % convert to nxspe (instrument view)
                    rdo = rundatah(sqw_obj);
                    rdo.saveNXSPE(obj.nxs_file{i});
                end
            end
            
            
            % Generate misaligned sqw file, with gl gs dpsi =0
            if ~(exist(sim_sqw_file,'file')==2)
                gen_sqw (obj.nxs_file, '', sim_sqw_file, ...
                    obj.efix, obj.emode, obj.alatt, obj.angdeg,...
                    obj.u, obj.v, obj.psi, 0, 0, 0, 0);
            end
            obj.misaligned_sqw_file = sim_sqw_file;
            
        end
    end
    methods(Static,Access=private)
        function change_crystal_1a_cleanup(nxs_file,misaligned_sqw_file,cof_path)
            % delete all auxiliary generated files on last
            % instance of test_change_crystal_1a class deletion
            %
            global test_change_crystal_1a_n_calls;
            test_change_crystal_1a_n_calls = test_change_crystal_1a_n_calls-1;
            if test_change_crystal_1a_n_calls > 0
                return
            end
            ws = warning('off','MATLAB:DELETE:Permission');
            
            % Delete temporary nxs files
            for i=1:numel(nxs_file)
                try
                    delete(nxs_file{i})
                catch
                end
            end
            delete(misaligned_sqw_file);
            
            rmpath(cof_path);
            warning(ws);
        end
        
    end
end

