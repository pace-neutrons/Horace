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
        old_ws
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
            obj.old_ws = warning('off','HORACE:old_file_format');
        end
        function delete(obj)
            warning(obj.old_ws);
        end
        %------------------------------------------------------------------
        % tests
        %
        %
        function test_fb_operations_pattern(obj)
            tf = fullfile(tmp_dir,'test_fb_operations_pattern.sqw');
            clObF = onCleanup(@()delete(tf));
            if is_file(tf)
                delete(tf);
            end
            assertFalse(is_file(tf));

            clOnConf = set_temporary_warning('off','HORACE:old_file_format');

            ref_sqw = read_sqw(obj.sample_file);
            ref_sqw.data.s = ref_sqw.data.s*2; % do sample modification

            clobConf = set_temporary_config_options(hor_config, 'mem_chunk_size', 1000, 'fb_scale_factor', 3);

            % ensure filebacked operations for tests. Interface is generic
            assertTrue(PixelDataBase.do_filebacked(ref_sqw.npixels))
            % copy source to target. May be implemented in internal copy operation
            source = sqw(obj.sample_file);
            targ_fac = sqw_formats_factory.instance().get_pref_access('sqw');
            targ_fac = targ_fac.init(source,tf);
            targ_fac = targ_fac.put_sqw('-nopix');
            % Get access to pixels.
            pix = source.pix;
            pix_pos = 1;
            data_range = PixelDataBase.EMPTY_RANGE;
            for i=1:pix.num_pages
                pix.page_num = i;
                % this may be operation specific, depending on we want
                % access to pixel class or not. For speed, in any case may
                % be beneficial to do pix_h = PixelDataMemory();
                % pix_h.data = pix.get_pixels('-raw_data');
                %
                pix_data = pix.get_pixels('-keep_precision','-raw_data');
                % Transform pixels according to requested operation here
                % and do appropriate image averages. E.g.
                %pix_data(8,:) = 2*pix_data(8,:); % Operations with PixelData class may be beneficial

                % calculate ranges:
                loc_range = [min(pix_data,[],2),max(pix_data,[],2)]';
                data_range = minmax_ranges(data_range,loc_range);
                %
                % store result
                targ_fac = targ_fac.put_raw_pix(pix_data,pix_pos);
                pix_pos = pix_pos + size(pix_data,2);
            end
            pix.full_filename = targ_fac.full_filename; % this is questionable. What if the file is renamed?
            pix.data_range = data_range;
            targ_fac = targ_fac.put_pix_metadata(pix);
            % modify accumulated signal and error.
            data = targ_fac.sqw_holder.data;
            data.s = 2*data.s; % test modifications, equivalent to image averages
            % add modified data to file accessor
            % Store modified dnd data
            targ_fac = targ_fac.put_dnd_data(data);
            % complete io operations and finalize target file
            targ_fac.delete();

            % check result
            assertTrue(is_file(tf));
            res_sqw = read_sqw(tf);

            assertEqual(res_sqw.pix.full_filename,tf);
            % this actually spurious, data range have not changed
            assertEqual(res_sqw.pix.data_range,data_range);

            assertEqualToTol(ref_sqw,res_sqw,1.e-12,'ignore_str',true)
            %
            res_sqw.pix = [];
            clear res_sqw; % try to delete memmapfile to be able to delete
            % test file
        end
        function obj = test_save_load_sqwV4_crossbuf(obj)
            clob1 = set_temporary_config_options(hor_config, 'mem_chunk_size', 1000);

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
            assertTrue(is_file(tf))
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

        function test_upgrdate_v2_to_v4_filebacked(obj)
            tf = fullfile(tmp_dir,'test_upgrade_v2tov4_fb.sqw');
            clObF = onCleanup(@()file_delete(tf));
            copyfile(obj.old_origin,tf,'f');
            clobW = set_temporary_warning('off','HOR_CONFIG:set_mem_chunk_size');

            ldr = sqw_formats_factory.instance().get_loader(tf);
            w_old = ldr.get_sqw('-ver');
            %------------ Now the test setting and test

            % 4324 pixels, let's ensure pixels in file are treated as filebacked
            clobConf = set_temporary_config_options(hor_config, 'mem_chunk_size', 500, 'fb_scale_factor', 3);

            assertTrue(PixelDataBase.do_filebacked(4324));

            fac = ldr.upgrade_file_format(tf);
            ldr.delete();

            assertEqual(fac.faccess_version,4.0)
            assertEqual(fac.npixels,uint64(4324))
            assertEqual(fac.num_contrib_files,109);

            w_new = fac.get_sqw('-ver');
            fac.delete();

            assertEqualToTol(w_old,w_new,1.e-12,'-ignore_date','ignore_str',true)

            fac1 = sqw_formats_factory.instance().get_loader(tf);
            assertEqual(fac1.faccess_version,4.0)
            w_new_new = fac1.get_sqw('-ver');
            fac1.delete();
            assertEqualToTol(w_new,w_new_new)
            % Cut projection is recovered correctly
            eq_cut = w_new_new.cut(w_new_new.data.proj,[],[],[],[]);
            assertEqualToTol(eq_cut,w_new_new,1.e-7,'-ignore_date', 'ignore_str', true);
            % do clean-up as pixels hold access to the file, which can not
            % be deleted as memmapfile holds it
            w_new.pix = [];
            w_new_new.pix = [];
            clear w_new;
            clear w_new_new;
        end

        function test_upgrdate_v2_to_v4_membased(obj)
            tf = fullfile(tmp_dir,'test_upgrade_v2tov4_mem.sqw');
            clOb = onCleanup(@()delete(tf));
            copyfile(obj.old_origin,tf,'f');
            ldr = sqw_formats_factory.instance().get_loader(tf);
            w_old = ldr.get_sqw('-ver');

            % ensure we are testing memory backed update
            assertFalse(PixelDataBase.do_filebacked(4324));
            fac = ldr.upgrade_file_format(tf);
            ldr.delete();

            assertEqual(fac.faccess_version,4.0)
            assertEqual(fac.npixels,uint64(4324))
            assertEqual(fac.num_contrib_files,109);
            w_new = fac.get_sqw('-ver');
            fac.delete();

            assertEqualToTol(w_old,w_new,1.e-12,'-ignore_date')

            fac1 = sqw_formats_factory.instance().get_loader(tf);
            assertEqual(fac1.faccess_version,4.0)
            w_new_new = fac1.get_sqw('-ver');
            fac1.delete();
            assertEqualToTol(w_new,w_new_new)
        end
        function test_init_and_get(obj)
            to = faccess_sqw_v4();

            [ok,initobj] = to.should_load(obj.sample_file);
            assertTrue(ok);
            assertTrue(initobj.file_id>0);

            to = to.init(initobj);
            assertEqual(to.npixels,uint64(4324));
            assertEqual(to.num_contrib_files,109);

            mheader = to.get_main_header('-keep_');
            assertEqual(numel(mheader.title),0);
            assertEqual(mheader.filename,'faccess_sqw_v4_sample.sqw');
            assertEqual(mheader.filepath,...
                'C:\Temp\Horace_4.0.0.342a84a5a');
            assertEqual(mheader.creation_date,'2023-07-20T17:41:29')

            [exp_info,~] = to.get_exp_info('-all');

            assertTrue(isa(exp_info,'Experiment'));
            inf = exp_info.expdata(2);
            assertEqual(inf.filename,'map11015.spe;1')
            assertElementsAlmostEqual(inf.psi,-0.0087,'absolute',1.e-4);

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
            assertEqual(data_dnd.filename,'faccess_sqw_v4_sample.sqw');

            data = to.get_data('-ver');
            assertEqual(data.filename,data_dnd.filename)
            assertEqual(data.filepath,data_dnd.filepath)

            pix = to.get_pix();
            assertTrue(isa(pix, 'PixelDataBase'));
            assertEqual(pix.full_filename, obj.sample_file);
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
            clob0 = set_temporary_warning('off','SQW_FILE_IO:legacy_data');

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
        function test_serialize_deserialize_faccess(obj)
            fo = faccess_sqw_v4();
            fo = fo.init(obj.sample_file);

            by = fo.serialize();
            fr = serializable.deserialize(by);

            assertEqual(fo,fr);
        end
        %
        function test_serialize_deserialize_empty_faccess(~)
            fo = faccess_sqw_v4();

            bys = fo.to_struct();
            forb = serializable.from_struct(bys);
            assertEqual(fo,forb);

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
            clob_for_tf1 = onCleanup(@()file_delete(targ_file));

            wrt =sqw_formats_factory.instance.get_pref_access(sample_obj);
            wrt = wrt.init(sample_obj,targ_file);

            % test file has been stored with name test_name.
            wrt.put_sqw();
            test_name_2 = 'test_wrong_file_name_activated_2.sqw';
            targ_file_2 = fullfile(tmp_dir(),test_name_2);
            wrt.delete();
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
        function obj = test_write_read_correctV4_filebacked(obj)

            clobC = set_temporary_config_options(hor_config, 'mem_chunk_size', 1000, 'fb_scale_factor', 3);

            samp_f = obj.sample_file;
            assertTrue(PixelDataBase.do_filebacked(4000))
            so = faccess_sqw_v4(samp_f);
            sqw_ob = so.get_sqw();
            % new sqw file
            assertTrue(sqw_ob.main_header.creation_date_defined);
            assertTrue(isa(sqw_ob,'sqw'));


            tf = fullfile(tmp_dir,'write_read_correctV4_filebacked.sqw');
            clobF = onCleanup(@()file_delete(tf));

            tob = faccess_sqw_v4();
            tob = tob.init(sqw_ob,tf);

            tob=tob.put_sqw();
            tob = tob.delete();
            so.delete();

            assertTrue(exist(tf,'file')==2)

            tob=tob.init(tf);
            ver_obj =tob.get_sqw('-verbatim');
            tob.delete();

            assertEqualToTol(sqw_ob,ver_obj,1.e-12,'ignore_str',true);
            clear ver_obj; % need to delete memmapfile associated with tf.
        end

        function test_write_read_correctV4_membased(obj)
            assertFalse(PixelDataBase.do_filebacked(4000))

            fac0 = faccess_sqw_v4(obj.sample_file);
            sample = fac0.get_sqw('-verbatim');


            test_f = fullfile(tmp_dir,'write_read_sample_correct.sqw');
            clOb = onCleanup(@()file_delete(test_f));
            wo = faccess_sqw_v4(sample,test_f);
            wo = wo.put_sqw();
            wo.delete();
            assertEqual(exist(test_f,'file'),2)

            ro = faccess_sqw_v4(test_f);
            rdd = ro.get_sqw('-verbatim');
            wo.delete();

            assertEqualToTol(sample,rdd,'ignore_str',true)
        end
        function test_get_set_pix_metadata(obj)

            test_f = fullfile(tmp_dir,'set_get_pix_metadata.sqw');
            copyfile(obj.sample_file,test_f,'f');
            clOb = onCleanup(@()file_delete(test_f));

            fac0 = faccess_sqw_v4(test_f);
            meta = fac0.get_pix_metadata();

            assertFalse(meta.is_misaligned)
            ref_range = meta.data_range;
            empty_range = ref_range  == PixelDataBase.EMPTY_RANGE;
            assertTrue(~any(empty_range(:)));
            ref_range(2,end) = 2*ref_range(2,end);
            alignment_mat = rotvec_to_rotmat2(rand(1,3));
            meta.alignment_matr = alignment_mat;
            meta.data_range = ref_range;

            fac0 = fac0.reopen_to_write();
            fac0 = fac0.put_pix_metadata(meta);
            fac0.delete();

            fac1 = faccess_sqw_v4(test_f);
            meta = fac1.get_pix_metadata();
            assertTrue(meta.is_misaligned)
            fac1.delete();

            assertElementsAlmostEqual(meta.alignment_matr,alignment_mat);
            assertElementsAlmostEqual(meta.data_range(:,4:end),ref_range(:,4:end));

        end
        %         function test_build_correct(obj)
        %             % TEST used in preparation of first v4 sample file and
        %             % is not testing
        %             % any other functionality. Left for references
        %             sample = read_sqw(obj.old_origin,'-verbatim');
        %             %fac0 = faccess_sqw_v4(obj.sample_file);
        %             %sample = fac0.get_sqw('-verbatim');
        %
        %             test_f = fullfile(tmp_dir,'faccess_sqw_v4_sample.sqw');
        %             wo = faccess_sqw_v4(sample,test_f);
        %             wo = wo.put_sqw();
        %             wo.delete();
        %             assertEqual(exist(test_f,'file'),2)
        %
        %             ro = faccess_sqw_v4(test_f);
        %             rdd = ro.get_sqw('-verbatim');
        %             ro.delete();
        %
        %             assertEqualToTol(sample,rdd)
        %         end

        function test_read_correct(obj)
            sample = read_sqw(obj.old_origin);

            to = faccess_sqw_v4(obj.sample_file);

            rdd = to.get_sqw();
            to.delete();
            % projection in sample contains w==[0,0,1], type='ppp' and projection
            % in rdd contains w == [], type='rrr'. Let's check both are
            % equivalent
            pix_cc = [eye(3),ones(3,1)];
            pr = rdd.data.proj.transform_pix_to_img(pix_cc);
            po = sample.data.proj.transform_pix_to_img(pix_cc);

            assertElementsAlmostEqual(pr,po);
            % as they are equivalent, let's eliminate one for comparison to
            % work
            sample.data.proj = rdd.data.proj;

            assertEqualToTol(sample,rdd,1.e-15,'-ignore_date','ignore_str',true)
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
