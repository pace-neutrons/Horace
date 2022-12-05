classdef test_distribute < TestCaseWithSave

    properties
        sqw_obj_1d;
        sqw_obj_2d;
        sqw_obj_4d;
        dnd_obj_1d;
        dnd_obj_2d;
        dnd_obj_4d;
    end

    methods
        function obj=test_distribute(name)
            output_file = 'test_distribute.mat';
            obj = obj@TestCaseWithSave(name, output_file);

            pths = horace_paths();
            obj.sqw_obj_1d = sqw(fullfile(pths.test_common, 'sqw_1d_1.sqw'));
            obj.sqw_obj_2d = sqw(fullfile(pths.test_common, 'sqw_2d_2.sqw'));
            obj.sqw_obj_4d = sqw(fullfile(pths.test_common, 'sqw_4d.sqw'));

            obj.dnd_obj_1d = read_dnd(fullfile(pths.test_common, 'sqw_1d_1.sqw'));
            obj.dnd_obj_2d = read_dnd(fullfile(pths.test_common, 'sqw_2d_2.sqw'));
            obj.dnd_obj_4d = read_dnd(fullfile(pths.test_common, 'sqw_4d.sqw'));

            obj.save();
        end

        function obj = test_distribute_xye(obj)
            test_data = struct('x', {{[1:10]}}, 'y', [1:10], 'e', [1:10]);
            [split, md] = distribute(test_data, 2, false);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10)
        end

        function obj = test_distribute_IX_dataset_1d(obj)
            test_data = IX_dataset_1d(1:100);
            [split, md] = distribute(test_data, 2, false);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10)
        end

        function obj = test_distribute_IX_dataset_2d(obj)
            test_data = IX_dataset_2d(1:100,1:100);
            [split, md] = distribute(test_data, 2, false);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10)
        end

        function obj = test_distribute_IX_dataset_3d(obj)
            test_data = IX_dataset_3d(1:10,1:10,1:10);
            [split, md] = distribute(test_data, 2, false);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10)
        end


        function obj = test_distribute_dnd_1d(obj)
            test_data = obj.dnd_obj_1d;
            [split, md] = distribute(test_data, 2, false);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10)

        end

        function obj = test_distribute_dnd_2d(obj)
            test_data = obj.dnd_obj_2d;
            [split, md] = distribute(test_data, 2, false);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10)

        end

        function obj = test_distribute_dnd_4d(obj)
            test_data = obj.dnd_obj_4d;
            [split, md] = distribute(test_data, 2, false);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10)

        end

        function obj = test_distribute_sqw_1d(obj)
            test_data = obj.sqw_obj_1d;
            [split, md] = distribute(test_data, 2, true);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10, 'ignore_str', 1, '-ignore_date')

        end

        function obj = test_distribute_sqw_1d_no_split_bins(obj)
            test_data = obj.sqw_obj_1d;
            [split, md] = distribute(test_data, 2, false);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10, 'ignore_str', 1, '-ignore_date')

        end

        function obj = test_distribute_sqw_2d(obj)
            test_data = obj.sqw_obj_2d;
            [split, md] = distribute(test_data, 2, true);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10, 'ignore_str', 1, '-ignore_date')

        end

        function obj = test_distribute_sqw_2d_no_split_bins(obj)
            test_data = obj.sqw_obj_2d;
            [split, md] = distribute(test_data, 2, false);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10, 'ignore_str', 1, '-ignore_date')

        end

        function obj = test_distribute_sqw_4d(obj)
            test_data = obj.sqw_obj_4d;
            [split, md] = distribute(test_data, 2, true);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10, 'ignore_str', 1, '-ignore_date')

        end

        function obj = test_distribute_sqw_4d_no_split_bins(obj)
            test_data = obj.sqw_obj_4d;
            [split, md] = distribute(test_data, 2, false);

            assertEqualToTolWithSave(obj, split, 'tol', 1e-10, 'ignore_str', 1, '-ignore_date')

        end

    end

end