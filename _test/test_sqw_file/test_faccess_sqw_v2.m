classdef test_faccess_sqw_v2< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    % $Revision$ ($Date$)
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
        function this=test_faccess_sqw_v2(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this=this@TestCase(name);
            
            this.sample_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))),'test_symmetrisation');
            this.sample_file = fullfile(this.sample_dir,'w3d_sqw.sqw');
            
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
        
        function obj = test_init(obj)
            to = faccess_sqw_v2();
            assertEqual(to.file_version,'-v2');
            
            
            % access to incorrect object
            f = @()(to.init());
            assertExceptionThrown(f,'SQW_FILE_IO:invalid_argument');
            
            
            [ok,initob] = to.should_load(obj.sample_file);
            
            assertTrue(ok);
            assertTrue(initob.file_id > 0);
            
            to = to.init(initob);
            assertEqual(to.npixels,1164180);
            
            header = to.get_header();
            assertEqual(header.filename,'slice_n_c_m1_ei140')
            assertEqual(header.ulabel{4},'E')
            assertEqual(header.ulabel{3},'Q_\eta')
            
            det = to.get_detpar();
            assertEqual(det.filename,'slice_n_c_m1_ei140.par')
            assertEqual(det.filepath,'C:\Russell\PCMO\ARCS_Oct10\Data\')
            assertEqual(numel(det.group),58880)
            
            data = to.get_data();
            assertEqual(size(data.pix),[9,1164180])
            assertEqual(size(data.s,1),numel(data.p{1})-1)
            assertEqual(size(data.e,2),numel(data.p{2})-1)
            assertEqual(size(data.npix,3),numel(data.p{3})-1)
            
        end
        function obj = test_get_data(obj)
            spath = fileparts(obj.sample_file);
            sample  = fullfile(spath,'w1d_sqw.sqw');
            
            to = faccess_sqw_v2(sample);
            
            data_h = to.get_data('-he');
            assertTrue(isstruct(data_h))
            assertEqual(data_h.filename,to.filename)
            assertEqual(data_h.filepath,to.filepath)
            
            data_dnd = to.get_data('-ver','-nopix');
            assertTrue(isa(data_dnd,'data_sqw_dnd'));
            assertEqual(data_dnd.filename,'ei140.sqw');
            
            data = to.get_data('-ver',1,20);
            assertEqual(data.filename,data_dnd.filename)
            assertEqual(data.filepath,data_dnd.filepath)
            assertEqual(size(data.pix),[9,20]);
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
                'C:\Russell\PCMO\ARCS_Oct10\Data\SQW\')
        end
        %
        function obj = test_put_sqw(obj)
            spath = fileparts(obj.sample_file);
            samplef  = fullfile(spath,'w2d_qq_small_sqw.sqw');
            
            
            ts = faccess_sqw_v2(samplef);
            tob_sqw = ts.get_sqw('-verbatim');
            
            tt = faccess_sqw_v2();
            
            tf = fullfile(tempdir,'test_put_sqw_v2.sqw');
            clob = onCleanup(@()delete(tf));
            
            tt = tt.init(tob_sqw);
            tt = tt.set_file_to_write(tf);
            
            
            tt=tt.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tt.delete();
            %
            sz1 = obj.fl_size(samplef);
            sz2 = obj.fl_size(tf);
            %
            assertEqual(sz1,sz2);
            %
            tn = faccess_sqw_v2(tf);
            rec_sqw = tn.get_sqw('-ver');
            tn.delete();
            %
            assertEqual(struct(tob_sqw),struct(rec_sqw));
            %
        end
        %
        function obj = test_upgrade_sqw(obj)
            spath = fileparts(obj.sample_file);
            samplef  = fullfile(spath,'w2d_qq_small_sqw.sqw');
            
            
            tf = fullfile(tempdir,'test_upgrade_sqwV2.sqw');
            clob = onCleanup(@()delete(tf));
            copyfile(samplef,tf);
            
            tob = faccess_sqw_v2(tf);
            tob = tob.upgrade_file_format();
            assertTrue(isa(tob,'faccess_sqw_v3'));
            
            
            sqw1 = tob.get_sqw();
            
            tob.delete();
            
            to = sqw_formats_factory.instance().get_loader(tf);
            assertTrue(isa(to,'faccess_sqw_v3'));
            
            sqw2 = to.get_sqw();
            
            assertEqual(sqw1,sqw2);
            to.delete();
            %
        end
        function obj = test_upgrade_sqw_wac(obj)
            %
            spath = fileparts(obj.sample_file);
            samplef  = fullfile(spath,'w2d_qq_small_sqw.sqw');
            
            sqwob = read_sqw(samplef);
            
            tf = fullfile(tempdir,'test_upgrade_sqwV2_wac.sqw');
            clob = onCleanup(@()delete(tf));
            tob = faccess_sqw_v2(sqwob,tf);
            tob = tob.put_sqw();
            
            tobV3 = tob.upgrade_file_format();
            assertTrue(isa(tobV3,'faccess_sqw_v3'));
            
            
            sqw1 = tobV3.get_sqw();
            
            tob.delete();
            tobV3.delete();
            
            to = sqw_formats_factory.instance().get_loader(tf);
            assertTrue(isa(to,'faccess_sqw_v3'));
            
            sqw2 = to.get_sqw();
            to.delete();           
            
            assertEqual(sqw1,sqw2);
            [ok,mess]=equal_to_tol(sqwob,sqw2,'ignore_str',true);
            assertTrue(ok,mess)
            
            %
        end
        
        
    end
end


