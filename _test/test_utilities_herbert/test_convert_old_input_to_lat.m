classdef test_convert_old_input_to_lat< TestCase
    properties
        input_var_names = {'alatt','angdeg','u','v','psi','omega','dpsi','gl','gs'}
        input_var_values= {[1,2,3],[91,89,92],[1,1,0],[0,1,0],10,2,3,4,5}
    end
    methods
        function this=test_convert_old_input_to_lat(name)
            if nargin == 0
                name = 'test_convert_old_input_to_lat';
            end
            this = this@TestCase(name);
        end
        %
        function test_wrong_replication_throws(obj)
            var = obj.input_var_values;
            var{8} = [3,7];
            var{9} = [3,7,9];

            assertExceptionThrown(@()convert_old_input_to_lat(var{:}),...
                'HERBERT:convert_old_input:invalid_argument');
        end

        function test_no_psi_throws(obj)
            var = obj.input_var_values(1:4);

            assertExceptionThrown(@()convert_old_input_to_lat(var{:}),...
                'HERBERT:convert_old_input:invalid_argument');

        end
        %
        function test_replication_on_scalar_conversion(obj)
            var = obj.input_var_values;
            var{8} = [3,7];
            lat = convert_old_input_to_lat(var{:});
            assertEqual(numel(lat),2)
            assertTrue(isa(lat,'oriented_lattice'));

            assertEqual(lat(1).alatt,var{1});
            assertEqual(lat(2).alatt,var{1});
            assertEqual(lat(1).gl,var{8}(1));
            assertEqual(lat(2).gl,var{8}(2));

        end
        function test_replication_on_vector_conversion(obj)
            var = obj.input_var_values;
            var{1} = [1,2,3;4,5,6];
            lat = convert_old_input_to_lat(var{:});
            assertEqual(numel(lat),2)
            assertTrue(isa(lat,'oriented_lattice'));

            assertEqual(lat(1).alatt,var{1}(1,:));
            assertEqual(lat(2).alatt,var{1}(2,:));
            assertEqual(lat(1).gs,var{9});
            assertEqual(lat(2).gs,var{9});

        end
        function test_simple_conversion(obj)
            lat = convert_old_input_to_lat(obj.input_var_values{:});
            assertEqual(numel(lat),1)
            assertTrue(isa(lat,'oriented_lattice'));

            for i=1:numel(obj.input_var_names)
                var = obj.input_var_names{i};
                assertEqual(lat.(var),obj.input_var_values{i});
            end

        end
    end
end
