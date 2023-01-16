classdef test_PixelDataMemory < TestCase %& common_pix_class_state_holder

    properties
    end

    methods

        function obj = test_PixelDataMemory(~)
            obj = obj@TestCase('test_PixelDataMemory');
        end

        function test_to_from_struct_v2(~)
            dat = [eye(9,9),eye(9,9)];
            pdm = PixelDataMemory(dat);

            dts = pdm.to_struct();

            pdm_rec = serializable.from_struct(dts);

            assertEqual(pdm,pdm_rec);
        end

        function test_data_constructor(~)
            pdm = PixelDataMemory(ones(9,20));
            assertEqual(pdm.page_size,20);
            assertFalse(pdm.is_filebacked);

            assertEqual(pdm.pix_range,ones(2,4));
        end

        function test_empty_constructor(~)
            pdm = PixelDataMemory();
            assertEqual(pdm.page_size,0);
            assertFalse(pdm.is_filebacked);

            assertEqual(pdm.pix_range,PixelDataBase.EMPTY_RANGE_)
        end
    end
end
