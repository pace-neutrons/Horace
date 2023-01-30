classdef test_PixelDataFile < TestCase %& common_pix_class_state_holder

    properties
        sample_dir;
        sample_file;
    end

    methods

        function obj = test_PixelDataFile(~)
            obj = obj@TestCase('test_PixelDataFile');
            hc = horace_paths;
            obj.sample_dir = hc.test_common;
            obj.sample_file  = fullfile(obj.sample_dir,'w2d_qe_sqw.sqw');
        end
        function test_get_raw_pix(obj)
            sw = warning('off','HORACE:old_file_format');
            clOb = onCleanup(@()warning(sw));

            df = PixelDataFileBacked(obj.sample_file);
            assertEqual(df.num_pixels,107130)

            dfm = PixelDataMemory(obj.sample_file);
            pix_data_f = df.get_pixels([1,20,100,1000,107130],'-raw_data');
            pix_data_m = dfm.get_pixels([1,20,100,1000,107130],'-raw_data');

            assertTrue(isnumeric(pix_data_f))
            assertEqual(pix_data_f ,pix_data_m );
        end
        

        function test_get_pix(obj)
            sw = warning('off','HORACE:old_file_format');
            clOb = onCleanup(@()warning(sw));

            df = PixelDataFileBacked(obj.sample_file);
            assertEqual(df.num_pixels,107130)

            dfm = PixelDataMemory(obj.sample_file);
            pix_data_f = df.get_pixels(10:2:100);
            pix_data_m = dfm.get_pixels(10:2:100);

            assertEqual(pix_data_f ,pix_data_m );
        end


        function test_serialize_deserialize_full(obj)
            sw = warning('off','HORACE:old_file_format');
            clOb = onCleanup(@()warning(sw));

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
        %
        function test_construct_from_data_loader_check_advance(obj)
            sw = warning('off','HORACE:old_file_format');
            clObW = onCleanup(@()warning(sw));

            hc = hor_config;
            mem_ch = hc.mem_chunk_size;
            clOb = onCleanup(@()set(hc,'mem_chunk_size',mem_ch));

            mchs =10000;
            hc.mem_chunk_size = mchs;

            ldr = sqw_formats_factory.instance().get_loader(obj.sample_file);
            assertTrue(PixelDataBase.do_filebacked(ldr.npixels));

            pdf = PixelDataFileBacked(obj.sample_file);

            np = pdf.num_pages;
            for i=1:np
                read_start = (i-1)*mchs+1;
                assertEqual(pdf.page_num,i)
                bl_size    = mchs;
                if read_start+bl_size>ldr.npixels
                    bl_size = ldr.npixels-read_start+1;
                end
                assertTrue(pdf.has_more)
                ref_data = double(ldr.get_pix_in_ranges(read_start,bl_size));
                check_data = pdf.data;
                assertEqual(check_data,ref_data);
                pdf = pdf.advance;
            end
            assertFalse(pdf.has_more)


            ldr.delete();
        end

        function test_construct_from_data_loader_check_pages(obj)
            sw = warning('off','HORACE:old_file_format');
            clObW = onCleanup(@()warning(sw));

            hc = hor_config;
            mem_ch = hc.mem_chunk_size;
            clOb = onCleanup(@()set(hc,'mem_chunk_size',mem_ch));

            mchs =10000;
            hc.mem_chunk_size = mchs;

            ldr = sqw_formats_factory.instance().get_loader(obj.sample_file);
            assertTrue(PixelDataBase.do_filebacked(ldr.npixels));

            pdf = PixelDataFileBacked(ldr);

            ref_data = double(ldr.get_pix_in_ranges(1,mchs));

            assertEqual(pdf.data,ref_data);

            pdf.page_num=11;
            ref_data = double(ldr.get_pix_in_ranges(10*mchs+1,ldr.npixels-10*mchs));
            assertEqual(pdf.data,ref_data);

            ldr.delete();
        end
        function test_empty_constructor(~)
            hc = hor_config;
            pdf = PixelDataFileBacked();
            assertEqual(pdf.page_size,hc.mem_chunk_size);
            assertTrue(pdf.is_filebacked);

            assertTrue(isempty(pdf.u1))
            assertEqual(size(pdf.u1),[1,0])
            assertEqual(size(pdf.q_coordinates),[3,0])
            assertEqual(size(pdf.coordinates),[4,0])
            assertEqual(pdf.pix_range,PixelDataBase.EMPTY_RANGE_)
            assertEqual(pdf.data_range,PixelDataBase.EMPTY_RANGE)
        end
    end
end
