classdef test_faccess_dnd_v4< TestCase & common_sqw_file_state_holder
    %
    % Validate faccess_dnd_v4 class operations
    %
    %
    %
    properties
        sample_dir;
        sample_file;
        this_dir
    end
    methods(Static)
        function fcloser(fid)
            if fid>0
                fn = fopen(fid);
                if ~isempty(fn)
                    fclose(fid);
                end

            end
        end
    end

    methods

        %The above can now be read into the test routine directly.
        function obj=test_faccess_dnd_v4(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            obj=obj@TestCase(name);
            hp = horace_paths;
            obj.sample_dir = hp.test_common;
            obj.sample_file = fullfile(obj.sample_dir,'w2d_qq_d2d.sqw');
            obj.this_dir = fileparts(mfilename('fullpath'));
        end
        %------------------------------------------------------------------
        % tests
        function test_set_file_to_update_fails_on_sqw(obj)
            source = fullfile(obj.sample_dir,'w1d_sqw.sqw');

            function ldr=f_checker(ldr,source)
                ldr = ldr.set_file_to_update(source);
            end

            ldr = faccess_dnd_v4();
            assertExceptionThrown(@()f_checker(ldr,source), ...
                'HORACE:faccess_dnd_v4:invalid_argument');
        end

        function obj = test_upgrade_file_format(obj)
            source = obj.sample_file;
            sample  = fullfile(tmp_dir,'faccess_dnd_v4_upgrade_ff.sqw');
            copyfile(source,sample,'f');
            clOb = onCleanup(@()delete(sample));

            ldr = sqw_formats_factory.instance().get_loader(sample);
            d2d1 = ldr.get_dnd();

            ldr = ldr.upgrade_file_format();

            assertTrue(isa(ldr,'faccess_dnd_v4'));

            d2d2 = ldr.get_dnd();
            ldr.delete();

            assertEqualToTol(d2d1,d2d2,1.e-12,'-ignore_date')
        end

        function obj = test_should_load_stream(obj)
            sample = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');
            to = faccess_dnd_v4();
            co = onCleanup(@()to.delete());


            [stream,fid] = to.get_file_header(sample);
            [ok,initob] = to.should_load_stream(stream,fid);
            co1 = onCleanup(@()fclose(initob.file_id));

            assertTrue(ok);
            assertTrue(initob.file_id>0);
        end
        %
        function obj = test_faccess_v4_subscribed_should_load_file(obj)
            sample = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');
            to = faccess_dnd_v4();
            assertEqual(to.faccess_version,4);

            [ok,initobj] = to.should_load(sample);
            co1 = onCleanup(@()fclose(initobj.file_id));


            assertTrue(ok);
            assertTrue(initobj.file_id>0);

        end
        %
        function test_empty_init_do_nothing(~)
            to = faccess_dnd_v4();

            % does nothing
            to = to.init();

            assertEqual(to.num_dim,'undefined')
            assertEqual(to.data_type,'b+')

        end
        %
        function test_init(obj)
            sample = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');
            to = faccess_dnd_v4();


            [ok,initob] = to.should_load(sample);
            co1 = onCleanup(@()obj.fcloser(initob.file_id));


            assertTrue(ok);
            assertTrue(initob.file_id>0);


            to = to.init(initob);

            [fd,fn,fe] = fileparts(sample);

            assertEqual(to.filename,[fn,fe])
            assertEqual(to.filepath,fd)
            assertEqual(to.faccess_version,4)
            assertFalse(to.sqw_type)
            assertEqual(to.num_dim,2)
            assertEqual(to.data_type,'b+')


            data = to.get_data();
            assertTrue(isa(data,'DnDBase'));
            assertTrue(isa(data,'d2d'));
            assertEqual(size(data.s,1),numel(data.axes.p{1})-1)
            assertEqual(size(data.e,2),numel(data.axes.p{2})-1)
            assertTrue(isprop(data.axes,'img_range'));

        end
        function test_faccess_dnd_v4_other_get_methods(obj)
            source = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');
            facc = faccess_dnd_v4(source);

            dobj  = facc.get_sqw();
            assertTrue(isa(dobj,'d2d'));

            sen = facc.get_se_npix();
            assertTrue(isstruct(sen))
            assertEqual(dobj.s,sen.s)
            assertEqual(dobj.e,sen.e)
            assertEqual(dobj.npix,double(sen.npix))

            ins = facc.get_instrument();
            assertEqual(ins,IX_null_inst);

            sam = facc.get_sample();
            assertTrue(isa(sam,'IX_samp'));

            pr =  facc.get_pix_range();
            assertTrue(isempty(pr));

            idb = facc.get_img_db_range();
            assertEqual(idb,dobj.img_range);

        end

        %
        function obj = test_get_put_blocks(obj)
            source = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');
            sample  = fullfile(tmp_dir,'faccess_dnd_v4_put_get_block.sqw');
            copyfile(source,sample,'f');
            clOb = onCleanup(@()delete(sample));


            facc = faccess_dnd_v4(sample);
            facc = facc.set_file_to_update();

            dnd_meta = facc.get_dnd_metadata();
            dnd_meta.title = 'my belowed data';
            facc = facc.put_dnd_metadata(dnd_meta);

            dnd_dat = facc.get_dnd_data();
            dnd_dat.sig(1:10) = 1:10;
            facc = facc.put_dnd_data(dnd_dat);
            facc.delete();

            % need to use other file name as the previous deleter have not
            % been worked yet
            facc1 = faccess_dnd_v4(sample);
            up_data = facc1.get_dnd('-ver');
            facc1.delete();

            ref_data = DnDBase.dnd(dnd_meta,dnd_dat);

            assertEqualToTol(up_data,ref_data,'-ignore_date')
        end
        %
        function obj = test_get_data(obj)
            sample = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');

            to = faccess_dnd_v4(sample);
            assertEqual(to.num_dim,2);
            assertEqual(to.faccess_version,4)
            assertFalse(to.sqw_type)
            assertEqual(to.data_type,'b+')



            data_h = to.get_data('-he');
            assertTrue(isstruct(data_h))
            assertEqual(data_h.filename,to.filename)
            assertEqual(data_h.filepath,to.filepath)

            data_dnd = to.get_data('-hver');
            assertTrue(isstruct(data_dnd));
            assertEqual(data_dnd.filename,'rbmnf3.sqw');
        end
        %
        function obj = test_get_sqw(obj)
            source_file = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');

            to = faccess_dnd_v4();
            to = to.init(source_file);

            assertEqual(to.num_dim,2);
            assertEqual(to.faccess_version,4)
            assertFalse(to.sqw_type)
            assertEqual(to.data_type,'b+')

            d2d_inst  = to.get_sqw();
            assertTrue(isa(d2d_inst ,'d2d'));
            assertEqual(d2d_inst.filename,to.filename)
            assertEqual(d2d_inst .filepath,to.filepath)

            data_dnd = to.get_sqw('-ver');
            assertTrue(isa(data_dnd,'d2d'));
            assertEqual(data_dnd.filename,'rbmnf3.sqw');
        end

        function obj = test_get_put_dnd_use_methods(obj)

            source_file = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');
            sldr = faccess_dnd_v4(source_file);
            sample_dnd = sldr.get_dnd('-ver');
            sldr.delete();

            targ_file = fullfile(tmp_dir,'faccess_dnd_v4_put_get.sqw');
            clOb = onCleanup(@()delete(targ_file));

            f_writer = faccess_dnd_v4();
            f_writer = f_writer.put_dnd(sample_dnd,targ_file);
            f_writer.delete();
            assertTrue(is_file(targ_file))

            f_reader = faccess_dnd_v4();
            [rec_dnd,f_reader]  = f_reader.get_dnd(targ_file,'-verbatim');
            f_reader.delete();

            assertEqual(sample_dnd,rec_dnd);
        end
        %
        function obj = test_get_put_dnd(obj)

            source_file = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');
            sldr = faccess_dnd_v4(source_file);
            sample_dnd = sldr.get_dnd('-ver');
            sldr.delete();

            targ_file = fullfile(tmp_dir,'faccess_dnd_v4_put_get.sqw');
            clOb = onCleanup(@()delete(targ_file));

            f_writer = faccess_dnd_v4(sample_dnd,targ_file);
            f_writer = f_writer.put_dnd();
            f_writer.delete();
            assertTrue(is_file(targ_file))

            f_reader = faccess_dnd_v4(targ_file);
            [rec_dnd,f_reader]  = f_reader.get_dnd('-verbatim');
            f_reader.delete();

            assertEqual(sample_dnd,rec_dnd);
        end
        %
        function test_get_dnd_v4(obj)
            test_file = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');
            origin  = fullfile(obj.sample_dir,'sqw_2d_1.sqw');

            org_ldr = sqw_formats_factory.instance().get_loader(origin);
            org_dnd = org_ldr.get_dnd('-ver');
            org_ldr.delete();


            sldr = faccess_dnd_v4(test_file);
            sample_dnd = sldr.get_dnd('-ver');
            sldr.delete();
            pix_cc = [eye(3),ones(3,1)];
            orig_img = org_dnd.proj.transform_pix_to_img(pix_cc);
            samp_img = sample_dnd.proj.transform_pix_to_img(pix_cc);
            assertElementsAlmostEqual(orig_img,samp_img);
            sample_dnd.proj = org_dnd.proj;

            assertEqualToTol(org_dnd,sample_dnd,'tol',1.e-12,'-ignore_date');
        end
    end
end
