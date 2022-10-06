classdef test_rundata_get_defaults< TestCase
    properties
        log_level;
    end

    methods

        function obj=test_rundata_get_defaults(name)
            obj = obj@TestCase(name);
        end

        function obj=setUp(obj)
            hc = hor_config;
            obj.log_level = hc.log_level';
            hc.saveable = false;
            hc.log_level = -1;
        end

        function obj=tearDown(obj)
            hc = hor_config;
            hc.saveable = false;
            obj.log_level = obj.log_level;
        end

        % TESTS:
        function obj=test_get_all_defaults(obj)
            rd=rundata();

            def_fields = rd.fields_with_defaults();
            assertEqual({'emode'},def_fields);
            rd.lattice = oriented_lattice();


            def_fields = rd.fields_with_defaults();

            assertEqual({'emode','omega','dpsi','gl','gs','u','v'},def_fields);
            def_values = get_defaults(rd);
            assertEqual(1,def_values{1});
            assertEqual(0,def_values{2});
            assertEqual(0,def_values{3});
            assertEqual(0,def_values{4});
            assertEqual(0,def_values{5});
            assertEqual([1,0,0],def_values{6});
            assertEqual([0,1,0],def_values{7});
        end

        function obj=test_wrong_defaults_throw(obj)
            rd=rundata();

            f = @()get_defaults(rd,'missing_default_parameter');
            assertExceptionThrown(f,'HERBERT:rundata:invalid_argument');

            f = @()get_defaults(rd,{1,10});
            assertExceptionThrown(f,'HERBERT:rundata:invalid_argument');

            f = @()get_defaults(rd,{'missing_dp1','missing_dp2','omega'});
            assertExceptionThrown(f,'HERBERT:rundata:invalid_argument');

            f = @()get_defaults(rd,1);
            assertExceptionThrown(f,'HERBERT:rundata:invalid_argument');

        end

        function obj=test_correct_defaults(obj)
            rd=rundata();
            rd.lattice=oriented_lattice();

            def=get_defaults(rd,'omega');
            assertEqual(0,def{1})

            def=get_defaults(rd,'omega','gl');
            assertEqual(0,def{1})
            assertEqual(0,def{2})
        end

        function obj=test_correct_deforder(obj)
            rd=rundata();
            rd.lattice = oriented_lattice();

            def=get_defaults(rd,'v','u','omega');

            assertEqual([0,1,0],def{1})
            assertEqual([1,0,0],def{2})
            assertEqual(0,def{3})
        end
    end
end
