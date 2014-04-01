classdef test_build_rundata_from_sqw < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        out_dir=tempdir();
        
        en=-80:8:760;
        par_file='map_4to1_dec09.par';
        sqw_file_single='test_build_rundata_from_sqw.sqw';
        efix=800;
        emode=1;
        alatt=[2.87,2.87,2.87];
        angdeg=[90,90,90];
        u=[1,0,0];
        v=[0,1,0];
        omega=1;dpsi=2;gl=3;gs=4;
        
        psi=4;
        
        sqw_obj;
    end
    
    methods
        function this=test_build_rundata_from_sqw (name)
            this = this@TestCase(name);
            root_dir = fileparts(which('horace_init.m'));
            data_dir = fullfile(root_dir,'_test','common_data');
            this.sqw_file_single = fullfile(this.out_dir,this.sqw_file_single);
            this.par_file = fullfile(data_dir,this.par_file);
            
            fake_sqw(this.en, this.par_file, this.sqw_file_single, this.efix,...
                this.emode, this.alatt, this.angdeg,...
                this.u, this.v, this.psi, this.omega, this.dpsi, this.gl, this.gs);
            
            this.sqw_obj = read_sqw(this.sqw_file_single);
            delete(this.sqw_file_single);
        end
        
        function this=test_build_rundata(this)
            
            
            rd = rundata(this.sqw_obj);
            
            assertEqual(rd.emode, this.emode);
            assertEqual(rd.efix, this.efix);
            
            lattice = rd.lattice;
            assertElementsAlmostEqual(lattice.alatt,this.alatt,'absolute',2e-7);
            assertElementsAlmostEqual(lattice.angdeg,this.angdeg);
            assertEqual(lattice.u,this.u);
            assertEqual(lattice.v,this.v);
            assertElementsAlmostEqual(lattice.psi,this.psi,'absolute',2e-7);
            assertElementsAlmostEqual(lattice.omega,this.omega,'absolute',2e-7);
            assertElementsAlmostEqual(lattice.dpsi,this.dpsi,'absolute',2e-7);
            assertElementsAlmostEqual(lattice.gl,this.gl,'absolute',2e-7);
            assertElementsAlmostEqual(lattice.gs,this.gs,'absolute',2e-7);
            
            det = get_par(this.par_file);
            det_par = rd.det_par;
            %
            assertElementsAlmostEqual(det_par.azim,det.azim,'absolute',7.7e-6);
            assertElementsAlmostEqual(det_par.group,det.group,'absolute',1.e-12);
            assertElementsAlmostEqual(det_par.height,det.height,'absolute',1.e-9);
            assertElementsAlmostEqual(det_par.phi,det.phi,'absolute',2.e-6);            
            assertElementsAlmostEqual(det_par.width,det.width,'absolute',2.e-6);                        
            assertElementsAlmostEqual(det_par.x2,det.x2,'absolute',2.e-6);                                    
            assertEqual(det_par.filename,det.filename)
            assertEqual(det_par.filepath,det.filepath)            
            %assertEqual(det_par,det);
            
        end
    end
end