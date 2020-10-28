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
        test_sqw_file = java.io.File(pwd(), obj.test_sqw_file_path);
        obj.test_sqw_file_full_path = char(test_sqw_file.getCanonicalPath());

        % add path for concatenate-pixel_pages
        addpath('./utils')
        % add path for deterministic psuedorandom sequence
        addpath('../../../Herbert/_test/shared');
    end

    function delete(obj)
        rmpath('./utils')
        rmpath('../../../Herbert/_test/shared');
        warning(obj.old_warn_state);
    end

    % --- Tests for in-memory operations ---
    
    function test_how_noisify_works(obj)
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
        % here using a regular sequence (disguised as pseudorandom)
        % to make testing by eye easier:
        a=deterministic_pseudorandom_sequence();
        myrng=@a.myrand;
        % if the standard MATLAB rng were used then we would need to 
        % initialise that to a repeatable state by:
        % rng(0) 
        % add the noise to object 1 using myrng (myrng could be left out
        % to get the default randn behaviour, used with rng(0)
        noisy_obj1 = noisify(sqw_obj1,factor,'random_number_function',myrng);
        % step 2 we increase the page size again to the notional max
        hc = hor_config();
        hc.pixel_page_size = 3e9;
        % We make another sqw objectfrom the same file
        sqw_obj2 = sqw(obj.test_sqw_file_full_path);
        % and we noisify it
        % - reset pseudorandom number distribution. If this reverted to
        %   standard MATLAB rng, with myrng=any rnd using rng e.g. randn,
        %   then the reset should be done with
        %   rng(0);
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
   end


    % -- Helpers --
end

methods (Static)

end
end