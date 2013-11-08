classdef test_config_classes< TestCase
    % Test basic functionality of configuration classes
    %
    %   > >test_config_classes
    %
    % Author: T.G.Perring
    properties
        s0_def;
        s1_def;
        s2_def;
    end
    methods
        function this=test_config_classes(name)
            
            this = this@TestCase(name);
            
            %banner_to_screen(mfilename)
            
            % Set test config classes
            set(test_config,'default');
            set(test1_config,'default');
            set(test2_config,'default');
            this.s2_def=get(test2_config);

            %???
            conf=get(config);             

            this.s0_def=get(test_config);
            this.s1_def=get(test1_config);
            
             
        end
        function this=test_getstruct(this)            
            
            % ----------------------------------------------------------------------------
            % Test getting values from a configuration
            % ----------------------------------------------------------------------------
            s2_def_pub=get(test2_config,'-pub');
            assertTrue(isequal(fieldnames(s2_def_pub),{'v1';'v2'}),'Problem 1 with: get(test2_config,''-pub'')')
            assertTrue(isequal(this.s2_def.v1,s2_def_pub.v1),'Problem 2 with: get(test2_config,''-pub'')')
            assertTrue(isequal(this.s2_def.v2,s2_def_pub.v2),'Problem 3 with: get(test2_config,''-pub'')')
      
            [v1,v3]=get(test2_config,'v1','v3');
            
            assertTrue(isequal(this.s2_def.v1,v1),'Problem with: get(test2_config,''v1'',''v3'')')
            assertTrue(isequal(this.s2_def.v3,v3),'Problem with: get(test2_config,''v1'',''v3'')')
        end
        
        function this=test_get_wrongCase(this)            
            % This should fail because V3 is upper case, but the field is v3
%             f = @()get(test2_config,'v1','V3');
%             assertExceptionThrown(f,'LOAD_ASCII:wrong_argument');
            
            try
               [v1,v3]=get(test2_config,'v1','V3');
               ok=false;
            catch
               ok=true;
            end
            assertTrue(ok,'Problem with: get(test2_config,''v1'',''V3'')')
        end
        function this=test_get_sealed(this)
            % This should fail because v3 is a sealed field
            f = @()get(test2_config,'v1','v3','-pub');                     
            assertExceptionThrown(f,'CONFIG:get');
        end
        
        function this=test_get_and_save(this)
            % ----------------------------------------------------------------------------
            % Test ghanging values and saving
            % ----------------------------------------------------------------------------
            

            
            % Change the config without saving, change to default without saving - see that this is done properly
            set(test2_config,'v1',55,'-buffer');
            s2_buf=get(test2_config);
            
            set(test2_config,'def','-buffer');
            s2_tmp=get(test2_config);
            
            assertTrue(~isequal(s2_tmp,s2_buf),'Error in config classes code');
            assertTrue(isequal(s2_tmp,this.s2_def),'Error in config classes code');
            
        end
        function this=test_set_withbuffer(this)
            set(test2_config,'v1',-30);
            s2_sav=get(test2_config);
            
            % Change the config without saving, change to save values, see this done properly
            set(test2_config,'v1',55,'-buffer');
            s2_buf=get(test2_config);
            
            set(test2_config,'save');
            s2_tmp=get(test2_config);

            assertTrue(~isequal(s2_tmp,s2_buf),'Error in config classes code')            
            assertTrue(isequal(s2_tmp,s2_sav),'Error in config classes code')            
           
        end
        
        function this=test_set_sealed(this)
            % Try to alter a sealed field
            f = @()set(test2_config,'v4','Whoops!');         
            % should throw; first argument has to be a file name
            assertExceptionThrown(f,'TESTCONFIG:set_invalid_argument','should throw on setting sealed field');            
        end
        function this=test_set_sealed_with_root(this)
            
            % Try to alter a sealed field using root set method
            f = @()set(test1_config,'v3','Whoops!');
            assertExceptionThrown(f,'CONFIG:set','should throw on setting sealed field');                 
           
        end
        
        function this=test_set_herbert_tests(this)

            conf=get(herbert_config,'init_tests');
            cleanup_obj=onCleanup(@()set(herbert_config,'init_tests',conf));

            set(herbert_config,'init_tests',0);            
            notfound=which('assertTrue.m');
            
            set(herbert_config,'init_tests',1);                                    
            assertTrue(isempty(notfound),' folder was not removed from search path properly');
            
        end
        
    end
end