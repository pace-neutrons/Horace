classdef test_faccess_sqw_prototype< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    % $Revision$ ($Date$)
    %
    
    
    properties
        sample_dir;
        sample_file;
        clob = []
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
            assertEqual(to.file_version,'-v0');
            
            [stream,fid] = to.get_file_header(obj.sample_file);
            co1 = onCleanup(@()(fclose(fid)));
            
            warning('off','SQW_FILE_IO:legacy_data')
            this.clob = onCleanup(@()(warning('on','SQW_FILE_IO:legacy_data')));
            
            [ok,initob] = to.should_load_stream(stream,fid);
            
            assertTrue(ok);
            assertTrue(initob.file_id>0);
            
            
        end
        function obj = test_should_load_file(obj)
            to = faccess_sqw_prototype();
            assertEqual(to.file_version,'-v0');
            co = onCleanup(@()to.delete());
            
            warning('off','SQW_FILE_IO:legacy_data')
            this.clob = onCleanup(@()(warning('on','SQW_FILE_IO:legacy_data')));
            
            [ok,inob] = to.should_load(obj.sample_file);
            co1 = onCleanup(@()(fclose(inob.file_id)));
            
            assertTrue(ok);
            assertTrue(inob.file_id>0);
            
        end
        
        function obj = test_init(obj)
            to = faccess_sqw_prototype();
            assertEqual(to.file_version,'-v0');
            
            %access to incorrect object
            f = @()(to.init());
            assertExceptionThrown(f,'SQW_FILE_IO:invalid_argument');
            
            warning('off','SQW_FILE_IO:legacy_data')
            this.clob = onCleanup(@()(warning('on','SQW_FILE_IO:legacy_data')));
            
            [ok,inob] = to.should_load(obj.sample_file);
            
            assertTrue(ok);
            assertTrue(inob.file_id>0);
            
            to = to.init(inob);
            assertEqual(to.npixels,16);
            
            header = to.get_header();
            assertEqual(header.filename,'map11014.spe')
            assertEqual(header.ulabel{4},'E')
            assertEqual(header.ulabel{3},'Q_\eta')
            
            det = to.get_detpar();
            assertEqual(det.filename,'demo_par.PAR')
            assertEqual(det.filepath,'d:\users\abuts\SVN\ISIS\HoraceV1.0final\documentation\')
            assertEqual(numel(det.group),28160)
            
            data = to.get_data();
            assertEqual(size(data.pix),[9,16])
            assertEqual(size(data.s,1),numel(data.p{1})-1)
            assertEqual(size(data.e,2),numel(data.p{2})-1)
            assertEqual(size(data.npix,3),numel(data.p{3})-1)
            
        end
        function obj = test_get_data(obj)
            %spath = fileparts(obj.sample_file);
            warning('off','SQW_FILE_IO:legacy_data')
            this.clob = onCleanup(@()(warning('on','SQW_FILE_IO:legacy_data')));
            
            to = faccess_sqw_prototype(obj.sample_file);
            
            data_h = to.get_data('-he');
            assertTrue(isstruct(data_h))
            assertEqual(data_h.filename,to.filename)
            assertEqual(data_h.filepath,to.filepath)
            
            data_dnd = to.get_data('-hver','-nopix');
            assertTrue(isa(data_dnd,'data_sqw_dnd'));
            assertEqual(data_dnd.filename,'test_sqw_read_write_v0_t.sqw');
            
            data = to.get_data('-hver',1,10);
            assertEqual(data.filename,data_dnd.filename)
            assertEqual(data.filepath,data_dnd.filepath)
            assertEqual(size(data.pix),[9,10]);
        end
        
    end
end

