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
        function file_delete(~,filename)
            if ~is_file(filename)
                return;
            end
            ws = warning('off','');
            wsClob = onCleanup(@()warning(ws));
            if ispc
                comm = sprintf('del %s',filename);
            else
                comm = sprintf('rm %s',filename);
            end
            for i=1:100
                delete(filename);
                [~,wid] = lastwarn;
                if ~strcmp(wid,'MATLAB:DELETE:Permission')
                    break;
                end
                system(comm);
                lastwarn('file have not been deleted','HORACE:test_file_deletion');
                pause(0.1);
            end
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
        function test_pix_alignment_set(~)
            pix_data = zeros(9,6);
            pix_data(1:4,1:4) = eye(4);
            pix_data(1:4,5)  = ones(4,1);
            pdm = PixelDataFileBacked(pix_data);

            initial_range = pdm.data_range;

            % this actually changes pixel_data_range!
            al_matr = rotvec_to_rotmat2([pi/4,0,0]);
            pdm.alignment_matr = al_matr ;

            al_data = pdm.data;
            assertFalse(all(pix_data(:) == al_data(:)));
            raw_data = pdm.get_raw_data();
            assertElementsAlmostEqual(raw_data,pix_data);

            al_range = pdm.data_range;
            assertFalse(all(initial_range(:) == al_range(:)));
            assertFalse(pdm.is_range_valid);

            assertElementsAlmostEqual(al_data(1:3,1:3),al_matr);
            ref_range = PixelDataBase.EMPTY_RANGE(:,1:3);
            assertElementsAlmostEqual(al_range(:,1:3),ref_range);
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

        function test_construct_from_faccessor_keep_tail(obj)

            hc = hor_config;
            rcd = hc.get_data_to_store();
            clOb = onCleanup(@()set(hc,rcd));

            mchs = 10000;
            hc.mem_chunk_size = mchs;
            hc.log_level = -1;

            wkf = fullfile(tmp_dir,'pix_data_with_tail.sqw');
            clObF = onCleanup(@()file_delete(obj,wkf));
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

            hc = hor_config;
            rcd = hc.get_data_to_store();
            clOb = onCleanup(@()set(hc,rcd));

            mchs = 10000;
            hc.mem_chunk_size = mchs;
            hc.log_level = -1;

            wkf = fullfile(tmp_dir,'pix_data_with_tail.sqw');
            clObF = onCleanup(@()file_delete(obj,wkf));
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
            sw = warning('off','HORACE:old_file_format');
            clObW = onCleanup(@()warning(sw));

            hc = hor_config;
            rcd = hc.get_data_to_store();
            clOb = onCleanup(@()set(hc,rcd));

            mchs = 10000;
            hc.mem_chunk_size = mchs;
            hc.log_level = -1;

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
            sw = warning('off','HORACE:old_file_format');
            clObW = onCleanup(@()warning(sw));

            hc = hor_config;
            rcd = hc.get_data_to_store();
            clOb = onCleanup(@()set(hc,rcd));

            mchs = 10000;
            hc.mem_chunk_size = mchs;
            hc.log_level = -1;

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
            hc = hor_config;
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
    end
end
