classdef test_test_sqw_utils < TestCase & common_pix_class_state_holder

    methods

        function obj = test_test_sqw_utils(~)
            obj = obj@TestCase('test_test_sqw_utils');
        end

        function test_concatenate_pixel_pages(~)

            % This test gives confidence in 'concatenate_pixel_pages' which several
            % other tests depend upon
            NUM_BYTES_IN_VALUE = 8;
            NUM_COLS_IN_PIX_BLOCK = 9;

            data = rand(NUM_COLS_IN_PIX_BLOCK, 30);
            npix_in_page = 11;

            faccess = FakeFAccess(data);
            pix = PixelDataBase.create(faccess);

            joined_pix_array = concatenate_pixel_pages(pix);
            assertElementsAlmostEqual(joined_pix_array, data,'relative',4.e-8);
        end

    end

end
