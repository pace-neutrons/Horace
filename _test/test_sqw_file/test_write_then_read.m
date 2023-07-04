classdef test_write_then_read < TestCase & common_sqw_file_state_holder

    properties
        old_warn_state;

        small_page_size = 5e5;  % 1Mb, chosen since the file below is ~1.8 MB.
        test_sqw_file_path = '../common_data/sqw_2d_1.sqw';
        npixels_in_file = 24689;
    end

    methods

        function obj = test_write_then_read(~)
            obj = obj@TestCase('test_write_then_read');

        end


        function test_sqw_with_paged_pix_saved_is_eq_to_original_with_all_pix(obj)
            sqw_obj = sqw(obj.test_sqw_file_path, ...
                'file_backed', true);
            assertFalse(sqw_obj.main_header.creation_date_defined);

            [file_cleanup, out_file_path] = obj.save_temp_sqw(sqw_obj);

            saved_sqw = sqw(out_file_path);
            assertTrue(saved_sqw.main_header.creation_date_defined);

            sqw_obj.main_header.creation_date = saved_sqw.main_header.creation_date;
            assertEqualToTol(saved_sqw, sqw_obj,1.e-9,'ignore_str', true);
        end

        function test_saved_sqw_with_paged_pix_equal_to_original_sqw(obj)
            sqw_obj = sqw(obj.test_sqw_file_path, ...
                'file_backed', true);
            assertFalse(sqw_obj.main_header.creation_date_defined);

            [file_cleanup, out_file_path] = obj.save_temp_sqw(sqw_obj);

            saved_sqw = sqw(out_file_path);
            assertTrue(saved_sqw.main_header.creation_date_defined);

            sqw_obj.main_header.creation_date = saved_sqw.main_header.creation_date;
            assertEqualToTol(saved_sqw, sqw_obj,1.e-9,'ignore_str', true);
        end

        function test_sqw_w_paged_pix_saved_correctly_with_small_mem_chunk_size(obj)
            conf_cleanup = set_temporary_config_options(...
                hor_config(), ...
                'mem_chunk_size', floor(obj.npixels_in_file/2) ...
                );
            sqw_obj = sqw(obj.test_sqw_file_path, ...
               'file_backed', true);
            assertFalse(sqw_obj.main_header.creation_date_defined);

            [file_cleanup, out_file_path] = obj.save_temp_sqw(sqw_obj);

            saved_sqw = sqw(out_file_path);
            assertTrue(saved_sqw.main_header.creation_date_defined);

            sqw_obj.main_header.creation_date = saved_sqw.main_header.creation_date;
            assertEqualToTol(saved_sqw, sqw_obj,1.e-9,'ignore_str', true);
        end

    end

    methods (Static)

        function [cleanup, file_path] = save_temp_sqw(obj_to_save)
            dbst = dbstack();
            % get the name of the function that called this one and use it as the
            % temp file name
            test_name = dbst(2).name;
            file_path = fullfile(tmp_dir(), [test_name, '.sqw']);
            save(obj_to_save, file_path);

            function del_temp_file(tmp_file_path)
                if is_file(tmp_file_path)
                    open_fids = fopen('all');
                    for i = 1:numel(open_fids)
                        fpath = fopen(open_fids(i));
                        if strcmp(fpath, tmp_file_path)
                            fclose(open_fids(i));
                        end
                    end
                    delete(tmp_file_path);
                end
            end

            cleanup = onCleanup(@() del_temp_file(file_path));
        end

    end

end
