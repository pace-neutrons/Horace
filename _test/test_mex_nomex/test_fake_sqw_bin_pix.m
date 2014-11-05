classdef test_fake_sqw_bin_pix < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        tmp_data_folder;
        skip_this_test=false;
        current_mex_state;
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
            
            hc.use_mex = 0;
            fake_sqw(en, par_file, sqw_file_single, efix, emode, alatt, angdeg,...
                u, v, psi, omega, dpsi, gl, gs);
            
            w_nomex=read_sqw(sqw_file_single);
            
            % can not compare pixel arrays as pixel sorting will be
            % different. Compare the whole image instead
            w_mex = d4d(w_mex);
            w_nomex = d4d(w_nomex);
            [ok,mess]=equal_to_tol(w_mex,w_nomex,-1.e-8);
            assertTrue(ok,[' MEX and non-mex versions of gen_sqw are different: ',mess]);
        end
        
    end
end