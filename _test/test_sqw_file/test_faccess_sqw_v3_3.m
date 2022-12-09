classdef test_faccess_sqw_v3_3< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %

    properties
        sample_dir;
        sample_file;
    end

    methods

        %The above can now be read into the test routine directly.
        function this=test_faccess_sqw_v3_3(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this=this@TestCase(name);

            this.sample_dir = fullfile(fileparts(mfilename('fullpath')));
            this.sample_file = fullfile(this.sample_dir,'test_sqw_file_read_write_v3_3.sqw');

        end

        % tests
        function obj = test_should_load_stream(obj)
            file_accessor = faccess_sqw_v3_3();
            assertEqual(file_accessor.faccess_version,3.3);
            co = onCleanup(@()file_accessor.delete());


            [stream,fid] = file_accessor.get_file_header(obj.sample_file);
            [ok,initobj] = file_accessor.should_load_stream(stream,fid);
            co1 = onCleanup(@()fclose(initobj.file_id));
            assertTrue(ok);
            assertTrue(initobj.file_id>0);

        end
        %
        function obj = test_should_load_file(obj)
            file_accessor = faccess_sqw_v3_3();
            co = onCleanup(@()file_accessor.delete());

            [ok,initobj] = file_accessor.should_load(obj.sample_file);
            co1 = onCleanup(@()fclose(initobj.file_id));

            assertTrue(ok);
            assertTrue(initobj.file_id>0);

        end
        %
        function obj = test_init_and_get(obj)
            file_accessor = faccess_sqw_v3_3();

            [ok,initobj] = file_accessor.should_load(obj.sample_file);
            assertTrue(ok);
            assertTrue(initobj.file_id>0);


            file_accessor = file_accessor.init(initobj);
            assertEqual(file_accessor.npixels,7680);
            assertEqual(file_accessor.num_contrib_files,1);


            mheader = file_accessor.get_main_header('-keep');
            assertEqual(numel(mheader.title),0);
            assertEqual(mheader.filename,'test_sqw_file_read_write_v3.sqw');
            assertEqual(mheader.filepath,...
                'C:\Users\abuts\Documents\developing_soft\Horace\_test\test_sqw_file\');

            exp_info = file_accessor.get_exp_info();
            %exp_info = header.get_exp_info();
            assertTrue(isa(exp_info,'Experiment'));
            inf = exp_info.expdata(1);

            assertEqual(inf.filename,'')
            assertElementsAlmostEqual(inf.psi,0.2967,'absolute',1.e-4);
            assertEqual(inf.ulabel{4},'E')
            assertEqual(inf.ulabel{3},'Q_\eta')


            det = file_accessor.get_detpar();
            assertEqual(det.filename,'')
            assertEqual(det.filepath,'.\')
            assertEqual(numel(det.group),96)

            data = file_accessor.get_data();

            assertEqual(size(data.s,1),numel(data.p{1})-1)
            assertEqual(size(data.e,2),numel(data.p{2})-1)
            assertEqual(size(data.npix,3),numel(data.p{3})-1)

            pix = file_accessor.get_pix();
            assertEqual(pix.num_pixels,7680)            
        end
        %
        function obj = test_get_data(obj)
            file_accessor = faccess_sqw_v3_3(obj.sample_file);

            data_h = file_accessor.get_data('-he');
            assertTrue(isstruct(data_h))
            assertEqual(data_h.filename,file_accessor.filename)
            assertEqual(data_h.filepath,file_accessor.filepath)

            data_dnd = file_accessor.get_data('-verb');
            assertTrue(isa(data_dnd,'DnDBase'));
            assertEqual(data_dnd.filename,'test_sqw_file_read_write_v3.sqw');

            data = file_accessor.get_data('-ver');
            assertEqual(data.filename,data_dnd.filename)
            assertEqual(data.filepath,data_dnd.filepath)
            
            pix = file_accessor.get_pix();
            assertTrue(isa(pix, 'PixelData'));
            assertEqual(pix.file_path, obj.sample_file);
            assertEqual(pix.num_pixels, 7680);

            raw_pix = file_accessor.get_raw_pix(1,20);
            assertEqual(pix.get_pixels(1:20).data, raw_pix);
        end
        %
        function obj = test_get_inst_or_sample(obj)
            file_accessor = faccess_sqw_v3_3();
            file_accessor = file_accessor.init(obj.sample_file);

            inst = file_accessor.get_instrument('-all');
            samp = file_accessor.get_sample();
            assertTrue(isa(samp,'IX_sample'));

            inst1 = file_accessor.get_instrument(1);
            assertEqual(inst{1},inst1);
        end
        %
        function obj = test_get_sqw(obj)

            fo = faccess_sqw_v3_3();
            fo = fo.init(obj.sample_file);

            sqw_obj = fo.get_sqw();

            assertTrue(isa(sqw_obj,'sqw'));
            assertEqual(sqw_obj.main_header.filename,fo.filename)
            assertEqual(sqw_obj.main_header.filepath,[fo.filepath,filesep])

            sqw_obj1 = fo.get_sqw('-hverbatim');

            assertTrue(isa(sqw_obj1,'sqw'));
            assertEqual(sqw_obj1.main_header.filename,'test_sqw_file_read_write_v3.sqw')
            assertEqual(sqw_obj1.main_header.filepath,...
                'C:\Users\abuts\Documents\developing_soft\Horace\_test\test_sqw_file\')
        end
        %
        function test_save_sqw2to3_3(obj)
            samp_f = fullfile(obj.sample_dir,...
                'test_sqw_file_read_write_v3.sqw');
            warning('off','SQW_FILE_IO:legacy_data');
            clob0 = onCleanup(@()warning('on','SQW_FILE_IO:legacy_data'));

            so = faccess_sqw_v2(samp_f);
            sqw_ob = so.get_sqw();

            ref_range = sqw_ob.data.img_range;

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

            tob = faccess_sqw_v3_3();
            tob = tob.init(sqw_ob);

            tf = fullfile(tmp_dir,'test_save_load_sqwV33.sqw');
            clob = onCleanup(@()delete(tf));

            tob = tob.set_file_to_update(tf);
            tob=tob.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tob=tob.delete();

            tob=tob.init(tf);
            assertEqual(tob.faccess_version,3.3);
            img_db_range = tob.get_img_db_range();
            assertElementsAlmostEqual(ref_range,img_db_range)
            pix_range = tob.get_pix_range();
            assertElementsAlmostEqual(pix_range,img_db_range, ...
                'relative',5.e-6) % is this the accuracy of conversion from
            % double to single?
        end
        %
        function obj = test_save_load_sqwV3_3(obj)
            samp_f = fullfile(obj.sample_dir,...
                'test_sqw_file_read_write_v3_3.sqw');

            so = faccess_sqw_v3_3(samp_f);
            sqw_ob = so.get_sqw();
            assertFalse(sqw_ob.main_header.creation_date_defined);
            % old sqw object contains incorrect runid map.
            % This map should be recalculated to maintain consistence
            % between pixels_id and headers
            assertTrue(sqw_ob.experiment_info.runid_recalculated)

            ref_range = sqw_ob.data.img_range;

            assertTrue(isa(sqw_ob,'sqw'));

            inst1=create_test_instrument(95,250,'s');
            hdr = sqw_ob.experiment_info;
            hdr.instruments{1} = inst1;
            sqw_ob = sqw_ob.change_header(hdr);

            tf = fullfile(tmp_dir,'test_save_load_sqwV3_3.sqw');
            clob = onCleanup(@()delete(tf));

            tob = faccess_sqw_v3_3();
            tob = tob.init(sqw_ob,tf);

            tob=tob.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tob = tob.delete();

            tob=tob.init(tf);
            ver_obj =tob.get_sqw('-verbatim');
            assertTrue(ver_obj.main_header.creation_date_defined,...
                'Creation date is still undefined');
            tob.delete();
            % newly stored object contains updated runid map which should
            % not be recalculated
            assertFalse(ver_obj.experiment_info.runid_recalculated)

            assertEqual(ref_range,ver_obj.data.img_range);

            sqw_ob.main_header.creation_date = ver_obj.main_header.creation_date;
            assertEqual(sqw_ob.main_header,ver_obj.main_header);
            ver_obj.experiment_info.runid_recalculated = true; % for testing;
            assertEqualToTol(sqw_ob,ver_obj,[1.e-7,1.e-7]);
        end

        %
        function test_serialize_deserialise_faccess(obj)
            fo = faccess_sqw_v3_3();
            fo = fo.init(obj.sample_file);

            by = hlp_serialize(fo);
            fr = hlp_deserialize(by);

            assertEqual(fo,fr);

            by = hlp_serialise(fo);
            fr = hlp_deserialise(by);
            assertEqual(fo,fr);
        end
        %

    end
end
