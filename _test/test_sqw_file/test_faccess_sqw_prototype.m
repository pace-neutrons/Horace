classdef test_faccess_sqw_prototype< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %

    properties
        sample_dir;
        sample_file;
    end

    methods

        %The above can now be read into the test routine directly.
        function this=test_faccess_sqw_prototype(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this=this@TestCase(name);

            this.sample_dir = fullfile(fileparts(mfilename('fullpath')));
            this.sample_file = fullfile(this.sample_dir,'test_sqw_read_write_v0_t.sqw');
        end

        % tests
        function obj = test_should_load_stream(obj)
            to = faccess_sqw_prototype();
            co = onCleanup(@()to.delete());
            assertEqual(to.faccess_version,0);

            [stream,fid] = to.get_file_header(obj.sample_file);
            co1 = onCleanup(@()(fclose(fid)));

            clob = set_temporary_warning('off','SQW_FILE_IO:legacy_data');

            [ok,initob] = to.should_load_stream(stream,fid);

            assertTrue(ok);
            assertTrue(initob.file_id>0);


        end
        function obj = test_should_load_file(obj)
            to = faccess_sqw_prototype();
            assertEqual(to.faccess_version,0);
            co = onCleanup(@()to.delete());

            clob = set_temporary_warning('off','SQW_FILE_IO:legacy_data');

            [ok,inob] = to.should_load(obj.sample_file);
            co1 = onCleanup(@()(fclose(inob.file_id)));

            assertTrue(ok);
            assertTrue(inob.file_id>0);

        end

        function obj = test_init(obj)
            to = faccess_sqw_prototype();
            assertEqual(to.faccess_version,0);

            clob = set_temporary_warning('off','SQW_FILE_IO:legacy_data');

            [ok,inob] = to.should_load(obj.sample_file);

            assertTrue(ok);
            assertTrue(inob.file_id>0);

            to = to.init(inob);
            assertEqual(to.npixels,16);

            header = to.get_exp_info();
            assertTrue(isa(header,'Experiment'));
            expdata = header.expdata();
            assertTrue(isa(expdata,'IX_experiment'));
            assertEqual(numel(expdata),1);
            assertFalse(isempty(expdata));
            assertEqual(expdata.filename,'map11014.spe')
            assertEqual(expdata.ulabel{4},'E')
            assertEqual(expdata.ulabel{3},'Q_\eta')

            det = to.get_detpar();
            assertEqual(det.filename,'demo_par.PAR')
            assertEqual(det.filepath,'d:\users\abuts\SVN\ISIS\HoraceV1.0final\documentation\')
            assertEqual(numel(det.group),28160)

            data = to.get_data();
            assertEqual(size(data.s,1),numel(data.p{1})-1)
            assertEqual(size(data.e,2),numel(data.p{2})-1)
            assertEqual(size(data.npix,3),numel(data.p{3})-1)

            pix = to.get_pix();
            assertTrue(isa(pix, 'PixelDataBase'));
            assertEqual(pix.num_pixels,16)

        end
        function obj = test_get_data(obj)
            %spath = fileparts(obj.sample_file);
            clob = set_temporary_warning('off','SQW_FILE_IO:legacy_data');

            to = faccess_sqw_prototype(obj.sample_file);

            data_h = to.get_data('-he');
            assertTrue(isstruct(data_h))
            assertEqual(data_h.filename,to.filename)
            assertEqual(data_h.filepath,[to.filepath,filesep])

            data_dnd = to.get_data('-ver');
            assertTrue(isa(data_dnd,'DnDBase'));
            assertEqual(data_dnd.filename,'test_sqw_read_write_v0_t.sqw');

            data = to.get_data('-ver');
            assertEqual(data.filename,data_dnd.filename)
            assertEqual(data.filepath,data_dnd.filepath)
            pix = to.get_pix();
            assertTrue(isa(pix, 'PixelDataBase'));
            assertEqual(pix.full_filename, obj.sample_file);
            assertEqual(pix.num_pixels, 16);
        end

    end
end
