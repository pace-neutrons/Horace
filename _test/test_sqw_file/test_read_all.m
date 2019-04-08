classdef test_read_all< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    % $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
    %
    
    
    properties
        sample_dir;
        sample_file;
    end
    methods(Static)
        function varargout = interface2tst(varargin)
            nout = nargout;
            nin = nargin;
            varargout = pack_io_outputs(varargin,nin,nout);
        end
        
    end
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_read_all(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this=this@TestCase(name);
            
            this.sample_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))));
            this.sample_file = fullfile(this.sample_dir,'test_symmetrisation','w2d_qq_d2d.sqw');
            
        end
        
        % tests
        function obj = test_outputs(obj)
            tobj = {sqw(),sqw()};
            out = test_read_all.interface2tst(tobj);
            assertTrue(iscell(out))
            assertTrue(isa(out{1},'sqw'));
            assertEqual(numel(out),2);
            
            out = test_read_all.interface2tst(tobj{:});
            assertFalse(iscell(out))
            assertEqual(numel(out),2)
            assertTrue(isa(out,'sqw'));
            
            [out1,out2] = test_read_all.interface2tst(tobj{:});
            assertTrue(isa(out1,'sqw'));
            assertTrue(isa(out2,'sqw'));
            
            tobj = {sqw(),d1d(),sqw()};
            [out1,out2,out3] = test_read_all.interface2tst(tobj{:});
            assertTrue(isa(out1,'sqw'));
            assertTrue(isa(out2,'d1d'));
            assertTrue(isa(out3,'sqw'));
            
            out = test_read_all.interface2tst(tobj{:});
            assertTrue(iscell(out))
            assertEqual(numel(out),3);
            assertTrue(isa(out{2},'d1d'));
            
            
            out = test_read_all.interface2tst(tobj);
            assertTrue(iscell(out))
            assertEqual(numel(out),3);
            assertTrue(isa(out{2},'d1d'));
        end
        
        function obj = test_read_horace(obj)
            warning('off','SQW_FILE_IO:legacy_data');
            clob = onCleanup(@()warning('on','SQW_FILE_IO:legacy_data'));
            
            out = read_horace(obj.sample_file);
            assertTrue(isa(out,'d2d'));
            assertFalse(iscell(out));
            assertEqual(numel(out),1);
            
            
            files = {fullfile(obj.sample_dir,'test_sqw_file','test_sqw_file_read_write_v3_1.sqw'),...
                fullfile(obj.sample_dir,'test_sqw_file','test_sqw_file_read_write_v3.sqw')};
            out = read_sqw(files);
            
            assertEqual(numel(out),2);
            assertFalse(iscell(out));
            assertTrue(isa(out,'sqw'));
            
            
            files = {fullfile(obj.sample_dir,'test_sqw_file','test_sqw_file_read_write_v3_1.sqw'),...
                fullfile(obj.sample_dir,'test_sqw_file','test_sqw_file_read_write_v3.sqw'),...
                obj.sample_file};
            out = read_horace(files);
            
            assertEqual(numel(out),3);
            assertTrue(iscell(out));
            assertTrue(isa(out{1},'sqw'));
            assertTrue(isa(out{3},'d2d'));
        end
        function obj = test_head(obj)
            warning('off','SQW_FILE_IO:legacy_data');
            clob = onCleanup(@()warning('on','SQW_FILE_IO:legacy_data'));
            
            files = {fullfile(obj.sample_dir,'test_sqw_file','test_sqw_file_read_write_v3_1.sqw'),...
                fullfile(obj.sample_dir,'test_sqw_file','test_sqw_file_read_write_v3.sqw'),...
                obj.sample_file};
            
            out = head_sqw(files);
            %head_sqw(files);
            
            assertEqual(numel(out),3)
            assertTrue(isstruct(out{1}))
            assertEqual(numel(fields(out{1})),20)
            assertTrue(isstruct(out{2}))
            assertEqual(numel(fields(out{2})),20)
            assertTrue(isstruct(out{3}))
            assertEqual(numel(fields(out{3})),14)
            
            [out1,out2,out3] = head_horace(files,'-full');
            assertEqual(numel(fields(out1)),4)
            assertEqual(numel(fields(out2)),4)
            assertEqual(numel(fields(out3)),17)
            
            
            out = head_dnd(obj.sample_file);
            assertTrue(isstruct(out))
            assertEqual(numel(fields(out)),14)
            
            out4 = head_horace(obj.sample_file);
            assertTrue(isstruct(out4))
            assertEqual(numel(fields(out4)),14)
            assertEqual(out,out4);
            
            tsw = sqw();
            files = {fullfile(obj.sample_dir,'test_sqw_file','test_sqw_file_read_write_v3_1.sqw'),...
                fullfile(obj.sample_dir,'test_sqw_file','test_sqw_file_read_write_v3.sqw')};
            
            [out1a,out2a] = head(tsw,files,'-full');
            assertEqual(out1,out1a)
            assertEqual(out2,out2a)
            
            out3a = head(tsw,files{1},'-full');
            assertEqual(out1,out3a)
            
            outc = head(tsw,files,'-full');
            assertEqual(numel(outc),1)
            assertEqual(outc,out1)
            
        end
        
    end
end


