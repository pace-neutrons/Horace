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
        function test_mask_top_corner_points(obj)
            tobj = obj.sqw_2d.data;
            img_range = tobj.img_range(:,1:2);
            dr = [0.1,0.1];

            r3 = img_range(2,:)';
            r1 = r3 - dr';  
            r2 = r1;
            r2(2) = r2(2)+dr(2);
            r4 = r1;
            r4(1) = r4(1)+dr(1);

            msk = mask_points(tobj,'remove',[r1(1),r3(1),r1(2),r3(2)]);
            ma = draw_mask(tobj,'points',[r1,r2,r3,r4]);
            assertEqual(msk,ma);
        end
        

        function test_mask_selected_points(obj)
            tobj = obj.sqw_2d;
            msk = mask_points(tobj,'remove',[-0.53,-0.49,-0.52,-0.48]);
            ma = draw_mask(tobj,'points',[...
                -0.53,-0.49,-0.49,-0.53; ...
                -0.48,-0.48,-0.52,-0.52]);
            assertEqual(msk,ma);
        end

        function test_dm_check_points_out_of_range_throw(obj)
            ds = obj.sqw_2d.data;
            assertExceptionThrown(@()draw_mask(ds,'points',[1,2,3;-0.6,-0.59,-0.58]), ...
                'HORACE:draw_mask:invalid_argument');
        end                
        function test_dm_check_fig_info_works_with_IXdata_and_points(obj)
            ds = obj.sqw_2d.data;
            xyData = IX_dataset_2d(ds);
            [ma,sz] = draw_mask(xyData,'points',[1,2,3,4],'-test_fig_info');
            
            assertEqual(struct('XLim',ds.img_range(:,1)','YLim',ds.img_range(:,2)'),ma);
            assertEqual(sz,[16,11]);
        end        
        function test_dm_check_fig_info_works_with_obj_and_points(obj)
            ds = obj.sqw_2d.data;
            [ma,sz] = draw_mask(obj.sqw_2d,'points',[1,2,3,4],'-test_fig_info');
            
            assertEqual(struct('XLim',ds.img_range(:,1)','YLim',ds.img_range(:,2)'),ma);
            assertEqual(sz,[16,11]);
        end
        function test_dm_check_fig_info_works_with_obj_input(obj)
            close all;            
            [ma,sz] = draw_mask(obj.sqw_2d,'-test_fig_info');
            fh = gcf;
            clOb = onCleanup(@()close(fh));
            ax = gca;
            assertEqual(ax,ma);
            assertEqual(sz,[16,11]);
        end
        function test_dm_check_fig_info_works_with_objhandle_input(obj)
            close all;
            fh = plot(obj.sqw_2d);
            clOb = onCleanup(@()close(fh));

            [ma,sz] = draw_mask(fh,'-test_fig_info');
            ax = gca;
            assertEqual(ax,ma);
            assertEqual(sz,[16,11]);
        end
        function test_dm_check_fig_info_works_with_handle_input(~)
            close all;
            fh = figure;
            clOb = onCleanup(@()close(fh));
            ax = gca;
            [ma,sz] = draw_mask(fh,'-test_fig_info');
            assertEqual(ax,ma);
            assertEqual(sz,[1,1])
        end

        function test_dm_check_fig_info_wrong_input_dim_d3d(~)
            ds = d3d();
            assertExceptionThrown(@()draw_mask(ds,'-test_fig_info'),...
                'HORACE:draw_mask:invalid_argument');
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
