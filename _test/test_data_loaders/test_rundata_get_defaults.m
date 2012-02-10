classdef test_rundata_get_defaults< TestCase
% 
% $Revision: 107 $ ($Date: 2011-11-24 10:51:03 +0000 (Thu, 24 Nov 2011) $)
%
    
    properties 
    end
    methods       
        % 
        function this=test_rundata_get_defaults(name)
            this = this@TestCase(name);
        end        
        function this=test_get_all_defaults(this)
            rd=rundata();
            
            def_values = get_defaults(rd);
            assertEqual(rd.the_fields_defaults,def_values);
        end
        function this=test_get_list_defaults(this)
            rd=rundata();
            
            def_values = get_defaults(rd,rd.fields_have_defaults);
            assertEqual(rd.the_fields_defaults,def_values);
        end

         function this=test_wrong_defaults_throw(this)
            rd=rundata();

            f = @()get_defaults(rd,'missing_default_parameter');
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');
            
           f = @()get_defaults(rd,{1,10});                        
           assertExceptionThrown(f,'MATLAB:ISMEMBER:InputClass');                       
                   
            f = @()get_defaults(rd,{'missing_dp1','missing_dp2','omega'});            
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');            
            
            f = @()get_defaults(rd,1);                        
            assertExceptionThrown(f,'MATLAB:ISMEMBER:InputClass');                       
               
         end        
        
        function this=test_correct_defaults(this)
            rd=rundata();

            def=get_defaults(rd,'omega');
            assertEqual(0,def)
            
            def=get_defaults(rd,'omega','gl');            
            assertEqual(0,def{1})            
            assertEqual(0,def{2})                  
        end                 
        
    end
end