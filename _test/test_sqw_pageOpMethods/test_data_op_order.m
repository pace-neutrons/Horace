classdef test_data_op_order < TestCase
    properties
        % list of classes with binary operations redefined
        known_classes
        %
        %    'sqw_with_pix'    ,'PixelDataBase', 'sqw_no_pix','DnDBase','IX_dataset','sgv_img','num_img',...  % image size arrays
        %    'sqw_nopix_scalar', 'DnDBase_scal','IX_dataset_scal','sigvar_scal','num_scal'}    % the same classes but scalar value

    end

    methods
        function obj = test_data_op_order(name)
            if nargin == 0
                name = 'test_data_op_order';
            end
            obj = obj@TestCase(name);
            base_sqw = sqw.generate_cube_sqw(4);
            sqw0 = sqw.generate_cube_sqw(1);
            sqw0.pix = [];
            sqw_nopix = base_sqw;
            sqw_nopix.pix = [];
            dd = d2d( ...
                line_axes('nbins_all_dims',[4,4,1,1],'img_range',[0,0,0,0;1,1,1,1]), ...
                line_proj('alatt',3,'angdeg',90));

            obj.known_classes = {
                base_sqw,...
                PixelDataMemory(ones(9,5)),...
                sqw_nopix,...
                dd,...
                IX_dataset_1d(1:10,1:10),...
                sigvar(ones(2,10),ones(2,10)),...
                ones(3,5),...
                sqw0,...
                d0d(),...
                IX_dataset_1d(1,1),...
                sigvar(1,1),...
                10};
        end

        function test_num_img_order(~)
            obj1 = IX_dataset_1d();
            obj2 = 4;
            [is,do_page_op,page_op_order]=data_op_interface.is_superior(obj2,obj1);
            assertTrue(is);
            assertFalse(do_page_op);
            assertEqual(page_op_order,0)
        end

        function test_img_num_order(~)
            obj1 = IX_dataset_1d();
            obj2 = 4;
            [is,do_page_op,page_op_order]=data_op_interface.is_superior(obj1,obj2);
            assertFalse(is);
            assertFalse(do_page_op);
            assertEqual(page_op_order,0)
        end

        function test_gen_priorities(obj)
            pri = cellfun(@(x)data_op_interface.get_priority(x),...
                obj.known_classes);
            assertEqual(numel(pri),12);
            % priorites are all ordered and have to be different
            uni_pri = unique(pri);
            assertEqual(pri,uni_pri)
        end

    end
end
