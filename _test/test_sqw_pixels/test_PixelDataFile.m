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
        %
        function test_construct_from_data_loader_check_advance(obj)
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
                    assertFalse(pdf.has_more)
                else
                    assertTrue(pdf.has_more)
                end
                ref_data = double(ldr.get_pix_in_ranges(read_start,bl_size));
                check_data = pdf.data;
                assertEqual(check_data,ref_data);
                pdf = pdf.advance;
            end

            ref_data = double(ldr.get_pix_in_ranges(10*mchs+1,ldr.npixels-10*mchs));
            assertEqual(pdf.data,ref_data);

            ldr.delete();
        end

        function test_construct_from_data_loader_check_pages(obj)
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
