classdef test_projaxes_deprecation < TestCase

    methods
        function obj = test_projaxes_deprecation(~)
            obj@TestCase('test_projaxes_deprecation');
        end

        function test_projaxes_sqeved_equal_to_ortho_proj_sqeved(~)
            clOb = set_temporary_warning('off','HORACE:ortho_proj:deprecation');

            dep_obj = projaxes([1,1,0], [-1,1,0], 'type', 'aaa');
            [~,id]=lastwarn();
            assertEqual(id,'HORACE:ortho_proj:deprecation')
            new_obj = ortho_proj([1,1,0], [-1,1,0], 'type', 'aaa');
            assertEqual(dep_obj,new_obj);

        end
        function test_projaxes_simple_equal_to_ortho_proj_simple(~)
            clOb = set_temporary_warning('off','HORACE:ortho_proj:deprecation');

            dep_obj = projaxes([1, 0, 0], [0, 1, 0], 'type', 'rrr');
            [~,id]=lastwarn();
            assertEqual(id,'HORACE:ortho_proj:deprecation')
            new_obj = ortho_proj([1, 0, 0], [0, 1, 0], 'type', 'rrr');
            assertEqual(dep_obj,new_obj);
        end
    end

end
