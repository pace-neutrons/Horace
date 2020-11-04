classdef test_paged_read_and_write < TestCase

properties
    old_warn_state;

    small_page_size = 1e6;  % 1Mb
    test_sqw_file_path = '../test_sqw_file/sqw_1d_1.sqw';
end

methods

    function obj = test_paged_read_and_write(~)
        obj = obj@TestCase('test_pagedPixelData');

        % Swallow any warnings for when pixel page size set too small
        obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');
    end

    function delete(obj)
        warning(obj.old_warn_state);
    end

    function test_sqw_with_paged_pix_saved_is_eq_to_original_with_all_pix(obj)
        conf_cleanup = obj.set_temp_pix_page_size(obj.small_page_size);
        sqw_obj = sqw(obj.test_sqw_file_path);

        dbst = dbstack;
        test_name = dbst.name;
        out_file_path = fullfile(tmp_dir, test_name);
        file_cleanup = obj.save_temp_file(sqw_obj, out_file_path);

        % reset the config so we read the whole of the pixel array in one go
        clear conf_cleanup

        saved_sqw = sqw(out_file_path);
        assertTrue(equal_to_tol(saved_sqw, sqw_obj, 'ignore_str', true));
    end

    function test_sqw_with_paged_pix_not_on_1st_pg_saved_correctly_(obj)
        conf_cleanup = obj.set_temp_pix_page_size(obj.small_page_size);
        sqw_obj = sqw(obj.test_sqw_file_path);
        sqw_obj.data.pix.advance();

        dbst = dbstack;
        test_name = dbst.name;
        out_file_path = fullfile(tmp_dir, test_name);
        file_cleanup = obj.save_temp_file(sqw_obj, out_file_path);

        % reset the config so we read the whole of the pixel array in one go
        clear conf_cleanup

        saved_sqw = sqw(out_file_path);
        assertTrue(equal_to_tol(saved_sqw, sqw_obj, 'ignore_str', true));
    end

    function test_saved_sqw_with_paged_pix_equal_to_original_sqw(obj)
        conf_cleanup = obj.set_temp_pix_page_size(obj.small_page_size);
        sqw_obj = sqw(obj.test_sqw_file_path);

        dbst = dbstack;
        test_name = dbst.name;
        out_file_path = fullfile(tmp_dir, test_name);
        file_cleanup = obj.save_temp_file(sqw_obj, out_file_path);

        saved_sqw = sqw(out_file_path);
        assertTrue(equal_to_tol(saved_sqw, sqw_obj, 'ignore_str', true));
    end

    function test_sqw_w_paged_pix_saved_correctly_with_small_mem_chunk_size(obj)
        num_pix_in_file = 100337;
        conf_cleanup = set_temporary_config_options(...
            hor_config(), ...
            'pixel_page_size', obj.small_page_size, ...
            'mem_chunk_size', floor(num_pix_in_file/2) ...
        );
        sqw_obj = sqw(obj.test_sqw_file_path);

        dbst = dbstack;
        test_name = dbst.name;
        out_file_path = fullfile(tmp_dir, test_name);
        file_cleanup = obj.save_temp_file(sqw_obj, out_file_path);

        saved_sqw = sqw(out_file_path);
        assertTrue(equal_to_tol(saved_sqw, sqw_obj, 'ignore_str', true));
    end

    function test_sqw_w_pix_on_2nd_pg_saved_right_with_small_mem_chunk_size(obj)
        num_pix_in_file = 100337;
        conf_cleanup = set_temporary_config_options(...
            hor_config(), ...
            'pixel_page_size', obj.small_page_size, ...
            'mem_chunk_size', floor(num_pix_in_file/2) ...
        );
        sqw_obj = sqw(obj.test_sqw_file_path);
        sqw_obj.data.pix.advance();

        dbst = dbstack;
        test_name = dbst.name;
        out_file_path = fullfile(tmp_dir, test_name);
        file_cleanup = obj.save_temp_file(sqw_obj, out_file_path);

        saved_sqw = sqw(out_file_path);
        assertTrue(equal_to_tol(saved_sqw, sqw_obj, 'ignore_str', true));
    end

end

methods (Static)

    function cleanup = set_temp_pix_page_size(pg_size)
        cleanup = set_temporary_config_options(...
            hor_config(), 'pixel_page_size', pg_size);
    end

    function cleanup = save_temp_file(obj_to_save, file_path)
        save(obj_to_save, file_path);

        function del_temp_file(tmp_file_path)
            if exist(tmp_file_path, 'file')
                open_fids = fopen('all');
                if ~isempty(open_fids)
                    for i = 1:numel(open_fids)
                        fpath = fopen(open_fids(i));
                        if strcmp(fpath, tmp_file_path)
                            fclose(open_fids(i));
                        end
                    end
                else
                    delete(tmp_file_path);
                end
            end
        end

        cleanup = onCleanup(@() del_temp_file(file_path));
    end

end

end
