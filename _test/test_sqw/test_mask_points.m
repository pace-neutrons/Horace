classdef test_mask_points < TestCase

    properties

        sqw_2d_file_path;
        sqw_2d;
    end

    methods

        function obj = test_mask_points(name)
            if ~exist('name','var')
                name = 'test_mask_points';
            end
            obj = obj@TestCase(name);

            pths = horace_paths();
            obj.sqw_2d_file_path = fullfile(pths.test_common, 'sqw_2d_1.sqw');
            % 2D case setup
            obj.sqw_2d = sqw(obj.sqw_2d_file_path, 'file_backed', false);
            % are signal and error in the sample object incorrect?
            obj.sqw_2d = obj.sqw_2d.recompute_bin_data();
        end

        function test_mask_selected_points(obj)
            tobj = obj.sqw_2d;
            msk = mask_points(tobj,[-0.53,-0.49,-0.52,-0.48]);

        end

        function test_dm_check_fig_info_works_with_handle_input(~)
            close all;
            fh = figure;
            clOb = onCleanup(@()close(fh));
            ax = gca;           
            ma = draw_mask(fh,'-test_fig_info');
            assertEqual(ax,ma);
        end

        function test_dm_check_fig_info_wrong_input_dim(~)
            ds = IX_dataset_1d(1:10,1:10);
            assertExceptionThrown(@()draw_mask(ds,'-test_fig_info'),...
            'HORACE:draw_mask:invalid_argument');
        end                
        function test_dm_check_fig_info_wrong_input_type(~)
            assertExceptionThrown(@()draw_mask('wrong type','-test_fig_info'),...
            'HORACE:draw_mask:invalid_argument');
        end                
        function test_dm_check_fig_info_wrong_num_input(~)
            close all;
            assertExceptionThrown(@()draw_mask(1,'-test_fig_info'),...
            'HERBERT:graphics:invalid_argument');
        end
    end

end
