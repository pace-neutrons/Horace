classdef test_change_crystal_bragg_fine < TestCase
    % Test crystal refinement functions change_crytstal and refine_crystal
    %
    %   >> test_refinement           % Use previously saved sqw input data file
    %
    % Author: T.G.Perring
    properties
        sim_sqw_file
        sim_sqw_file_corr
        hpc_config_data;
        qfwhh
    end
    methods
        function obj = test_change_crystal_bragg_fine(varargin)
            if nargin == 0
                name = 'test_change_crystal_bragg_fine';
            else
                name =varargin{1};
            end
            obj= obj@TestCase(name);

            % -----------------------------------------------------------------------------
            % Add common functions folder to path, and get location of common data
            pths = horace_paths;
            common_data_dir = pths.test_common;
            % -----------------------------------------------------------------------------

            dir_out=tmp_dir;
            obj.sim_sqw_file=fullfile(dir_out,'test_change_crystal_bragg_fine_sim.sqw');           % output file for simulation in reference lattice
            obj.sim_sqw_file_corr=fullfile(dir_out,'test_change_crystal_bragg_fine_sim_corr.sqw'); % output file for correction
            hp = hpc_config;
            obj.hpc_config_data = hp.get_data_to_store();
            hp.combine_sqw_using = 'mex_code';


            % Data for creation of test sqw file
            % ----------------------------------
            efix=45;
            emode=1;
            en=-0.75:0.5:0.75;
            par_file=fullfile(common_data_dir,'map_4to1_dec09.par');

            % Parameters for generation of reference sqw file
            alatt=[5,5,5];
            angdeg=[90,90,90];
            u=[1,0,0];
            v=[0,1,0];
            psi=0:1:90;
            omega=0; dpsi=2; gl=3; gs=-3;

            % Parameters of the true lattice
            alatt_true=[5.5,5.5,5.5];
            angdeg_true=[90,90,90];
            obj.qfwhh=0.1;                  % Spread of Bragg peaks
            efwhh=1;                    % Energy width of Bragg peaks
            rotvec=[10,10,0]*(pi/180);  % orientation of the true lattice w.r.t reference lattice


            % Create sqw file for refinement testing
            % --------------------------------------
            %if is_file(sim_sqw_file)
            pix_range = calc_sqw_pix_range (efix, emode, en(1), en(end), par_file, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);

            sqw_tmp_file=cell(size(psi));
            for i=1:numel(psi)
                wtmp=dummy_sqw (en, par_file, '', efix, emode, alatt, angdeg,...
                    u, v, psi(i), omega, dpsi, gl, gs, [1,1,1,1], pix_range);
                % Simulate cross-section on all the sqw files: place blobs at Bragg positions of the true lattice
                wtmp=sqw_eval(wtmp{1},@make_bragg_blobs,{[1,obj.qfwhh,efwhh],[alatt,angdeg],[alatt_true,angdeg_true],rotvec});
                sqw_tmp_file{i}=fullfile(dir_out,['dummy_test_change_crystal_1_',num2str(i),'.sqw']);
                save(wtmp,sqw_tmp_file{i});
            end

            % Combine the sqw files
            write_nsqw_to_sqw(sqw_tmp_file,obj.sim_sqw_file);
            % Delete temporary sqw files
            for i=1:numel(sqw_tmp_file)
                try
                    delete(sqw_tmp_file{i})
                catch
                end
            end
        end
        function test_alignment_from_bragg_peaks(obj)
            % Fit Bragg peak positions
            % ------------------------

            proj.u=[1,0,0];
            proj.v=[0,1,0];

            rlu=[1,0,1; 0,1,1; 0,0,1; 1,0,0; 0,-1,0];
            half_len=0.5; half_thick=0.25; bin_width=0.025;

            sqw_to_ref = sqw(obj.sim_sqw_file);

            rlu0=get_bragg_positions(sqw_to_ref, proj, rlu, half_len, half_thick, bin_width);
            % Should get approximately: rlu0=;
            ref_rlu = [1.052,-0.142,0.722;
                0.199,0.732,1.036;
                0.158,-0.135,0.886;
                0.895,0.015,-0.158;
                -0.015,-0.900,-0.158];

            assertElementsAlmostEqual(rlu0,ref_rlu,'absolute',1.e-2)

            alatt = sqw_to_ref.data.proj.alatt;
            angdeg = sqw_to_ref.data.proj.angdeg;

            % Get correction matrix from the 5 peak positions:
            % ------------------------------------------------
            [rlu_corr,alatt_fit,angdeg_fit,rotmat_fit] = refine_crystal(rlu0,alatt,angdeg,rlu,'fix_angdeg');


            % Apply to a copy of the sqw object to see that the alignment is now OK
            % ---------------------------------------------------------------------
            copyfile(obj.sim_sqw_file,obj.sim_sqw_file_corr)
            change_crystal_sqw(obj.sim_sqw_file_corr,rlu_corr)
            rlu0_corr=get_bragg_positions(sqw(obj.sim_sqw_file_corr), proj, rlu, half_len, half_thick, bin_width);


            assertTrue(max(abs(rlu0_corr(:)-rlu(:)))<=obj.qfwhh, ...
                'Problem in refinement of crystal orientation and lattice parameters')
        end
        %------------------------------------------------------------------
        function delete(obj)
            %
            % restore old hpc configuration
            set(hpc_config,obj.hpc_config_data);

            ws = warning('off','MATLAB:DELETE:Permission');

            try
                if exist(obj.sim_sqw_file,'file')
                    delete(obj.sim_sqw_file)
                end
                if exist(obj.sim_sqw_file_corr,'file')
                    delete(obj.sim_sqw_file_corr)
                end
            catch
                disp('Unable to delete temporary sqw file(s)')
            end
            warning(ws);
        end
    end
end
