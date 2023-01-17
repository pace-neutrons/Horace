classdef test_faccess_sqw_v4< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    %


    properties
        old_origin
        sample_dir;
        sample_file;
    end

    methods

        %The above can now be read into the test routine directly.
        function obj=test_faccess_sqw_v4(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            obj=obj@TestCase(name);

            % sqw
            obj.sample_dir = fileparts(mfilename('fullpath'));
            obj.sample_file = fullfile(obj.sample_dir,'faccess_sqw_v4_sample.sqw');
            hp = horace_paths;

            obj.old_origin = fullfile(hp.test_common,'sqw_1d_2.sqw');
        end
        %------------------------------------------------------------------
        % tests
        %
        %
        function obj = test_init_and_get(obj)
            to = faccess_sqw_v4();

            [ok,initobj] = to.should_load(obj.sample_file);
            assertTrue(ok);
            assertTrue(initobj.file_id>0);

            to = to.init(initobj);
            assertEqual(to.npixels,4324);
            assertEqual(to.num_contrib_files,109);

            mheader = to.get_main_header('-keep_');
            assertEqual(numel(mheader.title),0);
            assertEqual(mheader.filename,'Fe_ei787.sqw');
            assertEqual(mheader.filepath,...
                'c:\data\Fe\sqw\');
            assertEqual(mheader.creation_date,'2023-01-16T23:14:44')

            [exp_info,~] = to.get_exp_info('-all');

            assertTrue(isa(exp_info,'Experiment'));
            inf = exp_info.expdata(2);
            assertEqual(inf.filename,'map11015.spe;1')
            assertElementsAlmostEqual(inf.psi,-0.0087,'absolute',1.e-4);
            assertEqual(inf.ulabel{4},'E')
            assertEqual(inf.ulabel{3},'Q_\eta')

            det = to.get_detpar();
            assertEqual(det.filename,'9cards_4_4to1.par')
            assertEqual(det.filepath,'c:\data\Fe\')
            assertEqual(numel(det.group),36864)

            data = to.get_data();
            assertEqual(size(data.s,1),numel(data.axes.p{1})-1)
            assertEqual(size(data.npix,1),numel(data.axes.p{1})-1)

            pix  = to.get_pix();
            assertEqual(pix.num_pixels,4324)
        end
        %
        function obj = test_get_data(obj)
            to = faccess_sqw_v4(obj.sample_file);

            data_h = to.get_data('-he');
            assertTrue(isstruct(data_h))
            assertEqual(data_h.filename,to.filename)
            assertEqual(data_h.filepath,to.filepath)

            data_dnd = to.get_dnd('-verb');
            assertTrue(isa(data_dnd,'DnDBase'));
            assertEqual(data_dnd.filename,'Fe_ei787.sqw');

            data = to.get_data('-ver');
            assertEqual(data.filename,data_dnd.filename)
            assertEqual(data.filepath,data_dnd.filepath)

            pix = to.get_pix();
            assertTrue(isa(pix, 'PixelDataBase'));
            assertEqual(pix.file_path, obj.sample_file);
            assertEqual(pix.num_pixels, 4324);

            raw_pix = to.get_raw_pix(1,20);
            assertEqual(pix.get_pixels(1:20).data, raw_pix);
        end
        %
        function obj = test_get_set_inst_or_sample(obj)
            tf = fullfile(tmp_dir,'test_save_load_sqwV4.sqw');
            clob = onCleanup(@()delete(tf));
            copyfile(obj.sample_file,tf,'f');

            to = faccess_sqw_v4(tf,'-update');
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            sam1.alatt=[4 5 6];
            sam1.angdeg=[91 92 93];
            inst1=create_test_instrument(95,250,'s');

            to = to.put_instruments(inst1);
            to = to.put_samples(sam1);

            exi = to.get_exp_info('-all');
            to.delete();

            assertEqual(exi.instruments(1),inst1);
            assertEqual(exi.samples(1),sam1);
        end

        function obj = test_get_inst_or_sample(obj)
            to = faccess_sqw_v4();
            to = to.init(obj.sample_file);

            inst = to.get_instrument('-all');
            samp = to.get_sample();
            assertTrue(isa(samp,'IX_samp'));

            inst1 = to.get_instrument(1);
            assertEqual(inst{1},inst1);
        end

        %
        function test_read_sqwV2_save_sqwV4(obj)
            samp_f = fullfile(obj.sample_dir,...
                'test_sqw_file_read_write_v3.sqw');
            warning('off','SQW_FILE_IO:legacy_data');
            clob0 = onCleanup(@()warning('on','SQW_FILE_IO:legacy_data'));

            so = faccess_sqw_v2(samp_f);
            sqw_ob = so.get_sqw();

            assertTrue(isa(sqw_ob,'sqw'));
            % Create sample
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            sam1.alatt=[4 5 6];
            sam1.angdeg=[91 92 93];
            inst1=create_test_instrument(95,250,'s');
            sqw_ob.experiment_info.instruments = inst1;
            hdr = sqw_ob.experiment_info;
            hdr.samples{1} = sam1;
            sqw_ob = sqw_ob.change_header(hdr);

            tob = faccess_sqw_v4();
            tob = tob.init(sqw_ob);

            tf = fullfile(tmp_dir,'test_save_load_sqwV4.sqw');
            clob = onCleanup(@()delete(tf));

            tob = tob.set_file_to_update(tf);
            tob=tob.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tob=tob.delete();

            tob=tob.init(tf);
            assertEqual(tob.faccess_version,4);
            tob.delete();
        end
        %
        function obj = test_save_load_sqwV4_filebacked(obj)
            %
            skipTest('#893 wating for filebacked completeon')
            hc    = hor_config;
            mchs  = hc.mem_chunk_size;
            hc.mem_chunk_size = 1000;
            clob1 = onCleanup(@()set(hor_config,'mem_chunk_size',mchs));

            samp_f = obj.sample_file;

            so = faccess_sqw_v4(samp_f);
            sqw_ob = so.get_sqw();
            % new sqw file
            assertTrue(sqw_ob.main_header.creation_date_defined);
            assertTrue(isa(sqw_ob,'sqw'));

            inst1=create_test_instrument(95,250,'s');
            hdr = sqw_ob.experiment_info;
            hdr.instruments{1} = inst1;
            sqw_ob = sqw_ob.change_header(hdr);

            tf = fullfile(tmp_dir,'test_save_load_sqwV4.sqw');
            clob = onCleanup(@()delete(tf));

            tob = faccess_sqw_v4();
            tob = tob.init(sqw_ob,tf);

            tob=tob.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tob = tob.delete();

            tob=tob.init(tf);
            ver_obj =tob.get_sqw('-verbatim');
            tob.delete();

            assertTrue(ver_obj.main_header.creation_date_defined);
            assertEqual(sqw_ob.main_header,ver_obj.main_header);

            assertTrue(sqw_ob.experiment_info.runid_recalculated);
            assertFalse(ver_obj.experiment_info.runid_recalculated);

            ver_obj.experiment_info.runid_recalculated = true;
            assertEqualToTol(sqw_ob,ver_obj,1.e-7);
        end
        %
        %
        function test_serialize_deserialise_faccess(obj)
            fo = faccess_sqw_v4();
            fo = fo.init(obj.sample_file);

            by = fo.serialize();
            fr = serializable.deserialize(by);

            assertEqual(fo,fr);
        end
        %
        function test_wrong_file_name_activated(obj)
            ld = sqw_formats_factory.instance.get_loader(obj.sample_file);
            sample_obj = ld.get_sqw();

            test_name = 'test_wrong_file_name_activated_1.sqw';
            targ_file = fullfile(tmp_dir(),test_name);
            clob_for_tf1 = onCleanup(@()delete(targ_file));

            wrt =sqw_formats_factory.instance.get_pref_access(sample_obj);
            wrt = wrt.init(sample_obj,targ_file);

            % test file has been stored with name test_name.
            wrt.put_sqw();
            test_name_2 = 'test_wrong_file_name_activated_2.sqw';
            targ_file_2 = fullfile(tmp_dir(),test_name_2);
            wrt.delete();
            copyfile(targ_file,targ_file_2);
            clob_for_tf2 = onCleanup(@()delete(targ_file_2));

            % test file has been recovered with the name test_name_2.
            ld = sqw_formats_factory.instance.get_loader(targ_file_2);
            assertEqual(ld.filename,test_name_2);
            assertEqual([ld.filepath,filesep],tmp_dir());
            ld.delete();
        end
        %
        function test_correct_file_activated(obj)
            test_name = 'test_correct_activation.sqw';
            targ_file = fullfile(tmp_dir(),test_name);
            copyfile(obj.sample_file,targ_file);
            clob = onCleanup(@()delete(targ_file));

            fo = faccess_sqw_v4();
            fo = fo.init(targ_file);
            assertEqual(fo.filename,test_name);
            assertEqual([fo.filepath,filesep],tmp_dir());
            fo.delete();
        end

        %% get_pix_at_indices
        function test_get_pix_at_indices_returns_pixels_at_given_indices(obj)
            faccess = faccess_sqw_v4(obj.sample_file);
            pix_indices = [4:6, 100:104, 4323:4324];

            % we trust .get_pix, which is tested elsewhere, to load in the full
            % range
            raw_pix_full = faccess.get_raw_pix(1, faccess.npixels);

            raw_pix = faccess.get_pix_at_indices(pix_indices);
            expected_pix = raw_pix_full(:, pix_indices);

            assertEqualToTol(raw_pix, expected_pix, 5e-4);
        end

        function test_get_pix_at_indices_raises_if_reading_pix_out_of_range(obj)
            faccess = faccess_sqw_v4(obj.sample_file);
            pix_indices = [4:6, 100:104, 4323:4325];
            f = @() faccess.get_pix_at_indices(pix_indices);
            assertExceptionThrown(f, 'HORACE:validate_ranges:invalid_argument');
        end

        %% get_pix_in_ranges
        function test_get_pix_in_ranges_returns_pixels_in_given_ranges(obj)
            faccess = faccess_sqw_v4(obj.sample_file);
            pix_starts = [4, 100, 4323];
            pix_ends = [6, 104, 4324];
            block_sizes = pix_ends -pix_starts+1;
            pix_indices = [4:6, 100:104, 4323:4324];

            % we trust .get_pix, which is tested elsewhere, to load in the full
            % range
            raw_pix_full = faccess.get_raw_pix(1, faccess.npixels);

            raw_pix = faccess.get_pix_in_ranges(pix_starts, block_sizes);
            expected_pix = raw_pix_full(:, pix_indices);

            assertEqualToTol(raw_pix, expected_pix, 5e-4);
        end

        function test_get_pix_in_ranges_errors_if_any_starts_gt_ends(obj)
            faccess = faccess_sqw_v4(obj.sample_file);
            pix_starts = [4, 52, 4323];
            pix_ends = [6, 49, 4324];  % note 52 > 49
            bl_sizes = pix_ends-pix_starts+1;

            f = @() faccess.get_pix_in_ranges(pix_starts, bl_sizes);
            assertExceptionThrown(f, 'HORACE:validate_ranges:invalid_argument');
        end

        function test_get_pix_in_ranges_can_handle_out_of_order_ranges(obj)
            faccess = faccess_sqw_v4(obj.sample_file);
            pix_starts = [4, 4323, 100];
            pix_ends = [6, 4324, 104];
            pix_indices = [4:6, 4323:4324, 100:104];
            bl_sizes = pix_ends-pix_starts+1;


            % we trust .get_pix, which is tested elsewhere, to load in the full
            % range
            raw_pix_full = faccess.get_raw_pix(1, faccess.npixels);

            raw_pix = faccess.get_pix_in_ranges(pix_starts, bl_sizes);
            expected_pix = raw_pix_full(:, pix_indices);

            assertEqualToTol(raw_pix, expected_pix, 5e-4);
        end

        function test_get_pix_in_ranges_can_handle_overlapping_ranges(obj)
            faccess = faccess_sqw_v4(obj.sample_file);
            pix_starts = [4, 4000, 10];
            pix_ends = [20, 4010, 24];
            pix_indices = [4:20, 4000:4010, 10:24];
            bl_sizes = pix_ends-pix_starts+1;


            % we trust .get_pix, which is tested elsewhere, to load in the full
            % range
            raw_pix_full = faccess.get_raw_pix(1, faccess.npixels);

            raw_pix = faccess.get_pix_in_ranges(pix_starts, bl_sizes);
            expected_pix = raw_pix_full(:, pix_indices);

            assertEqualToTol(raw_pix, expected_pix, 5e-4);
        end

        function test_get_pix_in_ranges_raises_if_index_arrays_ne_size(obj)
            faccess = faccess_sqw_v4(obj.sample_file);
            pix_starts = [1, 3, 5, 7];
            bl_sizes = [2, 4, 6];

            f = @() faccess.get_pix_in_ranges(pix_starts, bl_sizes);
            assertExceptionThrown(f, 'HORACE:validate_ranges:invalid_argument');
        end

        function test_write_read_correct(obj)
            fac0 = faccess_sqw_v4(obj.sample_file);
            sample = fac0.get_sqw('-verbatim');

            test_f = fullfile(tmp_dir,'write_read_sample_correct.sqw');
            clOb = onCleanup(@()delete(test_f));
            wo = faccess_sqw_v4(sample,test_f);
            wo = wo.put_sqw();
            wo.delete();
            assertEqual(exist(test_f,'file'),2)

            ro = faccess_sqw_v4(test_f);
            rdd = ro.get_sqw('-verbatim');
            wo.delete();

            assertEqualToTol(sample,rdd)
        end
        function test_read_correct(obj)
            sample = read_sqw(obj.old_origin);

            to = faccess_sqw_v4(obj.sample_file);

            rdd = to.get_sqw();
            to.delete();

            assertEqualToTol(sample,rdd,1.e-20,'-ignore_date','ignore_str',true)
        end
        function test_should_load_file(obj)
            to = faccess_sqw_v4();
            co = onCleanup(@()to.delete());

            [ok,initobj] = to.should_load(obj.sample_file);
            co1 = onCleanup(@()fclose(initobj.file_id));

            assertTrue(ok);
            assertTrue(initobj.file_id>0);

        end

        function test_should_load_stream(obj)
            to = faccess_sqw_v4();
            assertEqual(to.faccess_version,4.0);
            co = onCleanup(@()to.delete());


            [stream,fid] = to.get_file_header(obj.sample_file);
            [ok,initobj] = to.should_load_stream(stream,fid);
            co1 = onCleanup(@()fclose(initobj.file_id));
            assertTrue(ok);
            assertTrue(initobj.file_id>0);

        end

    end
end
