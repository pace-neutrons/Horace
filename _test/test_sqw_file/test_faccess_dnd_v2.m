classdef test_faccess_dnd_v2< TestCase & common_sqw_file_state_holder
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    %


    properties
        sample_dir;
        sample_file;
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
        function this=test_faccess_dnd_v2(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this=this@TestCase(name);
            hp = horace_paths;
            this.sample_dir = hp.test_common;
            this.sample_file = fullfile(this.sample_dir,'w2d_qq_d2d.sqw');

        end

        % tests
        function obj = test_should_load_stream(obj)
            to = faccess_dnd_v2();
            co = onCleanup(@()to.delete());


            [stream,fid] = to.get_file_header(obj.sample_file);
            [ok,initob] = to.should_load_stream(stream,fid);
            co1 = onCleanup(@()fclose(initob.file_id));

            assertTrue(ok);
            assertTrue(initob.file_id>0);



        end
        function obj = test_should_load_file(obj)
            to = faccess_dnd_v2();
            assertEqual(to.faccess_version,2);

            [ok,initobj] = to.should_load(obj.sample_file);
            co1 = onCleanup(@()fclose(initobj.file_id));


            assertTrue(ok);
            assertTrue(initobj.file_id>0);

        end
        function test_empty_init_do_nothing(~)
            to = faccess_dnd_v2();

            % does nothing
            to = to.init();

            assertEqual(to.num_dim,'undefined')
            assertEqual(to.data_type,'undefined')

        end

        function test_init(obj)
            to = faccess_dnd_v2();


            [ok,initob] = to.should_load(obj.sample_file);
            co1 = onCleanup(@()obj.fcloser(initob.file_id));


            assertTrue(ok);
            assertTrue(initob.file_id>0);


            to = to.init(initob);

            [fd,fn,fe] = fileparts(obj.sample_file);

            assertEqual(to.filename,[fn,fe])
            assertEqual(to.filepath,fd)
            assertEqual(to.faccess_version,2)
            assertFalse(to.sqw_type)
            assertEqual(to.num_dim,2)
            assertEqual(to.data_type,'b+')


            data = to.get_data();
            assertTrue(isa(data,'DnDBase'));
            %data = data_sqw_dnd(data);
            assertEqual(size(data.s,1),numel(data.p{1})-1)
            assertEqual(size(data.e,2),numel(data.p{2})-1)
            assertFalse(isfield(data,'img_db_range'));
            assertEqual(size(data.s),to.dnd_dimensions);

        end
        function obj = test_get_data(obj)
            spath = fileparts(obj.sample_file);
            sample  = fullfile(spath,'w1d_d1d.sqw');

            to = faccess_dnd_v2(sample);
            assertEqual(to.num_dim,1);
            assertEqual(to.faccess_version,2)
            assertFalse(to.sqw_type)
            assertEqual(to.data_type,'b+')



            data_h = to.get_data('-he');
            assertTrue(isstruct(data_h))
            assertEqual(data_h.filename,to.filename)
            assertEqual(data_h.filepath,to.filepath)

            data_dnd = to.get_data('-hver');
            assertTrue(isstruct(data_dnd));
            assertEqual(data_dnd.filename,'ei140.sqw');
        end
        function test_get_npix_block(obj)
            spath = fileparts(obj.sample_file);
            sample  = fullfile(spath,'w3d_d3d.sqw');

            ldr = faccess_dnd_v2(sample);

            dat = ldr.get_dnd();
            npix = dat.npix;
            np = numel(npix);
            np1 = floor(np/2);
            npix1 = ldr.get_npix_block(1,np1);

            assertEqual(npix(1:np1),npix1');
            npix2 = ldr.get_npix_block(np1+1,np);
            ldr.delete(); % avoid problem with file-deleteon, when clOb
            % clears up before ldr in automatic clean-up
            assertEqual(npix(np1+1:np),npix2');
        end


        function obj = test_get_sqw(obj)
            spath = fileparts(obj.sample_file);
            sample  = fullfile(spath,'w3d_d3d.sqw');


            to = faccess_dnd_v2();
            to = to.init(sample);

            assertEqual(to.num_dim,3);
            assertEqual(to.faccess_version,2)
            assertFalse(to.sqw_type)
            assertEqual(to.data_type,'b+')

            d3d_inst  = to.get_sqw();
            assertTrue(isa(d3d_inst,'d3d'));
            assertEqual(d3d_inst.filename,to.filename)
            assertEqual(d3d_inst.filepath,to.filepath)

            data_dnd = to.get_sqw('-ver');
            assertTrue(isa(data_dnd,'d3d'));
            assertEqual(data_dnd.filename,'ei140.sqw');
        end

        function obj = test_put_dnd(obj)
            spath = fileparts(obj.sample_file);
            sample  = fullfile(spath,'w3d_d3d.sqw');


            ts = faccess_dnd_v2(sample);
            tob_dnd = ts.get_sqw('-ver');

            tt = faccess_dnd_v2();
            tt = tt.init(tob_dnd);

            tf = fullfile(tmp_dir,'test_save_dnd_v2.sqw');
            clob = onCleanup(@()delete(tf));
            tt = tt.set_file_to_update(tf);

            tt=tt.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tt.delete();
            %
            sz1 = obj.fl_size(sample);
            sz2 = obj.fl_size(tf);

            assertEqual(sz1,sz2);

            tn = faccess_dnd_v2(tf);
            rec_dnd = tn.get_sqw('-ver');
            tn.delete();

            assertEqualToTol(tob_dnd,rec_dnd);
        end
    end
end
