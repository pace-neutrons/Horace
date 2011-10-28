classdef test_parse_arg< TestCase
    properties 
    end
    methods       
        % 
        function this=test_parse_arg(name)
            this = this@TestCase(name);
        end
        % tests themself
        function test_one_key_val(this)         
            str.a = '';
            str = parse_arg(str,'a',10);
            assertEqual(10,str.a);
        end               
        function test_two_key_valw(this)         
            str.a = '';
            str.b = '';            
            [str,field_names,field_vals] = parse_arg(str,'a',10,'b','xxx');
            assertEqual({10,'xxx'},{str.a,str.b});
            assertEqual([1,2],size(field_names));            
            assertEqual(size(field_vals),size(field_names));                        
        end               
        function test_struct_one(this)         
            str.a = '';
            ss.a = 10;            
            str = parse_arg(str,ss);
            assertEqual(10,str.a);
        end               
        function test_struct_two(this)         
            str.a = '';
            str.b = '';            
            str.c = '';                        
            ss.a = 10;            
            ss.b = 'yyy';                        
            [str,field_names,field_vals] = parse_arg(str,ss);
            assertEqual({10,'yyy'},{str.a,str.b});
            assertEqual([1,2],size(field_names));
            assertEqual(size(field_vals),size(field_names));                                    
        end               
        function test_cell_one(this)
            str.a = '';
            str.b = '';            
            str.c = '';                        
            str = parse_arg(str,{'a',10});
            assertEqual(10,str.a);            
        end
      function test_cell_two(this)
            str.a = '';
            str.b = '';            
            str.c = '';                        
            str = parse_arg(str,{'a',10,'b','yyy'});
            assertEqual({10,'yyy'},{str.a,str.b});
      end        
      function test_add_field_throws(this)
            str.a = '';
            str.b = '';            
            str.c = '';   
             f = @()parse_arg(str,{'a',10,'b','yyy','d','r'});
            assertExceptionThrown(f,'PARSE_ARG:wrong_arguments');            
      end  
        
    end
end