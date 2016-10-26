classdef test_faccess_sqw_v2< TestCase
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
            co = onCleanup(@()to.close());
            
            
            [stream,fid] = to.get_file_header(obj.sample_file);
            [ok,to] = to.should_load_stream(stream,fid);
            assertTrue(ok);
            assertEqual(to.file_version,'-v2');
            
            
            
        end
        function obj = test_should_load_file(obj)
            to = faccess_sqw_v2();
            co = onCleanup(@()to.close());
            
            [ok,to] = to.should_load(obj.sample_file);
            assertTrue(ok);
            assertEqual(to.file_version,'-v2');
            
        end
        
        function obj = test_init(obj)
            to = faccess_sqw_v2();
            
            % access to incorrect object
            f = @()(to.init());
            assertExceptionThrown(f,'FACCESS_SQW_COMMON:runtime_error');
            
            
            [ok,to] = to.should_load(obj.sample_file);
            
            assertTrue(ok);
            assertEqual(to.file_version,'-v2');
            
            
            to = to.init();
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
            
            data_dnd = to.get_data('-hver','-nopix');
            assertTrue(isa(data_dnd,'data_sqw_dnd'));
            assertEqual(data_dnd.filename,'ei140.sqw');
            
            data = to.get_data('-hver',1,20);
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
        
    end
end


