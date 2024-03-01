classdef test_data_block < TestCase
    properties
        sqw_obj_for_tests;
    end

    methods
        function obj = test_data_block(varargin)
            if nargin == 0
                name = varargin{1};
            else
                name = 'test_data_block';
            end
            obj = obj@TestCase(name);
            hc = horace_paths;
            en = -1:1:50;
            par_file = fullfile(hc.test_common,'gen_sqw_96dets.nxspe');
            fsqw = dummy_sqw (en, par_file, '', 51, 1,[2.8,3.86,4.86], [120,80,90],...
                [1,0,0],[0,1,0], 10, 1.,0.1, -0.1, 0.1, [10,20,25,15]);
            sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
            fsqw = fsqw{1};
            sample.alatt = [4.2240 4.2240 4.2240];
            sample.angdeg = [90 90 90];
            inst = maps_instrument(90,250,'s');
            fsqw.experiment_info.samples = sample;
            fsqw.experiment_info.instruments = inst;
            obj.sqw_obj_for_tests = fsqw;
        end
        function file_deleter(~,fid,file)
            fn = fopen(fid);
            if ~isempty(fn)
                fclose(fid);
            end
            delete(file);
        end
        function test_pix_data_block_from_to_bat_rec(~)
            pdb = pix_data_block(10,1000);
            assertEqual(pdb.block_name,'bl_pix_data_wrap');
            assertEqual(pdb.npixels,uint64(1000))
            assertEqual(pdb.size,uint64(12+9*4*1000))

            batr_array = pdb.bat_record();
            assertEqual(numel(batr_array),pdb.bat_record_size);

            pdb_rec = data_block.deserialize_bat_record(batr_array);

            assertEqual(pdb,pdb_rec);
        end
        
        function test_pix_data_block_ser_deser(~)
            pdb = pix_data_block(10,1000,12);
            assertEqual(pdb.block_name,'bl_pix_data_wrap');
            assertEqual(pdb.npixels,uint64(1000))
            assertEqual(pdb.size,uint64(12+12*4*1000))

            pdb_struc = pdb.to_struct();
            pdb_rec = serializable.from_struct(pdb_struc);

            assertEqual(pdb,pdb_rec);
        end
        function test_pix_data_block_size_params(~)
            pdb = pix_data_block;
            assertEqual(pdb.sqw_prop_name,'pix')
            assertEqual(pdb.level2_prop_name,'data_wrap')
            pdb.npixels = 100;
            assertEqual(pdb.npixels,uint64(100))
            assertEqual(pdb.size,uint64(12+4*9*100))

            pdb.n_rows = 10;
            assertEqual(pdb.n_rows,10);
            assertEqual(pdb.npixels,uint64(100))
            assertEqual(pdb.size,uint64(12+4*10*100))

        end

        function test_set_size_pix_data_block_size(~)
            pdb = pix_data_block;
            assertEqual(pdb.sqw_prop_name,'pix')
            assertEqual(pdb.level2_prop_name,'data_wrap')
            pdb.size = 12+4*9*100;
            assertEqual(pdb.npixels,uint64(100))
            assertEqual(pdb.position,uint64(0))
            assertEqual(pdb.size,uint64(12+4*9*100))
            assertEqual(pdb.num_pix_position,uint64(4))
            assertEqual(pdb.pix_position,uint64(12))
            assertEqual(pdb.n_rows,9)
        end

        function test_npix_pix_data_block_size(~)
            pdb = pix_data_block;
            assertEqual(pdb.sqw_prop_name,'pix')
            assertEqual(pdb.level2_prop_name,'data_wrap')
            pdb.npixels = 100;
            assertEqual(pdb.npixels,uint64(100))
            assertEqual(pdb.position,uint64(0))
            assertEqual(pdb.size,uint64(12+4*9*100))
            assertEqual(pdb.num_pix_position,uint64(4))
            assertEqual(pdb.pix_position,uint64(12))
            assertEqual(pdb.n_rows,9)
        end

        function test_empty_pix_data_block_size(~)
            pdb = pix_data_block;
            assertEqual(pdb.sqw_prop_name,'pix')
            assertEqual(pdb.level2_prop_name,'data_wrap')
            assertEqual(pdb.npixels,'undefined')
            assertEqual(pdb.position,uint64(0))
            assertEqual(pdb.size,uint64(12))
            assertEqual(pdb.num_pix_position,uint64(4))
            assertEqual(pdb.pix_position,uint64(12))
            assertEqual(pdb.n_rows,9)
        end

        function test_put_get_dnd_info_reverted(obj)
            dp1 = dnd_data_block();
            dp2 = data_block('data','metadata');

            file = fullfile(tmp_dir(),'put_get_dnd_data_block_reverted.bin');
            fid = fopen(file,'wb+');
            clOb = onCleanup(@()file_deleter(obj,fid,file));

            tob = obj.sqw_obj_for_tests;
            npixels = tob.pix.num_pixels;
            nbins = numel(tob.data.s);
            idx = floor(1+(nbins-1)*rand(npixels,1));
            sig = zeros(size(tob.data.s));
            err = ones(size(tob.data.s));
            npix = zeros(size(tob.data.s));

            sig(idx) = 10;
            err(idx) = 20;
            npix(idx) = 1;
            tob.data.s = sig;
            tob.data.e = err;
            tob.data.npix = npix;


            dp1 = dp1.put_sqw_block(fid,tob);
            dp2.position = dp1.size;
            dp2 = dp2.put_sqw_block(fid,tob);

            tob.data = [];

            [~,rec_obj] = dp1.get_sqw_block(fid,tob);
            [~,rec_obj] = dp2.get_sqw_block(fid,rec_obj);
            fclose(fid);

            rec_obj.data.do_check_combo_arg = true;
            try
                rec_obj.data  = rec_obj.data.check_combo_arg();
                check_failed = false;
                ME = struct('message','');
            catch ME
                check_failed  = true;
            end
            assertFalse(check_failed,ME.message);

            tob = obj.sqw_obj_for_tests;
            tob.data.s = sig;
            tob.data.e = err;
            tob.data.npix = npix;

            assertEqualToTol(tob,rec_obj,1.e-12);
        end

        function test_dnd_block_bat_record_serialize_deserialize(~)
            db = dnd_data_block(10,10000);

            db_size = db.bat_record_size;
            bat_record = db.bat_record;
            assertEqual(db_size,numel(bat_record));

            [db_recovered,pos] = data_block.deserialize_bat_record(bat_record);

            assertEqual(db,db_recovered);
            assertEqual(pos,db_size+1);
        end

        function test_data_block_bat_record_serialize_deserialize(~)
            db = data_block('my_sqw','my_property',10,10000);

            db_size = db.bat_record_size;
            bat_record = db.bat_record;
            assertEqual(db_size,numel(bat_record));

            [db_recovered,pos] = data_block.deserialize_bat_record(bat_record);

            assertEqual(db,db_recovered);
            assertEqual(pos,db_size+1);
        end

        function test_put_get_dnd_info(obj)
            dp1 = data_block('data','metadata');
            dp2 = dnd_data_block();

            file = fullfile(tmp_dir(),'put_get_dnd_data_block.bin');
            fid = fopen(file,'wb+');
            clOb = onCleanup(@()file_deleter(obj,fid,file));

            tob = obj.sqw_obj_for_tests;
            npixels = tob.pix.num_pixels;
            nbins = numel(tob.data.s);
            idx = floor(1+(nbins-1)*rand(npixels,1));
            sig = zeros(size(tob.data.s));
            err = ones(size(tob.data.s));
            npix = zeros(size(tob.data.s));

            sig(idx) = 10;
            err(idx) = 20;
            npix(idx) = 1;
            tob.data.s = sig;
            tob.data.e = err;
            tob.data.npix = npix;

            dp1 = dp1.put_sqw_block(fid,tob);
            dp2.position = dp1.size;
            dp2 = dp2.put_sqw_block(fid,tob);

            tob.data = [];

            [~,rec_obj] = dp1.get_sqw_block(fid,tob);
            [~,rec_obj] = dp2.get_sqw_block(fid,rec_obj);
            fclose(fid);

            rec_obj.data.do_check_combo_arg = true;
            try
                rec_obj.data  = rec_obj.data.check_combo_arg();
                check_failed = false;
                ME = struct('message','');
            catch ME
                check_failed  = true;
            end
            assertFalse(check_failed,ME.message);

            tob = obj.sqw_obj_for_tests;
            tob.data.s = sig;
            tob.data.e = err;
            tob.data.npix = npix;

            assertEqualToTol(tob,rec_obj,1.e-12);
        end

        function test_put_get_two_data_blocks(obj)
            dp1 = data_block('experiment_info','samples');
            dp2 = data_block('experiment_info','instruments');

            file = fullfile(tmp_dir(),'put_get_sqw_block.bin');
            fid = sqw_fopen(file,'wb+');
            clOb = onCleanup(@()file_deleter(obj,fid,file));

            tob = obj.sqw_obj_for_tests;
            dp1 = dp1.put_sqw_block(fid,tob);
            dp2.position = dp1.size;
            dp2 = dp2.put_sqw_block(fid,tob);
            
            %{
            DISABLE test section as this experiment_info has 1 run so
            setting empty instruments is not allowed
            tob.experiment_info.instruments = [];
            clWarn = set_temporary_warning('off','HORACE:Experiment:lattice_changed');
            tob.experiment_info.samples = [];
            [~,rec_obj] = dp1.get_sqw_block(fid,tob);
            [~,rec_obj] = dp2.get_sqw_block(fid,rec_obj);

            assertEqual(obj.sqw_obj_for_tests,rec_obj);
            %}
            fclose(fid);

        end

        function test_put_get_sqw_block(obj)
            dp = data_block('experiment_info','instruments');

            file = fullfile(tmp_dir(),'put_get_sqw_block.bin');
            fid = sqw_fopen(file,'wb+');
            clOb = onCleanup(@()file_deleter(obj,fid,file));

            tob = obj.sqw_obj_for_tests;
            dp = dp.put_sqw_block(fid,tob);

            %{
            DISABLE test section.
            There is one run in this experiment info so removing the
            instruments container is not allowed.
            tob.experiment_info.instruments = [];
            [~,rec_obj] = dp.get_sqw_block(fid,tob);

            assertEqual(obj.sqw_obj_for_tests,rec_obj);
            %}
            fclose(fid);

        end
        %------------------------------------------------------------------
        function test_get_set_proper_dnd_subobj_proj(obj)
            dp = data_block('data','proj');

            proj = line_proj([1,1,0],[1,-1,0]);
            dnd_mod = dp.set_subobj(obj.sqw_obj_for_tests.data,proj);
            assertEqual(dnd_mod.proj,proj);
        end
        function test_get_set_proper_subobj_proj(obj)
            dp = data_block('data','proj');

            proj = line_proj([1,1,0],[1,-1,0]);
            sqw_mod = dp.set_subobj(obj.sqw_obj_for_tests.data,proj);

            assertEqual(sqw_mod.proj,proj);
        end
        function test_get_set_proper_subobj_instr(obj)
            dp = data_block('experiment_info','instruments');

            inst = IX_null_inst();
            sqw_mod = dp.set_subobj(obj.sqw_obj_for_tests,inst);

            assertEqual(sqw_mod.experiment_info.instruments(1),inst);
        end
    end
    % TESTING common data blocks and how they restore its contents from 
    % sqw object tree. 
    methods
        %------------------------------------------------------------------
        function test_get_block_name(~)
            dp = data_block('data','proj');

            assertEqual(dp.block_name,'bl_data_proj');
        end

        function test_get_proper_dnd_subobj_proj(obj)
            dp = data_block('data','proj');

            subobj = dp.get_subobj(obj.sqw_obj_for_tests.data);
            assertEqual(obj.sqw_obj_for_tests.data.proj,subobj);
        end
        function test_get_proper_subobj_proj(obj)
            dp = data_block('data','proj');

            subobj = dp.get_subobj(obj.sqw_obj_for_tests);
            assertEqual(obj.sqw_obj_for_tests.data.proj,subobj);
        end
        function test_get_proper_subobj_instr(obj)
            dp = data_block('experiment_info','instruments');

            subobj = dp.get_subobj(obj.sqw_obj_for_tests);
            assertEqual(obj.sqw_obj_for_tests.experiment_info.instruments,subobj);
        end

    end

end
