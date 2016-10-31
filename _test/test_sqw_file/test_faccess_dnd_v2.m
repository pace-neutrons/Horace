classdef test_faccess_dnd_v2< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    % $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
    %
    
    
    properties
        sample_dir;
        sample_file;
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
            
            this.sample_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))),'test_symmetrisation');
            this.sample_file = fullfile(this.sample_dir,'w2d_qq_d2d.sqw');
            
        end
        
        % tests
        function obj = test_should_load_stream(obj)
            to = faccess_dnd_v2();
            co = onCleanup(@()to.fclose());
            
            
            [stream,fid] = to.get_file_header(obj.sample_file);
            [ok,to] = to.should_load_stream(stream,fid);
            assertTrue(ok);
            assertEqual(to.file_version,'-v2');
            
            
            
        end
        function obj = test_should_load_file(obj)
            to = faccess_dnd_v2();
            
            [ok,to] = to.should_load(obj.sample_file);
            assertTrue(ok);
            assertEqual(to.file_version,'-v2');
            
        end
        
        function obj = test_init(obj)
            to = faccess_dnd_v2();
            
            % access to incorrect object
            f = @()(to.init());
            assertExceptionThrown(f,'DND_BINFILE_COMMON:runtime_error');
            
            
            [ok,to] = to.should_load(obj.sample_file);
            
            assertTrue(ok);
            assertEqual(to.file_version,'-v2');
            
            
            to = to.init();
            
            [fd,fn,fe] = fileparts(obj.sample_file);
            
            assertEqual(to.filename,[fn,fe])
            assertEqual(to.filepath,[fd,filesep])
            assertEqual(to.file_version,'-v2')
            assertFalse(to.sqw_type)
            assertEqual(to.num_dim,2)
            assertEqual(to.data_type,'b+')
            
            
            data = to.get_data();
            assertEqual(size(data.s,1),numel(data.p{1})-1)
            assertEqual(size(data.e,2),numel(data.p{2})-1)
            assertFalse(isfield(data,'urange'));
            assertEqual(size(data.s),to.dnd_dimensions);
            
        end
        function obj = test_get_data(obj)
            spath = fileparts(obj.sample_file);
            sample  = fullfile(spath,'w1d_d1d.sqw');
            
            to = faccess_dnd_v2(sample);
            assertEqual(to.num_dim,1);
            assertEqual(to.file_version,'-v2')
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
        
        function obj = test_get_sqw(obj)
            spath = fileparts(obj.sample_file);
            sample  = fullfile(spath,'w3d_d3d.sqw');
            
            
            to = faccess_dnd_v2();
            to = to.init(sample);
            
            assertEqual(to.num_dim,3);
            assertEqual(to.file_version,'-v2')
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
            
            tf = fullfile(tempdir,'test_save_dnd_v2.sqw');
            clob = onCleanup(@()delete(tf));
            tt = tt.set_filename_to_write(tf);
            
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
            
            assertEqual(struct(tob_dnd),struct(rec_dnd));
            
        end
        %
        function test_data_format_access(obj)
        end
        
        
    end
end


