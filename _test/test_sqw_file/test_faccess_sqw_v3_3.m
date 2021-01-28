classdef test_faccess_sqw_v3_3< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    
    properties
        sample_dir;
        sample_file;
    end
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_faccess_sqw_v3_3(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this=this@TestCase(name);
            
            this.sample_dir = fullfile(fileparts(mfilename('fullpath')));
            this.sample_file = fullfile(this.sample_dir,'test_sqw_file_read_write_v3_3.sqw');
            
        end
        
        % tests
        function obj = test_should_load_stream(obj)
            to = faccess_sqw_v3_3();
            assertEqual(to.file_version,'-v3.3');
            co = onCleanup(@()to.delete());
            
            
            [stream,fid] = to.get_file_header(obj.sample_file);
            [ok,initobj] = to.should_load_stream(stream,fid);
            co1 = onCleanup(@()fclose(initobj.file_id));
            assertTrue(ok);
            assertTrue(initobj.file_id>0);
            
        end
        %
        function obj = test_should_load_file(obj)
            to = faccess_sqw_v3_3();
            co = onCleanup(@()to.delete());
            
            [ok,initobj] = to.should_load(obj.sample_file);
            co1 = onCleanup(@()fclose(initobj.file_id));
            
            assertTrue(ok);
            assertTrue(initobj.file_id>0);
            
        end
        %
        function obj = test_init_wrong(obj)
            to = faccess_sqw_v3_3();
            
            % access to incorrect object
            f = @()(to.init());
            assertExceptionThrown(f,'SQW_FILE_IO:invalid_argument');
        end
        
        function obj = test_init_and_get(obj)
            to = faccess_sqw_v3_3();
            
            [ok,initobj] = to.should_load(obj.sample_file);
            assertTrue(ok);
            assertTrue(initobj.file_id>0);
            
            
            to = to.init(initobj);
            assertEqual(to.npixels,7680);
            assertEqual(to.num_contrib_files,1);
            
            
            mheader = to.get_main_header('-verbatim');
            assertEqual(numel(mheader.title),0);
            assertEqual(mheader.filename,'test_sqw_file_read_write_v3.sqw');
            assertEqual(mheader.filepath,...
                'C:\Users\abuts\Documents\developing_soft\Horace\_test\test_sqw_file\');
            
            header = to.get_header();
            assertEqual(header.filename,'')
            assertElementsAlmostEqual(header.psi,0.2967,'absolute',1.e-4);
            assertEqual(header.ulabel{4},'E')
            assertEqual(header.ulabel{3},'Q_\eta')
            
            det = to.get_detpar();
            assertEqual(det.filename,'')
            assertEqual(det.filepath,'.\')
            assertEqual(numel(det.group),96)
            
            data = to.get_data();
            assertEqual(data.pix.num_pixels,7680)
            assertEqual(size(data.s,1),numel(data.p{1})-1)
            assertEqual(size(data.e,2),numel(data.p{2})-1)
            assertEqual(size(data.npix,3),numel(data.p{3})-1)
            
        end
        %
        function obj = test_get_data(obj)
            to = faccess_sqw_v3_3(obj.sample_file);
            
            data_h = to.get_data('-he');
            assertTrue(isstruct(data_h))
            assertEqual(data_h.filename,to.filename)
            assertEqual(data_h.filepath,to.filepath)
            
            data_dnd = to.get_data('-verb','-nopix');
            assertTrue(isa(data_dnd,'data_sqw_dnd'));
            assertEqual(data_dnd.filename,'test_sqw_file_read_write_v3.sqw');
            
            data = to.get_data('-ver');
            assertEqual(data.filename,data_dnd.filename)
            assertEqual(data.filepath,data_dnd.filepath)
            assertTrue(isa(data.pix, 'PixelData'));
            assertEqual(data.pix.file_path, obj.sample_file);
            assertEqual(data.pix.num_pixels, 7680);
            
            raw_pix = to.get_pix(1,20);
            assertEqual(data.pix.get_pixels(1:20).data, raw_pix);
        end
        %
        function obj = test_get_inst_or_sample(obj)
            to = faccess_sqw_v3_3();
            to = to.init(obj.sample_file);
            
            inst = to.get_instrument('-all');
            samp = to.get_sample();
            assertTrue(isa(samp,'IX_sample'));
            
            inst1 = to.get_instrument(1);
            assertEqual(inst,inst1);
        end
        %
        function obj = test_get_sqw(obj)
            
            fo = faccess_sqw_v3_3();
            fo = fo.init(obj.sample_file);
            
            sqw_obj = fo.get_sqw();
            
            assertTrue(isa(sqw_obj,'sqw'));
            assertEqual(sqw_obj.main_header.filename,fo.filename)
            assertEqual(sqw_obj.main_header.filepath,fo.filepath)
            
            sqw_obj1 = fo.get_sqw('-hverbatim');
            assertTrue(isa(sqw_obj1,'sqw'));
            assertEqual(sqw_obj1.main_header.filename,'test_sqw_file_read_write_v3.sqw')
            assertEqual(sqw_obj1.main_header.filepath,...
                'C:\Users\abuts\Documents\developing_soft\Horace\_test\test_sqw_file\')
        end
        %
        function test_save_sqw2to3_3(obj)
            samp_f = fullfile(obj.sample_dir,...
                'test_sqw_file_read_write_v3.sqw');
            warning('off','SQW_FILE_IO:legacy_data');
            clob0 = onCleanup(@()warning('on','SQW_FILE_IO:legacy_data'));
            
            so = faccess_sqw_v2(samp_f);
            sqw_ob = so.get_sqw();
            
            ref_range = sqw_ob.data.img_range;
            
            assertTrue(isa(sqw_ob,'sqw'));
            % Create sample
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            %inst1=create_test_instrument(95,250,'s');
            %sqw_ob.header(1).instrument = inst1;
            sqw_ob.header(1).sample = sam1;
            
            
            tob = faccess_sqw_v3_3();
            tob = tob.init(sqw_ob);
            
            tf = fullfile(tmp_dir,'test_save_load_sqwV33.sqw');
            clob = onCleanup(@()delete(tf));
            
            tob = tob.set_file_to_update(tf);
            tob=tob.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tob=tob.delete();
            
            tob=tob.init(tf);
            assertEqual(tob.file_version,'-v3.3');
            img_range = tob.get_img_range();
            assertElementsAlmostEqual(ref_range,img_range)
            pix_range = tob.get_pix_range();
            assertElementsAlmostEqual(pix_range,img_range)
        end
        %
        function obj = test_save_load_sqwV3_3(obj)
            samp_f = fullfile(obj.sample_dir,...
                'test_sqw_file_read_write_v3_3.sqw');
            
            so = faccess_sqw_v3_3(samp_f);
            sqw_ob = so.get_sqw();
            ref_range = sqw_ob.data.img_range;
            
            assertTrue(isa(sqw_ob,'sqw'));
            
            inst1=create_test_instrument(95,250,'s');
            sqw_ob.header(1).instrument = inst1;
            
            tf = fullfile(tmp_dir,'test_save_load_sqwV3_3.sqw');
            clob = onCleanup(@()delete(tf));
            
            tob = faccess_sqw_v3_3();
            tob = tob.init(sqw_ob,tf);
            
            tob=tob.put_sqw();
            assertTrue(exist(tf,'file')==2)
            tob = tob.delete();
            
            tob=tob.init(tf);
            ver_obj =tob.get_sqw('-verbatim');
            tob.delete();
            
            assertEqual(ref_range,ver_obj.data.img_range);
            assertEqual(sqw_ob.main_header,ver_obj.main_header);
            assertEqual(sqw_ob,ver_obj);
        end
        
        %
        function test_serialize_deserialise_faccess(obj)
            fo = faccess_sqw_v3_3();
            fo = fo.init(obj.sample_file);
            
            by = hlp_serialize(fo);
            fr = hlp_deserialize(by);
            
            assertEqual(fo,fr);
        end
        %
        
    end
end


