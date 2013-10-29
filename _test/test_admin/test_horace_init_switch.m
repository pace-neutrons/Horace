classdef test_horace_init_switch < TestCase   
%The test class to check that if Libisis and Herbert are both availible, 
% switching occurs smoothly and propertly
%   Detailed explanation goes here
    
    properties
        herbert_path;
        herbert_was_initiated_in;
        libisis_path;
        libisis_was_initiated_in;        
        horace_path;
        current_path;
    end
    
    methods
        function keep_test_path(this)
            if ~isempty(this.herbert_path)
                addpath(fullfile(this.herbert_path,'_test/matlab_xunit/xunit'));
            end            
        end
      function this=test_horace_init_switch(name)          
            this = this@TestCase(name);
            this.current_path = pwd;                
            try
                this.herbert_was_initiated_in= fileparts(which('herbert_init.m'));
                this.herbert_path = herbert_on('where');
                this.herbert_path = strrep(this.herbert_path, '/', filesep) ;                
            catch
                this.herbert_path ='';
                warning('test_horace_init_switch:invalid_argument','test_horace_init_switch will not run propertly as herbert_on is not on the path');
            end
            try
                this.libisis_was_initiated_in= fileparts(which('libisis_init.m'));                
                this.libisis_path = libisis_on('where');
                this.libisis_path = strrep(this.libisis_path, '/', filesep) ;
            catch
                this.libisis_path ='';
                warning('test_horace_init_switch:invalid_argument','test_horace_init_switch will not run propertly as libisis_on is not on the path');
            end
            % clear all necessary packages
            try
                this.horace_path = fileparts(which('horace_init.m'));
                horace_off();
            catch
            end
            try
                libisis_off();
            catch
            end
            try
                herbert_off();
            catch
            end

            keep_test_path(this);
      end
      function this=tearDown(this)
            if ~isempty(this.libisis_was_initiated_in)
                libisis_on(this.libisis_was_initiated_in);
                this.libisis_was_initiated_in='';
            end
            if ~isempty(this.herbert_was_initiated_in)
                herbert_on(this.herbert_was_initiated_in);
                this.herbert_was_initiated_in='';
            end
            
            if ~isempty(this.horace_path)
                if isempty(which('herbert_init.m'))&&isempty(which('libisis_init.m'))
                    herbert_on();
                end
                horace_on();
                this.horace_path='';
            end
            cd(this.current_path);  
            keep_test_path(this);
      end      
      %
      function test_hor_her_on(this)
          try
              horace_off();
          catch
          end
          try
              herbert_off();
          catch
          end
          try 
                libisis_off();              
          catch
          end
          f = @()horace_on();       
          % throws undefined function as can not find function necessary
          % for horace_init (they are in herbert/Libisis
          assertExceptionThrown(f,'MATLAB:UndefinedFunction');
          herbert_on();
          horace_on(); 
          assertEqual(this.herbert_path,fileparts(which('herbert_init.m')));
          assertTrue(~isempty(fileparts(which('horace_init.m'))));    
          horace_off();
          herbert_off();
          keep_test_path(this);
      end
      function test_use_herbert_off(this)
        horace_on();
        horace_off();
        herbert_on();
        horace_on();
        use_herbert 'off'         
        keep_test_path(this);        
        
        assertEqual(this.libisis_path,fileparts(which('libisis_init.m')));
        assertEqual(horace_on('where'),fileparts(which('horace_init.m')));
        assertTrue(isempty(fileparts(which('herbert_init.m'))));        
        horace_off();
      end
      function this=test_use_herbert_on(this)        
        libisis_on();
        horace_on();
        horace_off();
      
        cd(this.herbert_path);
        horace_on();
        use_herbert;        
        assertEqual(this.herbert_path,fileparts(which('herbert_init.m')));
        assertEqual(horace_on('where'),fileparts(which('horace_init.m')));
        assertTrue(isempty(fileparts(which('libisis_init.m'))));        
        horace_off();
      end
    end
end

