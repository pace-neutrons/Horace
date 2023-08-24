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
                contents = textscan(tline ,'%9d %11.5f %11.5f %11.5f  %11.5f  %11.5f');
                obj.det_energy(k) = contents{6};
            end
            wkdir = obj.working_dir;
            sqw_file= fullfile(wkdir,'test_gen_sqw_indirect.sqw');
            obj.sqw_file = sqw_file;

            data_file = fullfile(obj.data_path,'MushroomSingleDE.nxspe');

            gen_sqw (data_file, '', sqw_file, obj.det_energy,...
                2, [2*pi,2*pi,2*pi], [90,90,90], [0,0,1], [0,-1,0],0,0,0,0,0);

        end
        function delete(obj)
            if is_file(obj.sqw_file)
                delete(obj.sqw_file)
            end
        end

        % tests
        function obj = test_read_write_upgrade_sqw(obj)
            % mushrum file had been generated in recent file  format -- the
            % preference for indirect

            sqw_obj = read_sqw(obj.sqw_file);
            %--------------------------------------------------------------
            % we can get proper sqw object
            pix_range = sqw_obj.pix.pix_range;
            assertFalse(any(any(pix_range == PixelDataBase.EMPTY_RANGE_)));
            data_range = sqw_obj.pix.data_range;
            assertFalse(any(any(data_range == PixelDataBase.EMPTY_RANGE)));


            % we can save the object as previous version of the file
            test_file=fullfile(obj.working_dir,'test_read_wr_upd_indirect_v3_2.sqw');
            co2 = onCleanup(@()del_memmapfile_files(test_file));
            save(sqw_obj,test_file,faccess_sqw_v3_2());


            ldr =sqw_formats_factory.instance().get_loader(test_file);
            assertTrue(isa(ldr,'faccess_sqw_v3_2'));
            %--------------------------------------------------------------
            % we can upgrade previous version of the file into new file
            % format, containing pixel range
            ldr = ldr.upgrade_file_format();

            assertTrue(isa(ldr,'faccess_sqw_v4'));

            pix_range1 = ldr.get_pix_range();
            % 3e-7 -- conversion from double to single
            assertTrue(all(all(abs(pix_range - pix_range1)<3.e-7)));
            ldr.delete();
            %--------------------------------------------------------------
            % the file has been upgraded properly
            ldr =sqw_formats_factory.instance().get_loader(test_file);

            sqw1 = ldr.get_sqw();
            ldr.delete();
            % old format object always recover w of the projection (from
            % u_to_rlu matrix) as non-empty vector. Make it empty; here the
            % projection units are 'aaa' so no problem with projection
            % recovery.
            sqw1.data.proj.w=[];
            % the recovered sqw object is equivalent to the generated sqw
            % object. Detpar accuacy is 5 digits

            assertEqualToTol(sqw1,sqw_obj,1e-5,'ignore_str',true)
        end
        %

    end
end
