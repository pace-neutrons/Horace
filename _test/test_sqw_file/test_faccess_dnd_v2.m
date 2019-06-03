classdef test_faccess_dnd_v2< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    % $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
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
            
            this.sample_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))),'test_symmetrisation');
            this.sample_file = fullfile(this.sample_dir,'w2d_qq_d2d.sqw');
            
        end
        
        % tests
        function obj = test_should_load_stream(obj)
            to = faccess_dnd_v2();
            co = onCleanup(@()to.fclose());
            
            
            [stream,fid] = to.get_file_header(obj.sample_file);
            [ok,initob] = to.should_load_stream(stream,fid);
            co1 = onCleanup(@()fclose(initob.file_id));

            assertTrue(ok);
            assertTrue(initob.file_id>0);
            
            
            
        end
        function obj = test_should_load_file(obj)
            to = faccess_dnd_v2();
            assertEqual(to.file_version,'-v2');
            
            [ok,initobj] = to.should_load(obj.sample_file);
            co1 = onCleanup(@()fclose(initobj.file_id));

            
            assertTrue(ok);
            assertTrue(initobj.file_id>0);
            
        end
        
        function obj = test_init(obj)
            to = faccess_dnd_v2();
            
            % access to incorrect object
            f = @()(to.init());
            assertExceptionThrown(f,'SQW_FILE_IO:invalid_argument');
            
            
            [ok,initob] = to.should_load(obj.sample_file);
            co1 = onCleanup(@()obj.fcloser(initob.file_id));
            
            
            assertTrue(ok);
            assertTrue(initob.file_id>0);
            
            
            to = to.init(initob);
            
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
            
            assertEqual(struct(tob_dnd),struct(rec_dnd));
            
        end
        %
%         function obj = test_block_sizes(obj)
%             tob = dnd_binfile_common();
%             
%             samp = fullfile(fileparts(obj.test_folder),...
%                 'test_symmetrisation','w1d_d1d.sqw');
%             
%             tob=tob.init(samp);
%             
%             assertFalse(tob.sqw_type)
%             assertEqual(tob.num_dim,1)
% 
%             td1d = tob.get_sqw();
% 
%             td1d.alatt = td1d.alatt*1.1;
%             test_file = fullfile(tempdir,'test_block_sizes_dnd.sqw');
%             clob = onCleanup(@()delete(test_file));
%             
%             whl = faccess_dnd_v2(td1d,test_file);
%             whl = whl.put_sqw();
%             whl.delete();
% 
%             other_tob = faccess_dnd_v2(test_file);
%             
%             ok = tob.check_upgrade(other_tob);
%             assertTrue(ok)
% 
%             other_tob.delete();
%         end        
        
    end
end


