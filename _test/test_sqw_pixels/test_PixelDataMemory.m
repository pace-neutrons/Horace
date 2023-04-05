classdef test_PixelDataMemory < TestCase %& common_pix_class_state_holder

    properties
        test_file
    end

    methods

        function obj = test_PixelDataMemory(~)
            obj = obj@TestCase('test_PixelDataMemory');
            hp = horace_paths;
            obj.test_file = fullfile(hp.test_common,'sqw_1d_2.sqw');
        end

        function test_to_from_struct_v2(~)
            dat = [eye(9,9),eye(9,9)];
            pdm = PixelDataMemory(dat);

            dts = pdm.to_struct();

            pdm_rec = serializable.from_struct(dts);

            assertEqual(pdm,pdm_rec);
        end

        function test_serialize_deserialize_full(obj)
            df = PixelDataMemory(obj.test_file);
            assertEqual(df.num_pixels,4324)
            df_struc = df.to_struct();

            df_rec = serializable.from_struct(df_struc);
            assertEqual(df,df_rec);
        end

        function test_serialize_deserialize_empty(~)
            df = PixelDataMemory();
            df_struc = df.to_struct();

            df_rec = serializable.from_struct(df_struc);
            assertEqual(df,df_rec);
        end
        %
        function test_pix_alignment_set(~)
            pix_data = zeros(9,6);
            pix_data(1:4,1:4) = eye(4);
            pix_data(1:4,5)  = ones(4,1);
            pdm = PixelDataMemory(pix_data);

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

            assertElementsAlmostEqual(al_data(1:3,1:3),al_matr);
            ref_range =[  ...
                0,   0,       -0.7071,   0; ...
                1.,  1.4142,   0.7071,   1.0 ];
            assertElementsAlmostEqual(al_range(:,1:4),ref_range,'absolute',1.e-4);
        end
        %
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

            assertTrue(isempty(pdm.u1))
            assertEqual(size(pdm.u1),[1,0])
            assertEqual(size(pdm.q_coordinates),[3,0])
            assertEqual(size(pdm.coordinates),[4,0])
            assertEqual(pdm.pix_range,PixelDataBase.EMPTY_RANGE_)
            assertEqual(pdm.data_range,PixelDataBase.EMPTY_RANGE)
        end
    end
end
