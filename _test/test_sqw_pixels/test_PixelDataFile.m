classdef test_PixelDataFile < TestCase & common_pix_class_state_holder

    properties
        sample_dir;
        sample_file;
        stored_config
    end

    methods

        function obj = test_PixelDataFile(~)
            obj = obj@TestCase('test_PixelDataFile');
            pths = horace_paths;
            obj.sample_dir = pths.test_common;
            obj.sample_file  = fullfile(obj.sample_dir,'w2d_qe_sqw.sqw');
        end

        function test_get_raw_pix(obj)
            clOb = set_temporary_warning('off','HORACE:old_file_format');

            df = PixelDataFileBacked(obj.sample_file);
            assertEqual(df.num_pixels,107130)

            dfm = PixelDataMemory(obj.sample_file);
            pix_data_f = df.get_pixels([1,20,100,1000,107130],'-raw_data');
            pix_data_m = dfm.get_pixels([1,20,100,1000,107130],'-raw_data');

            assertTrue(isnumeric(pix_data_f))
            assertEqual(pix_data_f ,pix_data_m );
        end

        function test_filebacked_pixels_from_data(~)
            data = rand(9,1000);
            pd = PixelDataFileBacked(data);
            assertEqualToTol(pd.data,data,3.e-7)

            pdm = PixelDataMemory(pd);

            assertEqual(pdm.data,pd.data);
            pdm.signal = 1:1000;
            pd.signal = 1:1000;

            assertEqual(pdm.signal,pd.signal);
            assertEqual(pdm.data,pd.data);
        end

        function test_get_pix(obj)
            clOb = set_temporary_warning('off','HORACE:old_file_format');

            df = PixelDataFileBacked(obj.sample_file);
            assertEqual(df.num_pixels,107130)

            dfm = PixelDataMemory(obj.sample_file);
            pix_data_f = df.get_pixels(10:2:100);
            pix_data_m = dfm.get_pixels(10:2:100);

            assertEqual(pix_data_f ,pix_data_m );
        end


        function test_serialize_deserialize_full(obj)
            clOb = set_temporary_warning('off','HORACE:old_file_format');

            df = PixelDataFileBacked(obj.sample_file);
            assertEqual(df.num_pixels,107130)
            df_struc = df.to_struct();

            df_rec = serializable.from_struct(df_struc);
            assertEqual(df,df_rec);
        end

        function test_serialize_deserialize_empty(~)
            df = PixelDataFileBacked();
            df_struc = df.to_struct();

            df_rec = serializable.from_struct(df_struc);
            assertEqual(df,df_rec);
        end

        function test_construct_from_faccessor_keep_tail(obj)

            mchs = 10000;
            clOb = set_temporary_config_options(hor_config, 'mem_chunk_size', mchs, 'log_level', -1);

            wkf = fullfile(tmp_dir,'pix_data_with_tail.sqw');
            clObF = onCleanup(@()file_delete(wkf));
            copyfile(obj.sample_file,wkf,'f');


            ldr = sqw_formats_factory.instance().get_loader(wkf);
            ldr = ldr.upgrade_file_format();
            assertTrue(PixelDataBase.do_filebacked(ldr.npixels));
            ldr.delete();

            pdf = PixelDataFileBacked(wkf);
            pdf_copy = PixelDataFileBacked(pdf);

            for i=1:pdf.num_pages
                pdf.page_num = i;
                pdf_copy.page_num = i;
                assertEqual(pdf.page_num, i)

                assertEqual(pdf.data,pdf_copy.data);
            end
            pdf.delete();
            pdf_copy.delete();
        end

        function test_construct_from_data_loader_check_advance_with_tail(obj)

            mchs = 10000;
            clOb = set_temporary_config_options(hor_config, 'mem_chunk_size', mchs, 'log_level', -1);

            wkf = fullfile(tmp_dir,'pix_data_with_tail.sqw');
            clObF = onCleanup(@()file_delete(wkf));
            copyfile(obj.sample_file,wkf,'f');

            ldr = sqw_formats_factory.instance().get_loader(wkf);
            ldr = ldr.upgrade_file_format();
            assertTrue(PixelDataBase.do_filebacked(ldr.npixels));

            pdf = PixelDataFileBacked(wkf);

            for i=1:pdf.num_pages
                pdf.page_num = i;
                assertEqual(pdf.page_num, i)

                [pix_idx_start, pix_idx_end] = pdf.get_page_idx_;
                pix_to_read = pix_idx_end - pix_idx_start + 1;

                ref_data = double(ldr.get_pix_in_ranges(pix_idx_start,pix_to_read));

                assertEqual(pdf.data,ref_data);
            end
            pdf.delete();
            ldr.delete();
        end

        function test_construct_from_data_loader_check_advance(obj)
            clobW = set_temporary_warning('off','HORACE:old_file_format');

            mchs = 10000;
            clOb = set_temporary_config_options(hor_config, 'mem_chunk_size', mchs, 'log_level', -1);

            ldr = sqw_formats_factory.instance().get_loader(obj.sample_file);
            assertTrue(PixelDataBase.do_filebacked(ldr.npixels));

            pdf = PixelDataFileBacked(obj.sample_file);

            for i=1:pdf.num_pages
                pdf.page_num = i;
                assertEqual(pdf.page_num, i)

                [pix_idx_start, pix_idx_end] = pdf.get_page_idx_;
                pix_to_read = pix_idx_end - pix_idx_start + 1;

                ref_data = double(ldr.get_pix_in_ranges(pix_idx_start,pix_to_read));

                assertEqual(pdf.data,ref_data);
            end

            ldr.delete();
        end

        function test_construct_from_data_loader_check_pages(obj)
            clObW = set_temporary_warning('off','HORACE:old_file_format');

            mchs = 10000;
            clOb = set_temporary_config_options(hor_config, 'mem_chunk_size', mchs, 'log_level', -1);

            ldr = sqw_formats_factory.instance().get_loader(obj.sample_file);
            assertTrue(PixelDataBase.do_filebacked(ldr.npixels));

            pdf = PixelDataFileBacked(ldr);

            pdf.page_num = 1;

            ref_data = double(ldr.get_pix_in_ranges(1,mchs));

            assertEqual(pdf.data,ref_data);

            pdf.page_num=11;
            ref_data = double(ldr.get_pix_in_ranges(10*mchs+1,ldr.npixels-10*mchs));
            assertEqual(pdf.data,ref_data);

            ldr.delete();
        end

        function test_empty_constructor(~)
            pdf = PixelDataFileBacked();
            assertEqual(pdf.page_size,0);
            assertTrue(pdf.is_filebacked);

            assertTrue(isempty(pdf.u1))
            assertEqual(size(pdf.u1),[1,0])
            assertEqual(size(pdf.q_coordinates),[3,0])
            assertEqual(size(pdf.coordinates),[4,0])
            assertEqual(pdf.pix_range,PixelDataBase.EMPTY_RANGE_)
            assertEqual(pdf.data_range,PixelDataBase.EMPTY_RANGE)
        end
        function test_tail(~)
            wkdir = tmp_dir();
            tmp_file = fullfile(wkdir,'test_tail.bin');
            clOb = onCleanup(@()del_memmapfile_files(tmp_file));

            npix = 200;
            ncols = 9;
            data = rand(ncols,npix);
            tail_size = 100;
            [offset,tail_pos]=test_PixelDataFile.write_test_pix_data(tmp_file,data,tail_size);

            data_size = size(data);
            format1 = {'single',data_size,'data'};
            fh1 = memmapfile(tmp_file,'format', format1,'Repeat', 1, ...
                'Writable', true,'offset', offset);
            pix_data = fh1.Data.data(:,1:npix);
            assertEqual(pix_data,single(data));

            format2 = {'single',data_size,'data';'uint8',4*double(tail_size),'tail'};
            fh2 = memmapfile(tmp_file,'format', format2,'Repeat', 1, ...
                'Writable', true,'offset', offset);
            pix_data2 = fh2.Data.data(:,1:npix);
            assertEqual(pix_data2,single(data));
            clear('fh2');
            clear('fh1');
        end
    end
    methods(Static,Access=private)
        function [data_pos,tail_pos] = write_test_pix_data(filename,data,tail_size)
            fh = fopen(filename,'wb+');
            if fh<1
                error('HORACE:test','can not open test file');
            end
            clOb = onCleanup(@()fclose(fh));
            datasize  = size(data);
            fwrite(fh,datasize,'float32');
            data_pos = ftell(fh);
            fwrite(fh,data,'float32');
            tail_pos = ftell(fh);
            tail = 1:tail_size;
            fwrite(fh,tail,'float32');
        end
    end
end
