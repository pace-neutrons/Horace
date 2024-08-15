classdef test_faccess_sqw_v2< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    %


    properties
        sample_dir;
        sample_file;
        test_folder;
        % old warning level
        old_wl;
    end
    methods(Static)
        function sz = fl_size(filename)
            fh = fopen(filename,'rb');
            p0 = ftell(fh);
            do_fseek(fh,0,'eof');
            p1 = ftell(fh);
            sz = p1-p0;
            fclose(fh);
        end

    end

    methods

        %The above can now be read into the test routine directly.
        function obj=test_faccess_sqw_v2(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            obj=obj@TestCase(name);

            hc = horace_paths;
            obj.sample_dir = hc.test_common;
            obj.sample_file = fullfile(obj.sample_dir,'w3d_sqw.sqw');
            obj.test_folder=fileparts(mfilename('fullpath'));
            obj.old_wl = warning('off','HORACE:old_file_format');
        end
        function delete(obj)
            warning(obj.old_wl);
        end

        % tests
        function obj = test_should_load_stream(obj)
            to = faccess_sqw_v2();
            co = onCleanup(@()to.delete());


            [stream,fid] = to.get_file_header(obj.sample_file);
            [ok,initob] = to.should_load_stream(stream,fid);
            co1 = onCleanup(@()fclose(initob.file_id));
            assertTrue(ok);
            assertTrue(initob.file_id> 0);



        end
        function obj = test_should_load_file(obj)
            to = faccess_sqw_v2();
            co = onCleanup(@()to.delete());

            [ok,initob] = to.should_load(obj.sample_file);
            co1 = onCleanup(@()fclose(initob.file_id));

            assertTrue(ok);
            assertTrue(initob.file_id>0);
        end

        function test_empty_init_does_nothing(~)
            to = faccess_sqw_v2();

            % does nothing
            to = to.init();

            assertEqual(to.num_dim,'undefined')
            assertEqual(to.data_type,'undefined')

        end

        function obj = test_init(obj)
            to = faccess_sqw_v2();
            assertEqual(to.faccess_version,2);

            [ok,initob] = to.should_load(obj.sample_file);

            assertTrue(ok);
            assertTrue(initob.file_id > 0);

            to = to.init(initob);
            assertEqual(to.npixels,1164180);

            exper = to.get_exp_info();
            exp_info = exper.expdata;
            assertEqual(exp_info.filename,'slice_n_c_m1_ei140')

            det = to.get_detpar();
            assertEqual(det.filename,'slice_n_c_m1_ei140.par')
            assertEqual(det.filepath,'C:\Russell\PCMO\ARCS_Oct10\Data\')
            assertEqual(numel(det.group),58880)

            data = to.get_data();
            assertEqual(size(data.s,1),numel(data.p{1})-1)
            assertEqual(size(data.e,2),numel(data.p{2})-1)
            assertEqual(size(data.npix,3),numel(data.p{3})-1)

            pix = to.get_pix();
            assertEqual(pix.num_pixels,1164180)

        end
        function obj = test_read_v1(obj)
            to = faccess_sqw_v2();
            assertEqual(to.faccess_version,2);

            [ok,initob] = to.should_load(fullfile(obj.test_folder,'w2_small_v1.sqw'));

            assertTrue(ok);
            assertTrue(initob.file_id > 0);

            to = to.init(initob);
            assertEqual(to.npixels,179024);

            exper = to.get_exp_info();
            header = exper.expdata;
            assertEqual(header.filename,'map11014.spe;1')

            det = to.get_detpar();
            assertEqual(det.filename,'9cards_4_4to1.par')
            assertEqual(det.filepath,'c:\data\Fe\')
            assertEqual(numel(det.group),36864)

            data = to.get_data();
            assertEqual(size(data.s,1),numel(data.p{1})-1)
            assertEqual(size(data.e,2),numel(data.p{2})-1)
            assertEqual(size(data.npix),size(data.e))
            pix = to.get_pix();
            assertEqual(pix.num_pixels,179024)

            exp_info = to.get_exp_info('-all');
            assertTrue(isa(exp_info,'Experiment'));
            assertEqual(exp_info.n_runs,186)

            exp_n = exp_info.expdata(186);
            assertEqual(exp_n.filename,'map11201.spe;1');
            assertEqual(exp_n.filepath,'c:\data\Fe\data_nov06\const_ei\');

            main_h = to.get_main_header('-keep_original');
            assertEqual(main_h.nfiles,186);
            assertEqual(main_h.filename,'Fe_ei787.sqw');
            assertEqual(main_h.filepath,'c:\data\Fe\sqw');

        end

        function obj = test_get_data(obj)
            spath = fileparts(obj.sample_file);
            sample  = fullfile(spath,'w1d_sqw.sqw');

            to = faccess_sqw_v2(sample);

            data_h = to.get_data('-he');
            assertTrue(isstruct(data_h))
            assertEqual(data_h.filename,to.filename)
            assertEqual(data_h.filepath,to.filepath)

            data_dnd = to.get_data('-ver');
            assertTrue(isa(data_dnd,'DnDBase'));
            assertEqual(data_dnd.filename,'ei140.sqw');

            data = to.get_data('-ver');
            assertEqual(data.filename,data_dnd.filename)
            assertEqual(data.filepath,data_dnd.filepath)
            pix = to.get_pix();
            assertTrue(isa(pix, 'PixelDataBase'));
            assertEqual(pix.full_filename, sample);
            assertEqual(pix.num_pixels, 8031);
        end

        function obj = test_get_sqw(obj)
            spath = fileparts(obj.sample_file);
            samplef  = fullfile(spath,'w2d_qq_small_sqw.sqw');

            fo = faccess_sqw_v2();
            fo = fo.init(samplef);

            sqw_obj = fo.get_sqw();

            assertTrue(isa(sqw_obj,'sqw'));
            assertEqual(sqw_obj.main_header.filename,fo.filename)
            assertEqual(sqw_obj.main_header.filepath,fo.filepath)

            sqw_obj1 = fo.get_sqw('-hverbatim');
            assertTrue(isa(sqw_obj1,'sqw'));
            assertEqual(sqw_obj1.main_header.filename,'ei140.sqw')
            assertEqual(sqw_obj1.main_header.filepath,...
                'C:\Russell\PCMO\ARCS_Oct10\Data\SQW')
        end
        %
        function obj = test_put_sqw(obj)
            spath = fileparts(obj.sample_file);
            samplef  = fullfile(spath,'w2d_qq_small_sqw.sqw');


            source_sqw = faccess_sqw_v2(samplef);
            tob_sqw = source_sqw.get_sqw('-verbatim');
            assertFalse(tob_sqw.main_header.creation_date_defined);

            fresh_sqw = faccess_sqw_v2();

            tf = fullfile(tmp_dir,'test_put_sqw_v2.sqw');
            clob = onCleanup(@()del_memmapfile_files(tf));

            fresh_sqw = fresh_sqw.init(tob_sqw);
            fresh_sqw = fresh_sqw.set_file_to_update(tf);


            fresh_sqw=fresh_sqw.put_sqw();
            assertTrue(exist(tf,'file')==2)
            fresh_sqw.delete();
            %
            sz1 = obj.fl_size(samplef);
            sz2 = obj.fl_size(tf);
            %
            % new file has been upgraded with runid_map so its size have
            % increased? one byte is missing, why?
            assertEqual(sz1+numel('$id$1')+numel(char(datetime("now")))- ...
                29,... % save small dummy ulabel instead of large old one
                sz2);
            %
            tn = faccess_sqw_v2(tf);
            rec_sqw = tn.get_sqw('-ver');
            tn.delete();
            assertTrue(rec_sqw.main_header.creation_date_defined);
            %

            tob_sqw.main_header.creation_date = rec_sqw.main_header.creation_date;
            assertEqualToTol(tob_sqw, rec_sqw,'tol',2.e-7);
            %
        end
        %
        function obj = test_upgrade_sqw(obj)
            spath = fileparts(obj.sample_file);
            samplef  = fullfile(spath,'w2d_qq_small_sqw.sqw');


            tf = fullfile(tmp_dir,'test_upgrade_sqwV2.sqw');
            clob = onCleanup(@()del_memmapfile_files(tf));
            copyfile(samplef,tf);

            tob = faccess_sqw_v2(tf);
            tob = tob.upgrade_file_format();
            assertTrue(isa(tob,'faccess_sqw_v4'));


            sqw1 = tob.get_sqw();
            tob.delete();

            to = sqw_formats_factory.instance().get_loader(tf);
            assertTrue(isa(to,'faccess_sqw_v4'));

            sqw2 = to.get_sqw();
            to.delete();

            assertEqualToTol(sqw1,sqw2,1.e-12,'-ignore_date','ignore_str',true);
            %
            %fclose all;
        end
        %
        function obj = test_upgrade_sqw_multiheader(obj)
            spath = fileparts(fileparts(obj.sample_file));
            samplef  = fullfile(spath,'test_sqw_file','w2_small_v1.sqw');


            tf = fullfile(tmp_dir,'test_upgrade_sqwV2_multiheader.sqw');
            clob = onCleanup(@()del_memmapfile_files(tf));
            copyfile(samplef,tf);

            tob = faccess_sqw_v2(tf);
            tob = tob.upgrade_file_format();
            assertTrue(isa(tob,'faccess_sqw_v4'));

            sqw1 = tob.get_sqw();
            tob.delete();

            to = sqw_formats_factory.instance().get_loader(tf);
            assertTrue(isa(to,'faccess_sqw_v4'));

            sqw2 = to.get_sqw();
            to.delete();

            assertEqualToTol(sqw1,sqw2,1.e-12,'-ignore_date','ignore_str',true);
            %
            %fclose all;
        end

        %
        function obj = test_upgrade_sqw_wac(obj)
            %
            spath = fileparts(obj.sample_file);
            samplef  = fullfile(spath,'w2d_qq_small_sqw.sqw');

            sqwob = read_sqw(samplef);
            assertFalse(sqwob.main_header.creation_date_defined);

            tf = fullfile(tmp_dir,'test_upgrade_sqwV2_wac.sqw');
            clob = onCleanup(@()del_memmapfile_files(tf));
            tob = faccess_sqw_v2(sqwob,tf);
            tob = tob.put_sqw();

            tobV4 = tob.upgrade_file_format();
            assertTrue(isa(tobV4,'faccess_sqw_v4'));

            sqw1 = tobV4.get_sqw();
            tobV4.delete();
            tob.delete();


            % file was written afresh so have chreation date defined
            assertTrue(sqw1.main_header.creation_date_defined);


            to = sqw_formats_factory.instance().get_loader(tf);
            assertTrue(isa(to,'faccess_sqw_v4'));

            sqw2 = to.get_sqw();
            to.delete();
            assertTrue(sqw2.main_header.creation_date_defined);

            assertEqualToTol(sqw1,sqw2,'ignore_str',true);

            assertEqualToTol(sqwob,sqw2,'tol',[2.e-7,2.e-7], ...
                'ignore_str',true,'-ignore_date')

            %
        end
        %
        function obj = test_put_dnd_from_sqw(obj)
            %
            spath = fileparts(obj.sample_file);
            samplef  = fullfile(spath,'w2d_qq_small_sqw.sqw');

            sqwob = read_sqw(samplef);

            tf = fullfile(tmp_dir,'test_put_dnd_from_sqw.sqw');
            clob = onCleanup(@()del_memmapfile_files(tf));
            tob = faccess_sqw_v2(sqwob,tf);
            tob = tob.put_dnd();
            tob.delete();

            to = sqw_formats_factory.instance().get_loader(tf);
            assertTrue(isa(to,'faccess_dnd_v2'));

            sqw2 = to.get_sqw();
            to.delete();
            assertTrue(isa(sqw2,'d2d'));

            assertEqualToTol(d2d(sqwob),sqw2, 'tol',[2e-7,2e-7],...
                'ignore_str',true)
            %
        end
        %
        function obj = test_get_dnd_from_sqw(obj)
            %
            spath = fileparts(obj.sample_file);
            samplef  = fullfile(spath,'w2d_qq_small_sqw.sqw');

            dnob = read_dnd(samplef);

            tf = fullfile(tmp_dir,'test_put_dnd_from_sqw.sqw');
            clob = onCleanup(@()del_memmapfile_files(tf));

            tob = faccess_dnd_v2(dnob,tf);
            tob = tob.put_sqw();
            tob.delete();

            to = sqw_formats_factory.instance().get_loader(tf);
            assertTrue(isa(to,'faccess_dnd_v2'));

            dn2 = to.get_sqw();
            to.delete();
            assertTrue(isa(dn2,'d2d'));

            assertEqualToTol(dn2,dnob,'ignore_str',true)
            %
        end
        %
        function obj = test_sqw_reopen_to_write(obj)

            samp = fullfile(obj.sample_dir,'w1d_sqw.sqw');
            ttob = faccess_sqw_v2(samp);
            % important! -keep_original is critical here! without it we should
            % reinitialize object to for upgrade, as file fields change!
            sq_obj = ttob.get_sqw('-keep_original');
            assertTrue(isa(sq_obj,'sqw'));

            test_f = fullfile(tmp_dir,'test_sqw_reopen_to_wrire.sqw');
            clob = onCleanup(@()del_memmapfile_files(test_f));

            % using already initialized object to write new data.
            % its better to initialize object again as with this form
            % object bas to be exactly the same as the one read before.
            ttob =  ttob.reopen_to_write(test_f);
            ttob = ttob.put_sqw(sq_obj);
            ttob.delete();

            assertEqual(exist(test_f,'file'),2);

            chob = faccess_sqw_v2(test_f);

            tsq_obj = chob.get_sqw();
            chob.delete();

            assertEqualToTol(sq_obj,tsq_obj,'tol',2.e-7, ...
                'ignore_str',true,'-ignore_date');


        end
    end
end
