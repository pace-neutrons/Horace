classdef test_dummy_sqw_bin_pix < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        tmp_data_folder;
        skip_tests;
        current_mex_state;
        current_thread_state;
        sample_dir;
    end

    methods
        function this=test_dummy_sqw_bin_pix(varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_dummy_sqw_bin_pix';
            end
            this = this@TestCase(name);

            hc = hor_config;
            par = parallel_config;
            this.current_mex_state = hc.use_mex;
            this.current_thread_state = par.threads;
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',this.current_mex_state));

            hc.use_mex = 1;

            this.skip_tests = ~hc.use_mex;

            this.tmp_data_folder = tmp_dir;
            pths = horace_paths;
            this.sample_dir = pths.test_common;
        end

        function test_bin_c(this)
            if this.skip_tests
                skipTest('MEX not enabled')
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',this.current_mex_state));


            en=-80:8:760;
            par_file=fullfile(this.sample_dir,'map_4to1_dec09.par');
            sqw_file_single=fullfile(this.tmp_data_folder,'test_dummy_sqw_bin_pix.sqw');
            cleanup_files=onCleanup(@()delete(sqw_file_single));
            efix=800;
            emode=1;
            alatt=[2.87,2.87,2.87];
            angdeg=[90,90,90];
            u=[1,0,0];
            v=[0,1,0];
            omega=0;dpsi=0;gl=0;gs=0;

            psi=8;

            hc=hor_config;
            hc.use_mex = 1;
            dummy_sqw(en, par_file, sqw_file_single, efix, emode, alatt, angdeg,...
                u, v, psi, omega, dpsi, gl, gs);

            w_mex=read_sqw(sqw_file_single);


            assertTrue(~any(w_mex.pix.detector_idx < 1 | w_mex.pix.detector_idx > 36864), ...
                       'found detectors with ID-s outside the allowed range');
            assertTrue(~any(w_mex.pix.energy_idx==0),'en bin id can not be equal to 0');


            hc.use_mex = 0;
            dummy_sqw(en, par_file, sqw_file_single, efix, emode, alatt, angdeg,...
                u, v, psi, omega, dpsi, gl, gs);

            w_nomex=read_sqw(sqw_file_single);
            n_det_out = sum
            assertTrue(~any(w_nomex.pix.detector_idx<1 | w_nomex.pix.detector_idx>36864), ...
                       'found detectors with ID-s outside the allowed range');
            assertTrue(~any(w_nomex.pix.energy_idx==0),'en bin id can not be equal to 0');


            % can not compare pixel arrays as pixel sorting will be
            % different. Compare the whole image instead
            w_mex = d4d(w_mex);
            w_nomex = d4d(w_nomex);
            assertEqualToTol(w_mex, w_nomex, [0, 1e-8])
        end

        function test_bin_c_multithread(this)
            if this.skip_tests
                skipTest('MEX not enabled')
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',this.current_mex_state));
            cleanup_obj2=onCleanup(@()set(parallel_config,'threads',this.current_thread_state));

            par_file=fullfile(this.sample_dir,'96dets.par');

            efix=35+0.5*3;
            en=0.05*efix:0.2+3/50:0.95*efix;
            psi=90-3+1;
            omega=10+3/2;
            dpsi=0.1+3/10;
            gl=3-1/6;
            gs=2.4+3/7;

            emode=1;
            alatt=[4.4,5.5,6.6];
            angdeg=[100,105,110];
            u=[1.02,0.99,0.02];
            v=[0.025,-0.01,1.04];

            sqw_file_single=fullfile(this.tmp_data_folder,'test_bin_c_multithread_dummy_sqw.sqw');
            cleanup_files=onCleanup(@()delete(sqw_file_single));

            hc=hor_config;
            par = parallel_config;

            hc.use_mex = 1;
            par.threads = 1;

            dummy_sqw(en, par_file, sqw_file_single, efix, emode, alatt, angdeg,...
                u, v, psi, omega, dpsi, gl, gs);

            w_mex=read_sqw(sqw_file_single);

            assertTrue(~any(w_mex.pix.detector_idx<1 | w_mex.pix.detector_idx>96), ...
                       'found detectors with ID-s outside the allowed range');
            assertEqual(~any(w_mex.pix.energy_idx==0),'en bin id can not be equal to 0');


            hc.use_mex = 1;
            par.threads = 8;

            dummy_sqw(en, par_file, sqw_file_single, efix, emode, alatt, angdeg,...
                u, v, psi, omega, dpsi, gl, gs);

            w_mex_thr=read_sqw(sqw_file_single);

            assertTrue(~any(w_mex_thr.pix.detector_idx<1 | w_mex_thr.pix.detector_idx>96), ...
                        'found detectors with ID-s out of the range allowed');
            assertTrue(~any(w_mex_thr.pix.energy_idx==0),'en bin id can not be equal to 0');

            % can not compare pixel arrays as pixel sorting will be
            % different. Compare the whole image instead
            %%{
            %skipTest("New dnd: d2d not yet implemented");
            w_mex = d4d(w_mex);
            w_mex_thr = d4d(w_mex_thr);
            assertEqualToTol(w_mex, w_mex_thr, [0, 1.e-8]);
            %%}
        end
    end

end
