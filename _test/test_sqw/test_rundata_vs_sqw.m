classdef test_rundata_vs_sqw < TestCaseWithSave & common_state_holder
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
            this_folder = fileparts(mfilename('fullpath'));
            ref_data = fullfile(fileparts(this_folder),'common_data','rundata_vs_sqw_refdata.mat');
            this = this@TestCaseWithSave(name,ref_data);
            %
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

        function obj=test_build_rundata_from_sqw_keeps_lattice_and_detectors(obj)

            rd = rundatah(obj.sqw_obj);

            assertEqual(rd.emode, obj.emode);
            assertEqual(rd.efix, obj.efix);

            lattice = rd.lattice;
            assertElementsAlmostEqual(lattice.alatt,obj.alatt,'absolute',2e-7);
            assertElementsAlmostEqual(lattice.angdeg,obj.angdeg);
            assertEqual(lattice.u,obj.u);
            assertEqual(lattice.v,obj.v);
            assertElementsAlmostEqual(lattice.psi,obj.psi,'absolute',2e-7);
            assertElementsAlmostEqual(lattice.omega,obj.omega,'absolute',2e-7);
            assertElementsAlmostEqual(lattice.dpsi,obj.dpsi,'absolute',2e-7);
            assertElementsAlmostEqual(lattice.gl,obj.gl,'absolute',2e-7);
            assertElementsAlmostEqual(lattice.gs,obj.gs,'absolute',2e-7);

            det = get_par(obj.par_file);
            det_par = rd.det_par;
            %
            assertElementsAlmostEqual(det_par.azim,det.azim,'absolute',7.7e-6);
            assertElementsAlmostEqual(det_par.group,det.group,'absolute',1.e-12);
            assertElementsAlmostEqual(det_par.height,det.height,'absolute',1.e-9);
            assertElementsAlmostEqual(det_par.phi,det.phi,'absolute',2.e-6);
            assertElementsAlmostEqual(det_par.width,det.width,'absolute',2.e-6);
            assertElementsAlmostEqual(det_par.x2,det.x2,'absolute',2.e-6);
            assertEqual(det_par.filename,det.filename)
        end
        %
        function obj=test_build_rundata(obj)
            rd = rundatah(obj.sqw_obj);

            grid_size = size(obj.sqw_obj.data.s);
            img_range    = obj.sqw_obj.data.img_range;

            sqw_rev = rd.calc_sqw(grid_size,img_range);

            lattice = rd.lattice;
            proj = struct('u',lattice.u,'v',lattice.v);

            [ok,mess]=is_cut_equal(obj.sqw_obj,sqw_rev,proj,0.04*(img_range(2,1)-img_range(1,1)),0.1*(img_range(2,2)-img_range(1,2)),[-Inf,Inf],[-Inf,Inf]);
            assertTrue(ok, ...
                sprintf('The cut from direct sqw obj and sqw->rundata->sqw converted obj are not the same:\n %s\n', ...
                mess));
            assertEqualToTol(obj.sqw_obj,sqw_rev,'tol',[1.e-12,1.e-12]);
        end
        function test_bounding_object_provides_correct_img_range(obj)
            rd = rundatah(obj.sqw_obj);

            grid_size = size(obj.sqw_obj.data.s);
            img_range    = obj.sqw_obj.data.img_range;

            % calculate bounding object surrounding existing data object
            bob = rd.build_bounding_obj();
            bos = bob.calc_sqw(grid_size,img_range);
            assertElementsAlmostEqual(bos.data.img_range,img_range,'relative',1.e-6);

            pix_range =[min(bos.data.pix.coordinates,[],2)'; max(bos.data.pix.coordinates,[],2)'];
            assertElementsAlmostEqual(bos.data.img_range,pix_range,'relative',1.e-6);
        end
        %
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
        %
        function sqw_build = rd_convert_checker(~,rundata_to_test,grid_size,img_db_range)
            % function used in test_serialize_deserialize_rundatah_with_op
            % test to ensure that imput parameters of the serialized function
            % are not picked up from the same variables subspace;
            sqw_build  = rundata_to_test.calc_sqw(grid_size,img_db_range);
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
            img_db_range = obj.sqw_obj.data.img_range;

            sqw_o = rd.calc_sqw(grid_size,img_db_range);
            sqw_r = obj.rd_convert_checker(fa,grid_size,img_db_range);

            assertEqual(sqw_o,sqw_r);

        end
        %
        function test_rundata_sqw(obj)
            test_file = fullfile(horace_root(),...
                '_test','common_data','MAP11014.nxspe');
            ds = struct('alatt',[2.63,2.63,2.63],'angdeg',[90,90,90],...
                'u',[1,0,0],'v',[0,1,0]);

            rd = rundatah(test_file,ds);
            rd = rd.load();

            hc = hor_config;
            dts = hc.get_data_to_store();
            clob = onCleanup(@()set(hc,dts));
            hc.use_mex = false;
            hc.ignore_nan = true;

            [sq4,grid,pix_range] = rd.calc_sqw();
            assertEqual(grid,[50,50,50,50]);
            ref_range = [0.0576   -6.6475   -6.6475    2.5000;...
                3.8615    6.6475    6.6475  147.5000];
            assertElementsAlmostEqual(pix_range,ref_range,'relative',3.e-4);
            assertEqualToTolWithSave(obj,sq4,'ignore_str',true,'tol',1.e-7);

            rdr = rundatah(sq4);
            assertEqualToTol(rdr.saveobj(),rd.saveobj(),'ignore_str',true,'tol',1.e-7);

        end
        %
        function test_rundata_mex_nomex(~)
            test_file = fullfile(horace_root(),...
                '_test','common_data','MAP11014.nxspe');
            ds = struct('alatt',[2.63,2.63,2.63],'angdeg',[97,60,80],...
                'u',[1,0,0],'v',[0,1,0]);

            rd = rundatah(test_file,ds);
            rd = rd.load();
            hc = hor_config;
            dts = hc.get_data_to_store();
            clob = onCleanup(@()set(hc,dts));

            hc.use_mex = true;
            [sq4_mex,grid_mex,pix_range_mex] = rd.calc_sqw();
            hc.use_mex = false;
            [sq4_nom,grid_nom,pix_range_nom] = rd.calc_sqw();

            assertEqual(grid_mex,grid_nom);
            assertEqual(pix_range_mex,pix_range_nom);

            assertElementsAlmostEqual(sort(sq4_mex.data.pix.data'),...
                sort(sq4_nom.data.pix.data'));
            % Binning here is substantially different. TODO: decrease the
            % differebce
            assertEqual(sq4_nom.data.pix.pix_range,sq4_mex.data.pix.pix_range);
        end
    end
end
