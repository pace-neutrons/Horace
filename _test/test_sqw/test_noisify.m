classdef test_noisify < TestCase

properties
    old_warn_state;

    test_sqw_file_path = '../test_sqw_file/deterministic_sqw_fake_data_for_testing.sqw';
    test_sqw_file_full_path = '';
    search_path_herbert_shared = fullfile(herbert_root, '_test/shared');
end

methods

    function obj = test_noisify(~)
        obj = obj@TestCase('test_noisify');

        % Swallow any warnings for when pixel page size set too small
        obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');

        % Process the file path
        test_sqw_file = java.io.File(pwd(), obj.test_sqw_file_path);
        obj.test_sqw_file_full_path = char(test_sqw_file.getCanonicalPath());

        % add path for concatenate_pixel_pages
        addpath('./utils')
        % add path for deterministic psuedorandom sequence
        addpath(obj.search_path_herbert_shared);
    end

    function delete(obj)
        rmpath('./utils')
        rmpath(obj.search_path_herbert_shared);
        warning(obj.old_warn_state);
    end

    function test_how_noisify_works(obj)
        % obj is the test case object
        % what we want to do is call noisify here on different kinds of
        % data

        % step 1 we reduce the page size
        pixel_page_size = 1e5;
        % we set up the test "random number generator" which is actually
        % a deterministic set of numbers 1:999 repeated. Use factor to make
        % them in range 0:1
        factor = 1/999;
        % We make an sqw object with the above page size
        sqw_obj1 = sqw(obj.test_sqw_file_full_path, 'pix_pg_size', pixel_page_size);

        % ensure we're actually paging data
        pix = sqw_obj1.data.pix;
        assertTrue(pix.num_pixels > pix.page_size);

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
        assertEqual(nconcpix,noisy_obj2.data.pix.data,'',5e-4);
   end

end

end
