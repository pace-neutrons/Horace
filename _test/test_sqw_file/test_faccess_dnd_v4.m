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
        function sz = fl_size(filename)
            fh = fopen(filename,'rb');
            p0 = ftell(fh);
            fseek(fh,0,'eof');
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
        %         function obj = test_should_load_stream(obj)
        %             to = faccess_dnd_v2();
        %             co = onCleanup(@()to.delete());
        %
        %
        %             [stream,fid] = to.get_file_header(obj.sample_file);
        %             [ok,initob] = to.should_load_stream(stream,fid);
        %             co1 = onCleanup(@()fclose(initob.file_id));
        %
        %             assertTrue(ok);
        %             assertTrue(initob.file_id>0);
        %         end
        % %
        %         function obj = test_should_load_file(obj)
        %             to = faccess_dnd_v2();
        %             assertEqual(to.faccess_version,2);
        %
        %             [ok,initobj] = to.should_load(obj.sample_file);
        %             co1 = onCleanup(@()fclose(initobj.file_id));
        %
        %
        %             assertTrue(ok);
        %             assertTrue(initobj.file_id>0);
        %
        %         end
        %         %
        %         function test_empty_init_do_nothing(~)
        %             to = faccess_dnd_v2();
        %
        %             % does nothing
        %             to = to.init();
        %
        %             assertEqual(to.num_dim,'undefined')
        %             assertEqual(to.data_type,'undefined')
        %
        %         end
        % %
        %         function test_init(obj)
        %             to = faccess_dnd_v2();
        %
        %
        %             [ok,initob] = to.should_load(obj.sample_file);
        %             co1 = onCleanup(@()obj.fcloser(initob.file_id));
        %
        %
        %             assertTrue(ok);
        %             assertTrue(initob.file_id>0);
        %
        %
        %             to = to.init(initob);
        %
        %             [fd,fn,fe] = fileparts(obj.sample_file);
        %
        %             assertEqual(to.filename,[fn,fe])
        %             assertEqual(to.filepath,[fd,filesep])
        %             assertEqual(to.faccess_version,2)
        %             assertFalse(to.sqw_type)
        %             assertEqual(to.num_dim,2)
        %             assertEqual(to.data_type,'b+')
        %
        %
        %             data = to.get_data();
        %             assertTrue(isa(data,'DnDBase'));
        %             %data = data_sqw_dnd(data);
        %             assertEqual(size(data.s,1),numel(data.p{1})-1)
        %             assertEqual(size(data.e,2),numel(data.p{2})-1)
        %             assertFalse(isfield(data,'img_db_range'));
        %             assertEqual(size(data.s),to.dnd_dimensions);
        %
        %         end
        %  %
        %         function obj = test_get_data(obj)
        %             spath = fileparts(obj.sample_file);
        %             sample  = fullfile(spath,'w1d_d1d.sqw');
        %
        %             to = faccess_dnd_v2(sample);
        %             assertEqual(to.num_dim,1);
        %             assertEqual(to.faccess_version,2)
        %             assertFalse(to.sqw_type)
        %             assertEqual(to.data_type,'b+')
        %
        %
        %
        %             data_h = to.get_data('-he');
        %             assertTrue(isstruct(data_h))
        %             assertEqual(data_h.filename,to.filename)
        %             assertEqual(data_h.filepath,to.filepath)
        %
        %             data_dnd = to.get_data('-hver');
        %             assertTrue(isstruct(data_dnd));
        %             assertEqual(data_dnd.filename,'ei140.sqw');
        %         end
        % %
        %         function obj = test_get_sqw(obj)
        %             spath = fileparts(obj.sample_file);
        %             sample  = fullfile(spath,'w3d_d3d.sqw');
        %
        %
        %             to = faccess_dnd_v2();
        %             to = to.init(sample);
        %
        %             assertEqual(to.num_dim,3);
        %             assertEqual(to.faccess_version,2)
        %             assertFalse(to.sqw_type)
        %             assertEqual(to.data_type,'b+')
        %
        %             d3d_inst  = to.get_sqw();
        %             assertTrue(isa(d3d_inst,'d3d'));
        %             assertEqual(d3d_inst.filename,to.filename)
        %             assertEqual(d3d_inst.filepath,to.filepath)
        %
        %             data_dnd = to.get_sqw('-ver');
        %             assertTrue(isa(data_dnd,'d3d'));
        %             assertEqual(data_dnd.filename,'ei140.sqw');
        %         end
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


            f_reader = faccess_dnd_v4(targ_file);
            [rec_dnd,f_reader]  = f_reader.get_dnd('-verbatim');
            f_reader.delete();

            assertEqual(sample_dnd,rec_dnd);

        end
        function test_get_dnd_v4(obj)
            test_file = fullfile(obj.this_dir,'faccess_dnd_v4_sample.sqw');
            origin  = fullfile(obj.sample_dir,'sqw_2d_1.sqw');

            org_ldr = sqw_formats_factory.instance().get_loader(origin);
            org_dnd = org_ldr.get_dnd('-ver');
            org_ldr.delete();


            sldr = faccess_dnd_v4(test_file);
            sample_dnd = sldr.get_dnd('-ver');
            sldr.delete();

            assertEqualToTol(org_dnd,sample_dnd,'tol',1.e-12,'-ignore_date');
        end
    end
end


