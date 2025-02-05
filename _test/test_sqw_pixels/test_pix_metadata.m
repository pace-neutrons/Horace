classdef test_pix_metadata < TestCase
    properties

    end
    methods

        function obj = test_pix_metadata(~)
            obj = obj@TestCase('test_pix_metadata');
        end

        function test_get_metadata(~)
            data = rand(9,10);
            pix = PixelDataMemory(data);

            meta = pix.metadata;
            assertTrue(isa(meta,'pix_metadata'));

            assertEqual(meta.data_range,pix.data_range);

            assertTrue(meta.is_range_valid);
        end
        function test_metadata_empty_has_invalid_range(~)
            meta = pix_metadata;            
            assertFalse(meta.is_range_valid);
        end
        
    end
end
