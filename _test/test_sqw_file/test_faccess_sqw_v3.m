classdef test_faccess_sqw_v3< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    %


    properties
        sample_dir;
        sample_file;
    end

    methods

        %The above can now be read into the test routine directly.
        function this=test_faccess_sqw_v3(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this=this@TestCase(name);

            this.sample_dir = fullfile(fileparts(mfilename('fullpath')));
            this.sample_file = fullfile(this.sample_dir,'test_sqw_file_read_write_v3_1.sqw');

        end

        % tests
        function obj = test_should_load_stream(obj)
            to = faccess_sqw_v3();
            assertEqual(to.faccess_version,3.1);
            co = onCleanup(@()to.delete());


            [stream,fid] = to.get_file_header(obj.sample_file);
            [ok,initobj] = to.should_load_stream(stream,fid);
            co1 = onCleanup(@()fclose(initobj.file_id));
            assertTrue(ok);
            assertTrue(initobj.file_id>0);

        end
        %
        function obj = test_should_load_file(obj)
            to = faccess_sqw_v3();
            co = onCleanup(@()to.delete());

            [ok,initobj] = to.should_load(obj.sample_file);
            co1 = onCleanup(@()fclose(initobj.file_id));

            assertTrue(ok);
            assertTrue(initobj.file_id>0);

        end
        function obj = test_save_load_sqwV31_crossbuf(obj)
            clob1 = set_temporary_config_options(hor_config, 'mem_chunk_size', 1000);
            clObW = set_temporary_warning('off','HORACE:old_file_format');

            samp_f = fullfile(obj.sample_dir,...
                'test_sqw_file_read_write_v3_1.sqw');

            so = faccess_sqw_v3(samp_f);
            sqw_ob = so.get_sqw();
            % old sqw file
            assertFalse(sqw_ob.main_header.creation_date_defined);

            assertTrue(isa(sqw_ob,'sqw'));

            inst1=create_test_instrument(95,250,'s');
            hdr = sqw_ob.experiment_info;
            hdr.instruments{1} = inst1;
            sqw_ob = sqw_ob.change_header(hdr);

            tf = fullfile(tmp_dir,'test_save_load_sqwV31.sqw');
            clob = onCleanup(@()file_delete(tf));

            tob = faccess_sqw_v3();
            tob = tob.init(sqw_ob,tf);

            tob=tob.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tob = tob.delete();

            tob=tob.init(tf);
            ver_obj =tob.get_sqw('-verbatim');
            tob.delete();
            assertTrue(ver_obj.main_header.creation_date_defined);

            assertTrue(sqw_ob.experiment_info.runid_recalculated);
            assertFalse(ver_obj.experiment_info.runid_recalculated);

            ver_obj.experiment_info.runid_recalculated = true;
            assertEqualToTol(sqw_ob,ver_obj,1.e-7,'-ignore_date','ignore_str',true);
        end

        %
        function obj = test_init_and_get(obj)
            to = faccess_sqw_v3();

            [ok,initobj] = to.should_load(obj.sample_file);
            assertTrue(ok);
            assertTrue(initobj.file_id>0);

            to = to.init(initobj);
            assertEqual(to.npixels,7680);
            assertEqual(to.num_contrib_files,1);

            mheader = to.get_main_header('-keep_');
            assertEqual(numel(mheader.title),0);
            assertEqual(mheader.filename,'test_sqw_file_read_write_v3.sqw');
            assertEqual(mheader.filepath,...
                'd:\Users\abuts\Data\ExcitDev\ISIS_svn\Hor#162\_test\test_sqw_file\');

            [exp_info,~] = to.get_exp_info();

            assertEqual(exp_info.runid_map.keys(),{1})
            assertEqual(exp_info.runid_map.values(),{1})

            assertTrue(isa(exp_info,'Experiment'));
            inf = exp_info.expdata(1);
            assertEqual(inf.filename,'')
            assertElementsAlmostEqual(inf.psi,0.2967,'absolute',1.e-4);
            assertEqual(inf.ulabel{4},'E')
            assertEqual(inf.ulabel{3},'Q_\eta')

            det = to.get_detpar();
            assertEqual(det.filename,'')
            assertEqual(det.filepath,'.\')
            assertEqual(numel(det.group),96)

            data = to.get_data();
            assertEqual(size(data.s,1),numel(data.p{1})-1)
            assertEqual(size(data.e,2),numel(data.p{2})-1)
            assertEqual(size(data.npix,3),numel(data.p{3})-1)

            pix  = to.get_pix();
            assertEqual(pix.num_pixels,7680)
        end
        %
        function obj = test_get_data(obj)
            to = faccess_sqw_v3(obj.sample_file);

            data_h = to.get_data('-he');
            assertTrue(isstruct(data_h))
            assertEqual(data_h.filename,to.filename)
            assertEqual(data_h.filepath,to.filepath)

            data_dnd = to.get_data('-verb');
            assertTrue(isa(data_dnd,'DnDBase'));
            assertEqual(data_dnd.filename,'test_sqw_file_read_write_v3.sqw');

            data = to.get_data('-ver');
            assertEqual(data.filename,data_dnd.filename)
            assertEqual(data.filepath,data_dnd.filepath)

            pix = to.get_pix();
            assertTrue(isa(pix, 'PixelDataBase'));
            assertEqual(pix.full_filename, obj.sample_file);
            assertEqual(pix.num_pixels, 7680);

            raw_pix = to.get_raw_pix(1,20);
            assertEqual(pix.get_pixels(1:20).data, raw_pix);
        end
        %
        function obj = test_get_inst_or_sample(obj)
            to = faccess_sqw_v3();
            to = to.init(obj.sample_file);

            inst = to.get_instrument('-all');
            samp = to.get_sample();
            assertTrue(isa(samp,'IX_sample'));

            inst1 = to.get_instrument(1);
            assertEqual(inst{1},inst1);
        end
        %
        function obj = test_get_sqw(obj)

            fo = faccess_sqw_v3();
            fo = fo.init(obj.sample_file);

            sqw_obj = fo.get_sqw();

            assertTrue(isa(sqw_obj,'sqw'));
            assertEqual(sqw_obj.main_header.filename,fo.filename)
            assertEqual(sqw_obj.main_header.filepath,[fo.filepath,filesep])

            sqw_obj1 = fo.get_sqw('-hverbatim');
            assertTrue(isa(sqw_obj1,'sqw'));
            assertEqual(sqw_obj1.main_header.filename,'test_sqw_file_read_write_v3.sqw')
            assertEqual(sqw_obj1.main_header.filepath,...
                'd:\Users\abuts\Data\ExcitDev\ISIS_svn\Hor#162\_test\test_sqw_file\')
        end
        %
        function test_save_sqw2to3(obj)
            samp_f = fullfile(obj.sample_dir,...
                'test_sqw_file_read_write_v3.sqw');
            clob0 = set_temporary_warning('off','SQW_FILE_IO:legacy_data');

            so = faccess_sqw_v2(samp_f);
            sqw_ob = so.get_sqw();

            assertTrue(isa(sqw_ob,'sqw'));
            % Create sample
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            sam1.alatt=[4 5 6];
            sam1.angdeg=[91 92 93];
            %inst1=create_test_instrument(95,250,'s');
            %sqw_ob.header(1).instrument = inst1;
            hdr = sqw_ob.experiment_info;
            hdr.samples{1} = sam1;
            sqw_ob = sqw_ob.change_header(hdr);

            tob = faccess_sqw_v3();
            tob = tob.init(sqw_ob);

            tf = fullfile(tmp_dir,'test_save_load_sqwV31.sqw');
            clob = onCleanup(@()file_delete(tf));

            tob = tob.set_file_to_update(tf);
            tob=tob.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tob=tob.delete();

            tob=tob.init(tf);
            assertEqual(tob.faccess_version,3.1);
        end
        %
        function obj = test_save_load_sqwV31(obj)
            samp_f = fullfile(obj.sample_dir,...
                'test_sqw_file_read_write_v3_1.sqw');

            so = faccess_sqw_v3(samp_f);
            sqw_ob = so.get_sqw();

            assertTrue(isa(sqw_ob,'sqw'));
            % old sqw object contains incorrect runid map.
            % This map shoudl be recalculated to maintain consistence
            % betweem pixels_id and headers
            assertTrue(sqw_ob.experiment_info.runid_recalculated)

            inst1=create_test_instrument(95,250,'s');
            hdr = sqw_ob.experiment_info;
            hdr.instruments{1} = inst1;
            sqw_ob = sqw_ob.change_header(hdr);

            tf = fullfile(tmp_dir,'test_save_load_sqwV31.sqw');
            clob = onCleanup(@()file_delete(tf));

            tob = faccess_sqw_v3();
            tob = tob.init(sqw_ob,tf);

            tob=tob.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tob = tob.delete();

            tob=tob.init(tf);
            ver_obj =tob.get_sqw('-verbatim');
            tob.delete();
            % newly stored object contains updated runid map which should
            % not be recalculated
            assertFalse(ver_obj.experiment_info.runid_recalculated)

            ver_obj.experiment_info.runid_recalculated = true;
            assertEqualToTol(sqw_ob,ver_obj,1.e-7,'ignore_str',true,'-ignore_date');
        end
        %
        %
        function test_save_sqwV3toV2(obj)
            samp_f = fullfile(obj.sample_dir,...
                'test_sqw_file_read_write_v3_1.sqw');

            so = faccess_sqw_v3(samp_f);
            sqw_ob = so.get_sqw();

            assertTrue(isa(sqw_ob,'sqw'));

            tf = fullfile(tmp_dir,'test_save_sqwV3toV2.sqw');
            clob = onCleanup(@()file_delete(tf));

            tob = faccess_sqw_v3(sqw_ob);
            tob = tob.set_file_to_update(tf);
            try
                tob=tob.put_sqw('-v2');
            catch er
                assertEqual(er.identifier,'FACCESS_SQW_V3:runtime_error')
            end

            assertTrue(exist(tf,'file')==2)

            tob1=faccess_sqw_v2(tf);
            assertEqual(tob1.faccess_version,2);
            % this may fail in furute versions of the code as delete was
            % invoked over tob
            assertEqual(tob.npixels,tob1.npixels);
            assertEqual(tob.pix_position,tob1.pix_position);
            assertEqual(tob.data_position,tob1.data_position);
            assertEqual(tob.npix_position,tob1.npix_position);
            tob1.delete();
        end
        %
        function test_serialize_deserialize_faccess(obj)
            fo = faccess_sqw_v3();
            fo = fo.init(obj.sample_file);

            by = hlp_serialize(fo);
            fr = hlp_deserialize(by);

            assertEqual(fo,fr);
        end
        %
        function test_wrong_file_name_activated(obj)
            ld = sqw_formats_factory.instance.get_loader(obj.sample_file);
            sample_obj = ld.get_sqw();

            test_name = 'test_wrong_file_name_activated_1.sqw';
            targ_file = fullfile(tmp_dir(),test_name);

            wrt =sqw_formats_factory.instance.get_pref_access(sample_obj);
            wrt = wrt.init(sample_obj,targ_file);

            % test file has been stored with name test_name.
            wrt.put_sqw();
            test_name_2 = 'test_wrong_file_name_activated_2.sqw';
            targ_file_2 = fullfile(tmp_dir(),test_name_2);
            wrt.delete();
            clob_for_tf1 = onCleanup(@()file_delete(targ_file));
            copyfile(targ_file,targ_file_2);
            clob_for_tf2 = onCleanup(@()file_delete(targ_file_2));

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
            clob = onCleanup(@()file_delete(targ_file));

            fo = faccess_sqw_v3();
            fo = fo.init(targ_file);
            assertEqual(fo.filename,test_name);
            assertEqual([fo.filepath,filesep],tmp_dir());
            fo.delete();
        end

        %% get_pix_at_indices
        function test_get_pix_at_indices_returns_pixels_at_given_indices(obj)
            faccess = faccess_sqw_v3(obj.sample_file);
            pix_indices = [4:6, 100:104, 7679:7680];

            % we trust .get_pix, which is tested elsewhere, to load in the full
            % range
            raw_pix_full = faccess.get_raw_pix(1, faccess.npixels);

            raw_pix = faccess.get_pix_at_indices(pix_indices);
            expected_pix = raw_pix_full(:, pix_indices);

            assertEqualToTol(raw_pix, expected_pix, 5e-4);
        end

        function test_get_pix_at_indices_raises_if_reading_pix_out_of_range(obj)
            faccess = faccess_sqw_v3(obj.sample_file);
            pix_indices = [4:6, 100:104, 7679:7681];
            f = @() faccess.get_pix_at_indices(pix_indices);
            assertExceptionThrown(f, 'SQW_BINFILE_COMMON:get_pix_at_indices');
        end

        %% get_pix_in_ranges
        function test_get_pix_in_ranges_returns_pixels_in_given_ranges(obj)
            faccess = faccess_sqw_v3(obj.sample_file);
            pix_starts = [4, 100, 7679];
            pix_ends = [6, 104, 7680];
            block_sizes = pix_ends -pix_starts+1;
            pix_indices = [4:6, 100:104, 7679:7680];

            % we trust .get_pix, which is tested elsewhere, to load in the full
            % range
            raw_pix_full = faccess.get_raw_pix(1, faccess.npixels);

            raw_pix = faccess.get_pix_in_ranges(pix_starts, block_sizes);
            expected_pix = raw_pix_full(:, pix_indices);

            assertEqualToTol(raw_pix, expected_pix, 5e-4);
        end

        function test_get_pix_in_ranges_errors_if_any_starts_gt_ends(obj)
            faccess = faccess_sqw_v3(obj.sample_file);
            pix_starts = [4, 52, 7679];
            pix_ends = [6, 49, 7680];  % note 52 > 49
            bl_sizes = pix_ends-pix_starts+1;

            f = @() faccess.get_pix_in_ranges(pix_starts, bl_sizes);
            assertExceptionThrown(f, 'HORACE:validate_ranges:invalid_argument');
        end

        function test_get_pix_in_ranges_can_handle_out_of_order_ranges(obj)
            faccess = faccess_sqw_v3(obj.sample_file);
            pix_starts = [4, 7679, 100];
            pix_ends = [6, 7680, 104];
            pix_indices = [4:6, 7679:7680, 100:104];
            bl_sizes = pix_ends-pix_starts+1;


            % we trust .get_pix, which is tested elsewhere, to load in the full
            % range
            raw_pix_full = faccess.get_raw_pix(1, faccess.npixels);

            raw_pix = faccess.get_pix_in_ranges(pix_starts, bl_sizes);
            expected_pix = raw_pix_full(:, pix_indices);

            assertEqualToTol(raw_pix, expected_pix, 5e-4);
        end

        function test_get_pix_in_ranges_can_handle_overlapping_ranges(obj)
            faccess = faccess_sqw_v3(obj.sample_file);
            pix_starts = [4, 7679, 10];
            pix_ends = [20, 7680, 24];
            pix_indices = [4:20, 7679:7680, 10:24];
            bl_sizes = pix_ends-pix_starts+1;


            % we trust .get_pix, which is tested elsewhere, to load in the full
            % range
            raw_pix_full = faccess.get_raw_pix(1, faccess.npixels);

            raw_pix = faccess.get_pix_in_ranges(pix_starts, bl_sizes);
            expected_pix = raw_pix_full(:, pix_indices);

            assertEqualToTol(raw_pix, expected_pix, 5e-4);
        end

        function test_get_pix_in_ranges_raises_if_index_arrays_ne_size(obj)
            faccess = faccess_sqw_v3(obj.sample_file);
            pix_starts = [1, 3, 5, 7];
            bl_sizes = [2, 4, 6];

            f = @() faccess.get_pix_in_ranges(pix_starts, bl_sizes);
            assertExceptionThrown(f, 'HORACE:validate_ranges:invalid_argument');
        end
    end
end
