classdef test_rundata_get_defaults< TestCase
    %
    % $Revision$ ($Date$)
    %
    
    properties
        log_level;
    end
    methods
        %
        function this=test_rundata_get_defaults(name)
            this = this@TestCase(name);
        end
        function this=setUp(this)
            this.log_level = get(herbert_config,'log_level');
            set(herbert_config,'log_level',-1,'-buffer');
        end
        function this=tearDown(this)
            set(herbert_config,'log_level',this.log_level,'-buffer');
        end
        
        % TESTS:
        function this=test_get_all_defaults(this)
            rd=rundata();
            
            def_fields = rd.fields_with_defaults();
            
            assertEqual({'omega','dpsi','gl','gs','is_crystal','u','v'},def_fields);
            def_values = get_defaults(rd);
            assertEqual(0,def_values{1});
            assertEqual(0,def_values{2});
            assertEqual(0,def_values{3});
            assertEqual(0,def_values{4});
            assertEqual(true,def_values{5});
            assertEqual([1,0,0],def_values{6});
            assertEqual([0,1,0],def_values{7});
        end
        
        function this=test_wrong_defaults_throw(this)
            rd=rundata();
            
            f = @()get_defaults(rd,'missing_default_parameter');
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');
            
            f = @()get_defaults(rd,{1,10});
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');
            
            f = @()get_defaults(rd,{'missing_dp1','missing_dp2','omega'});
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');
            
            f = @()get_defaults(rd,1);
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');
            
        end
        
        function this=test_correct_defaults(this)
            rd=rundata();
            
            def=get_defaults(rd,'omega');
            assertEqual(0,def{1})
            
            def=get_defaults(rd,'omega','gl');
            assertEqual(0,def{1})
            assertEqual(0,def{2})
        end
        function this=test_correct_deforder(this)
            rd=rundata();
            
            def=get_defaults(rd,'v','u','omega');
            
            assertEqual([0,1,0],def{1})
            assertEqual([1,0,0],def{2})
            assertEqual(0,def{3})
        end
        
        
    end
end
