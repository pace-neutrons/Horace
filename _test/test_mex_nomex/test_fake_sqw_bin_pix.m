classdef test_fake_sqw_bin_pix < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        tmp_data_folder;
        skip_this_test=false;
        current_mex_state;
        current_thread_state;
        sample_dir;
    end
    
    methods
        function this=test_fake_sqw_bin_pix(varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_fake_sqw_bin_pix';
            end
            this = this@TestCase(name);
            
            this.skip_this_test = false;
            hc = hor_config;
            this.current_mex_state =hc.use_mex;
            this.current_thread_state = hc.threads;
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',this.current_mex_state));
            
            hc.use_mex = 1;
            if hc.use_mex ~= 1
                this.skip_this_test= true;
            end
            this.tmp_data_folder = tempdir;
            root_dir = fileparts(which('horace_init.m'));
            this.sample_dir = fullfile(root_dir,'_test','common_data');
        end
        function test_bin_c(this)
            if this.skip_this_test
                warning('TEST_FAKE_SQW_BIN_PIX:test_bin_c','skipping this test as mex files are not enabled');
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',this.current_mex_state));
            
            
            en=-80:8:760;
            par_file=fullfile(this.sample_dir,'map_4to1_dec09.par');
            sqw_file_single=fullfile(this.tmp_data_folder,'test_fake_sqw_bin_pix.sqw');
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
            fake_sqw(en, par_file, sqw_file_single, efix, emode, alatt, angdeg,...
                u, v, psi, omega, dpsi, gl, gs);
            
            w_mex=read_sqw(sqw_file_single);
            
            
            n_det_out = sum(w_mex.data.pix(6,:)<1 | w_mex.data.pix(6,:)>36864);
            assertEqual(0,n_det_out,'found detectors with ID-s outp of the range allowed');
            
            n_en_zeros = sum(w_mex.data.pix(7,:)==0);
            assertEqual(0,n_en_zeros,'en bin id can not be equal to 0');
            
            
            hc.use_mex = 0;
            fake_sqw(en, par_file, sqw_file_single, efix, emode, alatt, angdeg,...
                u, v, psi, omega, dpsi, gl, gs);
            
            w_nomex=read_sqw(sqw_file_single);
            n_det_out = sum(w_nomex.data.pix(6,:)<1 | w_nomex.data.pix(6,:)>36864);
            assertEqual(0,n_det_out,'found detectors with ID-s outp of the range allowed');
            n_en_zeros = sum(w_nomex.data.pix(7,:)==0);
            assertEqual(0,n_en_zeros,'en bin id can not be equal to 0');
            
            
            % can not compare pixel arrays as pixel sorting will be
            % different. Compare the whole image instead
            w_mex = d4d(w_mex);
            w_nomex = d4d(w_nomex);
            [ok,mess]=equal_to_tol(w_mex,w_nomex,-1.e-8);
            assertTrue(ok,[' MEX and non-mex versions of gen_sqw are different: ',mess]);
        end
        function test_bin_c_multithread(this)
            if this.skip_this_test
                warning('TEST_FAKE_SQW_BIN_PIX:test_bin_c','skipping this test as mex files are not enabled');
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',this.current_mex_state,'threads',this.current_thread_state));
            
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
            
            sqw_file_single=fullfile(this.tmp_data_folder,'test_bin_c_multithread_fake_sqw.sqw');
            cleanup_files=onCleanup(@()delete(sqw_file_single));
            
            hc=hor_config;
            %
            hc.use_mex = 1;
            hc.threads = 1;
            %
            fake_sqw(en, par_file, sqw_file_single, efix, emode, alatt, angdeg,...
                u, v, psi, omega, dpsi, gl, gs);
            
            w_mex=read_sqw(sqw_file_single);
            
            
            n_det_out = sum(w_mex.data.pix(6,:)<1 | w_mex.data.pix(6,:)>96);
            assertEqual(0,n_det_out,'found detectors with ID-s outp of the range allowed');
            
            n_en_zeros = sum(w_mex.data.pix(7,:)==0);
            assertEqual(0,n_en_zeros,'en bin id can not be equal to 0');
            
            %
            hc.use_mex = 1;
            hc.threads = 8;
            %
            fake_sqw(en, par_file, sqw_file_single, efix, emode, alatt, angdeg,...
                u, v, psi, omega, dpsi, gl, gs);
            
            w_mex_thr=read_sqw(sqw_file_single);
            n_det_out = sum(w_mex_thr.data.pix(6,:)<1 | w_mex_thr.data.pix(6,:)>96);
            assertEqual(0,n_det_out,'found detectors with ID-s outp of the range allowed');
            n_en_zeros = sum(w_mex_thr.data.pix(7,:)==0);
            assertEqual(0,n_en_zeros,'en bin id can not be equal to 0');
            
            % can not compare pixel arrays as pixel sorting will be
            % different. Compare the whole image instead
            w_mex = d4d(w_mex);
            w_mex_thr = d4d(w_mex_thr);
            [ok,mess]=equal_to_tol(w_mex,w_mex_thr,-1.e-8);
            assertTrue(ok,[' MEX threaded and non-threaded versions of gen_sqw are different: ',mess]);
        end
        
        
        
    end
    
end
