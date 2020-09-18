classdef test_rundata_vs_sqw < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        out_dir=tmp_dir();
        % use intermediate sqw file to store test data (slower but tests IO
        % as well)
        save_file = false;
        
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
        
        sqw_obj=[];
        clob_ = [];
    end
    methods(Static)
        function rm_sqw(filename)
            if exist(filename,'file')
                delete(filename);
            end
        end
        
    end
    
    methods
        function this=test_rundata_vs_sqw(varargin)
            if nargin==0
                name = 'test_rundata_vs_sqw';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
            root_dir = horace_root();
            data_dir = fullfile(root_dir,'_test','common_data');
            this.sqw_file_single = fullfile(this.out_dir,this.sqw_file_single);
            this.par_file = fullfile(data_dir,this.par_file);
            if this.save_file
                fn =this.sqw_file_single;
                this.clob_ = onCleanup(@()this.rm_sqw(fn));
                
                if ~exist(this.sqw_file_single,'file')
                    fake_sqw(this.en, this.par_file, this.sqw_file_single, this.efix,...
                        this.emode, this.alatt, this.angdeg,...
                        this.u, this.v, this.psi, this.omega, this.dpsi, this.gl, this.gs,...
                        [10,5,5,5]);
                end
                this.sqw_obj = read_sqw(this.sqw_file_single);
                
            else
                this.sqw_obj = fake_sqw(this.en, this.par_file, '', this.efix,...
                    this.emode, this.alatt, this.angdeg,...
                    this.u, this.v, this.psi, this.omega, this.dpsi, this.gl, this.gs,...
                    [10,5,5,5]);
                this.sqw_obj = this.sqw_obj{1};
            end
            
            
            
        end
        
        function this=test_build_rundata(this)
            
            rd = rundatah(this.sqw_obj);
            
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
            %assertEqual(det_par.filepath,det.filepath)
            %assertEqual(det_par,det);
            grid_size = size(this.sqw_obj.data.s);
            urange    = this.sqw_obj.data.urange;
            % somewhere on the way, pixels become single precision, so...
            urange(1,:) = urange(1,:)*(1+2.e-7);
            urange(2,:) = urange(2,:)*(1+2.e-7);
            
            sqw_rev = rd.calc_sqw(grid_size,urange);
            
            proj = struct('u',lattice.u,'v',lattice.v);
            [ok,mess]=is_cut_equal(this.sqw_obj,sqw_rev,proj,0.04*(urange(2,1)-urange(1,1)),0.1*(urange(2,2)-urange(1,2)),[-Inf,Inf],[-Inf,Inf]);
            assertTrue(ok,['Combining cuts from each individual sqw file and the cut from the combined sqw file not the same ',mess]);
            %assertEqual(this.sqw_obj,sqw_rev);
            
            % calculate bounding object surrounding existing data object
            bob = rd.build_bounding_obj();
            bos = bob.calc_sqw(grid_size,urange);
            assertElementsAlmostEqual(bos.data.urange,urange,'relative',1.e-6);
            
            pix_range =[min(bos.data.pix.coordinates,[],2)'; max(bos.data.pix.coordinates,[],2)'];
            assertElementsAlmostEqual(bos.data.urange,pix_range);
        end
        
        function  this=test_serialize_deserialize_rundatah(this)
            rd = rundatah(this.sqw_obj);
            
            by = rd.serialize();
            
            fa = rundatah.deserialize(by);
            [~,fa] = fa.get_par;
            assertTrue(isa(fa,'rundatah'));
            [ok,mess]=equal_to_tol(rd.S,fa.S);
            assertTrue(ok,mess);
            [ok,mess]=equal_to_tol(rd.det_par,fa.det_par,1.e-4);
            assertTrue(ok,mess);
            rd = rd.unload();
            fa = fa.unload();
            assertEqual(rd,fa);
        end
        function sqw_build = rd_convert_checker(~,rundata_to_test,grid_size,urange)
            % function used in test_serialize_deserialize_rundatah_with_op
            % test to ensure that imput parameters of the serialized function
            % are not picked up from the same variables subspace;
            sqw_build  = rundata_to_test.calc_sqw(grid_size,urange);
        end
        %
        function  test_serialize_deserialize_rundatah_with_op(obj)
            % test checks if transofrmation is serialized/recovered correctly.
            rd = rundatah(obj.sqw_obj);
            v1=[0,1,0]; v2=[0,0,1]; v3=[0,0,0];
            rd.transform_sqw = @(x)symmetrise_sqw(x,v1,v2,v3);
            
            by = rd.serialize();
            
            fa = rundatah.deserialize(by);
            
            grid_size = size(obj.sqw_obj.data.s);
            urange = obj.sqw_obj.data.urange;
            
            sqw_o = rd.calc_sqw(grid_size,urange);
            sqw_r = obj.rd_convert_checker(fa,grid_size,urange);
            
            assertEqual(sqw_o,sqw_r);
            
        end
        
        %
        function obj = test_send_receive_rundata(obj)
            
        end
    end
end
