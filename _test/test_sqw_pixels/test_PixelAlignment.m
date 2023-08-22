classdef test_PixelAlignment < TestCase & common_pix_class_state_holder

    properties
        stored_config
    end

    methods

        function obj = test_PixelAlignment(~)
            obj = obj@TestCase('test_PixelAlignment');

            hc = hor_config;
            obj.stored_config = hc.get_data_to_store();
        end

        function test_apply_alignment_filebacked(~)
            clW = set_temporary_warning('off', 'HOR_CONFIG:set_mem_chunk_size');
            clCf = set_temporary_config_options(hor_config, 'mem_chunk_size', 10);
            pix_data = rand(9, 30);

            pdm = PixelDataFileBacked(pix_data);
            assertEqualToTol(pix_data(:, 1:10), pdm.data, 'tol', 1e-6)

            al_matr = rotvec_to_rotmat2([0, 0, pi/4]);
            pdm.alignment_matr = al_matr;
            assertTrue(pdm.is_misaligned);

            ref_data = pix_data;
            ref_data(1:3, :) = al_matr*pix_data(1:3, :);
            ref_pix = PixelDataMemory(ref_data);

            assertEqualToTol(ref_data(:, 1:10), pdm.data, 'tol', 1e-6);

            ref_range = [min(ref_data, [], 2), max(ref_data, [], 2)]';

            pdm = pdm.apply_alignment();

            assertFalse(pdm.is_misaligned);
            assertEqualToTol(pdm, ref_pix, 'tol', 1e-6);
        end

        function test_apply_alignment_membacked(~)
            pix_data = rand(9, 10);

            pdm = PixelDataMemory(pix_data);

            al_matr = rotvec_to_rotmat2([0, pi/4, pi/4]);

            pdm.alignment_matr = al_matr;
            assertTrue(pdm.is_misaligned);

            ref_data = pix_data;
            ref_data(1:3, :) = al_matr*pix_data(1:3, :);
            assertElementsAlmostEqual(ref_data, pdm.data);

            ref_range = [min(ref_data, [], 2), max(ref_data, [], 2)]';

            pdm = pdm.apply_alignment();

            assertFalse(pdm.is_misaligned);
            assertElementsAlmostEqual(pdm.data, ref_data);
            assertElementsAlmostEqual(pdm.data_range, ref_range);
        end

        function test_pix_alignment_set_filebacked_properties(~)
            pix_data = ones(9, 5);
            pix_data(1:4, 1:4) = eye(4);

            pdm = PixelDataFileBacked(pix_data);

            al_matr = rotvec_to_rotmat2([0, 0, pi/4]);
            pdm.alignment_matr = al_matr ;

            ref_data = al_matr*pix_data(1:3, :);

            assertEqual(pdm.u1, ref_data(1, :))
            assertEqual(pdm.u2, ref_data(2, :))
            assertEqual(pdm.u3, ref_data(3, :))
            assertEqual(pdm.dE, [0, 0, 0, 1, 1])

            assertEqual(pdm.q_coordinates, ref_data)
            assertEqual(pdm.coordinates, [ref_data;[0, 0, 0, 1, 1]]);
        end


        function test_pix_alignment_set_filebacked_ranges(~)
            pix_data = zeros(9, 6);
            pix_data(1:4, 1:4) = eye(4);
            pix_data(1:4, 5)  = ones(4, 1);
            pdf = PixelDataFileBacked(pix_data);

            initial_range = pdf.data_range;


            al_matr = rotvec_to_rotmat2([pi/4, 0, 0]);
            % this actually changes pixel_data_range, as actual pixel
            % coordinate change
            pdf.alignment_matr = al_matr ;
            assertTrue(pdf.is_misaligned);

            ref_al_data = al_matr*pix_data(1:3, :);
            ref_data = pix_data;
            ref_data(1:3, :) = ref_al_data;

            aligned_data = pdf.data;
            assertElementsAlmostEqual(ref_data, aligned_data);

            raw_data = pdf.get_raw_data();
            assertElementsAlmostEqual(raw_data, pix_data);
            % now the range is calculated on request
            clWarn = set_temporary_warning('off', 'HORACE:old_file_format');
            al_range = pdf.data_range;
            [~, lw] = lastwarn; % data range have been recalculated on request with
            % warning
            assertEqual(lw, 'HORACE:old_file_format');
            assertFalse(all(initial_range(:) == al_range(:)));
            % range is still invalid as int is calculated on request
            assertFalse(pdf.is_range_valid);

            assertElementsAlmostEqual(aligned_data(1:3, 1:3), al_matr);
        end
        %
        function test_pix_alignment_set_membacked_properties(~)
            pix_data = ones(9, 5);
            pix_data(1:4, 1:4) = eye(4);

            pdm = PixelDataMemory(pix_data);

            al_matr = rotvec_to_rotmat2([0, 0, pi/4]);
            pdm.alignment_matr = al_matr ;

            ref_data = al_matr*pix_data(1:3, :);

            assertEqual(pdm.u1, ref_data(1, :))
            assertEqual(pdm.u2, ref_data(2, :))
            assertEqual(pdm.u3, ref_data(3, :))
            assertEqual(pdm.dE, [0, 0, 0, 1, 1])

            assertEqual(pdm.q_coordinates, ref_data)
            assertEqual(pdm.coordinates, [ref_data;[0, 0, 0, 1, 1]]);
        end


        function test_pix_alignment_set_membacked_ranges(~)
            pix_data = zeros(9, 6);
            pix_data(1:4, 1:4) = eye(4);
            pix_data(1:4, 5)  = ones(4, 1);
            pdm = PixelDataMemory(pix_data);

            initial_range = pdm.data_range;

            al_matr = rotvec_to_rotmat2([pi/4, 0, 0]);
            % this actually changes pixel_data_range, as actual pixel
            % coordinate change
            pdm.alignment_matr = al_matr;

            assertTrue(pdm.is_misaligned);

            ref_al_data = al_matr*pix_data(1:3, :);
            ref_data = pix_data;
            ref_data(1:3, :) = ref_al_data;

            aligned_data = pdm.data;
            assertElementsAlmostEqual(ref_data, aligned_data);

            raw_data = pdm.get_raw_data();
            assertElementsAlmostEqual(raw_data, pix_data);

            al_range = pdm.data_range;
            assertFalse(all(initial_range(:) == al_range(:)));

            assertElementsAlmostEqual(aligned_data(1:3, 1:3), al_matr);
            ref_range =[  ...
                0, 0, -0.7071, 0; ...
                1., 1.4142, 0.7071, 1.0 ];
            assertElementsAlmostEqual(al_range(:, 1:4), ref_range, 'absolute', 1.e-4);
        end
    end
end
