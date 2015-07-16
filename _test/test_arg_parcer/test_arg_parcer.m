classdef test_arg_parcer < TestCase   
%The test checks if proj cass works fine
    
%     properties
%     end
    
    methods
     function this=test_arg_parcer(name)
            this=this@TestCase(name);
     end
        
      function test_constrFromCellarray(this)          
          fields={'a','b',1,'10',20,'a10'};
          
          parcer=arg_parcer(fields);
          assertEqual(3,numel(parcer.data_fields));
          assertEqual('a',parcer.data_fields{1});
          assertEqual('b',parcer.data_fields{2});          
          assertEqual('a10',parcer.data_fields{3});                    
      end

      function test_constrFromSrtuct(this)          
          dat.a=10;
          dat.b='aaa';
          dat.a10=100;
          
          parcer=arg_parcer(dat);
          assertEqual(3,numel(parcer.data_fields));
          assertEqual('a',parcer.data_fields{1});
          assertEqual('b',parcer.data_fields{2});          
          assertEqual('a10',parcer.data_fields{3});                    
      end
      function ass_helper(this)
          parcer=arg_parcer({'something'});
          parcer.data_fields{1} = 'other';
      end
      
      function test_noAssign(this)
          f = @()this.ass_helper();
          assertExceptionThrown(f,'ARG_PARCER:invalid_argument');
      end
      
      function test_to_cellarray(this)
           fields={'a','b','a10'};
           parcer=arg_parcer(fields); 
           
           cells = parcer.to_cell_array('10','a');
           
           assertEqual(cells{1},'a');
           assertEqual(cells{2},'10');           
           assertEqual(cells{3},'b');                      
           assertEqual(cells{4},'a');
           assertEqual(cells{5},'a10');           
           assertEqual(cells{6},[]);                      
      end

      function test_to_cellarray2(this)
           fields={'a','b'};
           parcer=arg_parcer(fields); 
           
           cells = parcer.to_cell_array(10,'20',[1,2,3]);
           assertEqual(numel(cells),5)
           
           assertEqual(cells{1},'a');
           assertEqual(cells{2},10);           
           assertEqual(cells{3},'b');                      
           assertEqual(cells{4},'20');
           assertEqual(cells{5},[1,2,3]);                  
           
 
           cells = parcer.to_cell_array(10,'20',[1,2,3],'bbb');
           
           assertEqual(numel(cells),6)           
           assertEqual(cells{1},'a');
           assertEqual(cells{2},10);           
           assertEqual(cells{3},'b');                      
           assertEqual(cells{4},'20');
           assertEqual(cells{5},[1,2,3]);                             
           assertEqual(cells{6},'bbb');                                        
       
      end

      function test_extend_cellarray(this)
           fields={'a','b'};
           parcer=arg_parcer(fields); 
           
           cells= parcer.to_cell_array('c',20,'a',[1,2,3],'b',0);
           
           assertEqual(numel(cells),6);
           assertEqual(cells{3},'a');
           assertEqual(cells{4},[1,2,3]);           
           assertEqual(cells{5},'b');                      
           assertEqual(cells{6},0);
           
           assertEqual(cells{1},'c');           
           assertEqual(cells{2},20);                      
 
       
      end
      
    end
end


