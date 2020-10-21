classdef test_noisify < TestCase

properties
    old_warn_state;

    raw_pix_data = rand(9, 10);
    small_page_size_ = 1e6;  % 1Mb
    test_sqw_file_path = '../test_sqw_file/deterministic_sqw_fake_data_for_testing.sqw';
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

    function obj = test_noisify(~)
        obj = obj@TestCase('test_noisify');

        % Swallow any warnings for when pixel page size set too small
        obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');

        % Process the file path
        test_sqw_file = 'c:\boobly6.sqw';%java.io.File('c:\', obj.test_sqw_file_path);
        obj.test_sqw_file_full_path = 'c:\boobly6.sqw';%char(test_sqw_file.getCanonicalPath());

        % Tests use a number of different input streams:
        % Construct an object from raw data
        obj.pixel_data_obj = PixelData(obj.raw_pix_data);
        % Construct an object from a file
        obj.pix_data_from_file = PixelData(obj.test_sqw_file_path);
        % Construct an object from a file accessor
        f_accessor = sqw_formats_factory.instance().get_loader(obj.test_sqw_file_path);
        obj.pix_data_from_faccess = PixelData(f_accessor);
        % Construct an object from file accessor with small page size
        obj.pix_data_small_page = PixelData(f_accessor, obj.small_page_size_);
    end

    function delete(obj)
        warning(obj.old_warn_state);
    end

    % --- Tests for in-memory operations ---
    
    function test_how_noisify_works(obj)
        % Thinking aloud here:
        % obj is the test case object
        % what we want to do is call noisify here on different kinds of
        % data
        % step 1 we reduce the page size
        hc = hor_config();
        hc.pixel_page_size = 10000;
        % we set up the test "random number generator" which is actually
        % a deterministic set of numbers 1:999 repeated. Use factor to make
        % them in range 0:1
        factor =1/999;
        % We make an sqw object with the above page size
        sqw_obj1 = sqw(obj.test_sqw_file_full_path);
        % and we noisify it
        rng(0) % don't need seed as it's not the proper rng but left in in
        % case we change our mind
        % instead set the flag to initialize the test "random" sequence
        global testrand_init;
        testrand_init = true;
        % add the noise to object 1
        
        addpath('./utils')
        addpath('../../../Herbert/_test/test_utilities');
        addpath('../../../Herbert/_test/shared');
        a=deterministic_pseudorandom_sequence();
        myrng=@a.myrand;
        noisy_obj1 = noisify(sqw_obj1,factor,'random_number_function',myrng);
        % step 2 we increase the page size again to the notional max
        hc = hor_config();
        hc.pixel_page_size = 3e9;
        % We make another sqw objectfrom the same file
        sqw_obj2 = sqw(obj.test_sqw_file_full_path);
        % and we noisify it
        rng(0)
        testrand_init = true;
        a.reset();
        noisy_obj2 = noisify(sqw_obj2,factor,'random_number_function',myrng);
        % as the page test whether the 2 paged versions are equal
        concpix = concatenate_pixel_pages(sqw_obj1(1).data.pix);
        assertEqual(concpix,sqw_obj2.data.pix.data,'',5e-4);
        nconcpix = concatenate_pixel_pages(noisy_obj1(1).data.pix);
        assertEqual(nconcpix(1,:),noisy_obj2.data.pix.data(1,:),'',5e-4);
        assertEqual(nconcpix(2,:),noisy_obj2.data.pix.data(2,:),'',5e-4);
        assertEqual(nconcpix(3,:),noisy_obj2.data.pix.data(3,:),'',5e-4);
        assertEqual(nconcpix(4,:),noisy_obj2.data.pix.data(4,:),'',5e-4);
        assertEqual(nconcpix(5,:),noisy_obj2.data.pix.data(5,:),'',5e-4);
        assertEqual(nconcpix(6,:),noisy_obj2.data.pix.data(6,:),'',5e-4);
        assertEqual(nconcpix(7,:),noisy_obj2.data.pix.data(7,:),'',5e-4);
        assertEqual(nconcpix(8,:),noisy_obj2.data.pix.data(8,:),'',5e-4);
        assertEqual(nconcpix(9,:),noisy_obj2.data.pix.data(9,:),'',5e-4);
        assertEqual(nconcpix,noisy_obj2.data.pix.data,'',5e-4);
        rmpath('./utils')
        rmpath('../../../Herbert/_test/test_utilities');
        rmpath('../../../Herbert/_test/shared');
   end

    function test_error_raised_if_setting_coordinates_with_wrong_num_cols(obj)
        num_rows = 10;
        pix_data_obj = obj.get_random_pix_data_(num_rows);

        function set_coordinates(data)
            pix_data_obj.coordinates = data;
        end

        new_coord_data = ones(3, num_rows);
        f = @() set_coordinates(new_coord_data);
        assertExceptionThrown(f, 'MATLAB:subsassigndimmismatch')
    end


    % -- Helpers --
end

methods (Static)

end
end