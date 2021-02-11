classdef test_gen_runfiles < TestCase
    % Test that a bug discovered in gen_runfiles on 31/10/2013 has been resolved

    properties
        common_data_dir
    end

    methods
        function obj = test_gen_runfiles(name)
            obj = obj@TestCase(name);

            % -----------------------------------------------------------------------------
            % Add common functions folder to path, and get location of common data
            hor_root = horace_root();
            addpath(fullfile(hor_root, '_test', 'common_functions'))
            obj.common_data_dir = fullfile(hor_root, '_test', 'common_data');
            % -----------------------------------------------------------------------------
        end

        function test_gen_sqw_serial(obj)

            % This test should always run serially
            % test_gen_sqw_accumulate_sqw_<framework> tests in parallel
            hpc = hpc_config;
            original_hpc_conf = hpc.get_data_to_store();
            hpc.saveable = false;
            hpc.build_sqw_in_parallel = false;
            hpc.combine_sqw_using = 'matlab';
            config_cleanup = onCleanup(@() set(hpc, original_hpc_conf));

            outdir = tmp_dir; % directory of spe and tmp files

            nfiles_max = 2;

            % =====================================================================================================================
            % Make spe files
            % =====================================================================================================================
            par_file = fullfile('96dets.par');
            spe_file = cell(1, nfiles_max);
            for i = 1:nfiles_max
                spe_file{i} = [outdir, 'test_gen_runfiles_spe_', num2str(i), '.nxspe'];
            end
            sqw_file_12 = fullfile(outdir, 'test_gen_runfiles_sqw_12.sqw');
            cleanup_obj = onCleanup(@()delete(spe_file{:}, sqw_file_12));

            en = cell(1, nfiles_max);
            efix = zeros(1, nfiles_max);
            psi = zeros(1, nfiles_max);
            omega = zeros(1, nfiles_max);
            dpsi = zeros(1, nfiles_max);
            gl = zeros(1, nfiles_max);
            gs = zeros(1, nfiles_max);
            for i = 1:nfiles_max
                efix(i) = 35 + 0.5 * i; % different ei for each file
                en{i} = 0.05 * efix(i):0.2 + i / 50:0.95 * efix(i); % different energy bins for each file
                psi(i) = 90 - i + 1;
                omega(i) = 10 + i / 2;
                dpsi(i) = 0.1 + i / 10;
                gl(i) = 3 - i / 6;
                gs(i) = 2.4 + i / 7;
            end
            psi = 90:-1:90 - nfiles_max + 1;

            emode = 1;
            alatt = [4.4, 5.5, 6.6];
            angdeg = [100, 105, 110];
            u = [1.02, 0.99, 0.02];
            v = [0.025, -0.01, 1.04];

            pars = [1000, 8, 2, 4, 0]; % [Seff,SJ,gap,gamma,bkconst]
            scale = 0.3;
            for i = 1:nfiles_max
                simulate_spe_testfunc(en{i}, par_file, spe_file{i}, @sqw_sc_hfm_testfunc, pars, scale, ...
                    efix(i), emode, alatt, angdeg, u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i));
            end

            % =====================================================================================================================
            % The line that failed before: the problem was efix the same for two files, but number of energy bins different
            % =====================================================================================================================
            try
                gen_sqw(spe_file, par_file, sqw_file_12, efix(1), emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'replicate');
            catch Err
                rethrow(Err);
            end

            assertEqual(exist(spe_file{1}, 'file'), 2)
            assertEqual(exist(spe_file{2}, 'file'), 2)

            assertEqual(exist(sqw_file_12, 'file'), 2)
        end
    end
end