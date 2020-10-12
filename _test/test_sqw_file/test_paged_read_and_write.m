classdef test_paged_read_and_write < TestCase

properties
    old_warn_state;

    raw_pix_data = rand(9, 10);
    small_page_size_ = 1e6;  % 1Mb
    test_sqw_file_path = '../test_sqw_file/deterministic.sqw';
    test_sqw_file_full_path = '';

    pixel_data_obj;
    pix_data_from_file;
    pix_data_from_faccess;
    pix_data_small_page;
    pix_fields = {'u1', 'u2', 'u3', 'dE', 'coordinates', 'q_coordinates', ...
                  'run_idx', 'detector_idx', 'energy_idx', 'signal', ...
                  'variance'};
end

properties (Constant)
    NUM_BYTES_IN_VALUE = 8;
    NUM_COLS_IN_PIX_BLOCK = 9;
end

methods (Access = private)

    function pix_data = get_random_pix_data_(~, rows)
        data = rand(9, rows);
        pix_data = PixelData(data);
    end

end

methods

    function obj = test_paged_read_and_write(~)
        obj = obj@TestCase('test_pagedPixelData');

        % Swallow any warnings for when pixel page size set too small
        obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');

        test_sqw_file = java.io.File(pwd(), obj.test_sqw_file_path);
        obj.test_sqw_file_full_path = char(test_sqw_file.getCanonicalPath());
    end
    
    function test_put_pixel_paged(obj)
        hc = hor_config();
        hc.pixel_page_size = 1e5;
        sqw_obj1 = sqw(obj.test_sqw_file_full_path);
        % and we save it
        save(sqw_obj1,'../test_sqw_file/paged_deterministic_1e5.sqw');
        % step 2 we increase the page size again
        hc = hor_config();
        hc.pixel_page_size = 3e9;
        % We make an sqw object 
        sqw_obj2 = sqw(obj.test_sqw_file_full_path);
        % and we save it
        save(sqw_obj2,'../test_sqw_file/paged_deterministic_3e9.sqw');
        % Now we pull back the 1e5-paged written file at the large page
        % size
        sqw_obj3 = sqw('../test_sqw_file/paged_deterministic_1e5.sqw');
        % we reset the filenames so they compare equal and the remaining
        % comparisons are about data
        sqw_obj3.main_header.filename = sqw_obj2.main_header.filename;
        sqw_obj3.data.filename = sqw_obj2.data.filename;
        % and we compare against the large-page-sized sqw (obj2)
        % as re-read after its save
        assertEqual(sqw_obj2,sqw_obj3,'',5e-4); 
        addpath('../test_sqw/utils');
        concpix = concatenate_pixel_pages(sqw_obj1(1).data.pix);
        rmpath('../test_sqw/utils');
        assertEqual(concpix,sqw_obj3.data.pix.data,'',5e-4);
    end

    function delete(obj)
        warning(obj.old_warn_state);
    end

end

end
