classdef test_faccess_sqw_v3_21< TestCase
    %
    % Test mushrum file format and their relationship
    
    properties
        % properties to use as input for data
        data_path;
        working_dir
        det_energy;
        sqw_file
    end
    
    methods
        
        %The above can now be read into the test routine directly.
        function obj=test_faccess_sqw_v3_21(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            obj=obj@TestCase(name);
            data_path= fullfile(fileparts(fileparts(mfilename('fullpath'))),...
                'test_sqw_class','data');
            obj.data_path = data_path;
            
            hc = hor_config;
            obj.working_dir = hc.working_directory;
            
            %------------------------------------------------------------
            ef_file = fullfile(data_path,'det_positions.dat');
            % e-fixed
            %------------------------------------------------------------
            fid = fopen(ef_file,'r');
            clOb = onCleanup(@()fclose(fid));
            tline = fgets(fid);
            tline = fgets(fid);
            n_det = textscan(tline,'%d10');
            n_det = n_det{1};
            tline = fgets(fid);
            obj.det_energy = zeros(1,n_det );
            for k=1:n_det
                tline = fgets(fid);
                Cont = textscan(tline ,'%9d %11.5f %11.5f %11.5f  %11.5f  %11.5f');
                obj.det_energy(k) = Cont{6};
            end
            wkdir = obj.working_dir;
            sqw_file= fullfile(wkdir,'test_gen_sqw_indirect.sqw');
            obj.sqw_file = sqw_file;
            
            data_file = fullfile(obj.data_path,'MushroomSingleDE.nxspe');
            
            gen_sqw (data_file, '', sqw_file, obj.det_energy,...
                2, [2*pi,2*pi,2*pi], [90,90,90], [0,0,1], [0,-1,0],0,0,0,0,0);
            
        end
        function delete(obj)
            obj.delete_files(obj.sqw_file)
        end
        
        % tests
        function obj = test_read_write_updata_sqw(obj)
            % mushrum file had been generated in v3_21 format -- the
            % preference for indirect
            fl_acc = faccess_sqw_v3_21();
            assertEqual(fl_acc.file_version,'-v3.21');
            co = onCleanup(@()fl_acc.delete());
            
            [stream,fid] = fl_acc.get_file_header(obj.sqw_file);
            [ok,initobj] = fl_acc.should_load_stream(stream,fid);
            co1 = onCleanup(@()fclose(initobj.file_id));
            assertTrue(ok);
            assertTrue(initobj.file_id>0);
            % we can read and access these data using loader v3.21
            fl_acc = fl_acc.init(initobj);
            
            sqw_obj = fl_acc.get_sqw();
            pix_range = sqw_obj.data.pix.pix_range;
            assertFalse(any(pix_range == PixelData.EMPTY_RANGE_));
            
            
            assertTrue(isa(sqw_obj,'sqw'));
            assertEqual(sqw_obj.main_header.filename,fl_acc.filename)
            assertEqual(sqw_obj.main_header.filepath,fl_acc.filepath)
            
            test_file=fullfile(obj.working_dir,'test_read_wr_upd_indirect.sqw');
            co2 = onCleanup(@()delete(test_file));
            save(sqw_obj,test_file,faccess_sqw_v3_2());
            
            ldr =sqw_formats_factory.instance().get_loader(test_file);
            assertTrue(isa(ldr,'faccess_sqw_v3_2'));
            
            ldr = ldr.upgrade_file_format();
            
            assertTrue(isa(ldr,'faccess_sqw_v3_21'));
            
            pix_range1 = ldr.get_pix_range();
            assertTrue(all(pix_range == pix_range1));
            ldr.delete();
        end
        %
        
    end
end

