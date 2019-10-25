classdef test_herbert_on< TestCase
% 
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%
    
    properties 
    end
    methods       
        % 
        function this=test_herbert_on(name)
            this = this@TestCase(name);
        end
        % tests themself
        function switch_on(this)               
            if ~isempty(which('herbert_on'))
                path=which('herbert_init.m');
                pc=herbert_on();
                assertEqual(path,pc);
            else
                disp('herbert_on not installed. No test to be performed')
                assertEqual(1,1);    % dummy assignment to ensure test is passed
            end
        end               
        function test_herLocations(this)                           
            if ~isempty(which('herbert_on'))
                path=herbert_on('where');
                pc =fileparts(which('herbert_init.m'));   
                assertEqual(path,pc);            
            else
                disp('herbert_on not installed. No test to be performed')
                assertEqual(1,1);    % dummy assignment to ensure test is passed
            end
        end
%         function test_herWrongEmpty(this)                           
%             hp =fileparts(which('herbert_init.m'));               
%             % disables herbert
%             path_empty=herbert_on('wrong/path/somewhere');
%             % it is disabled
%             path_emtpy1 =fileparts(which('herbert_init.m'));               
%             % enable it again to run tests
%             path=herbert_on(hp);    
%             % check previous and current herbert right,.
%             assertEqual('',path_empty);
%             assertEqual('',path_emtpy1);            
%             assertEqual(hp,path);            
%         end
        
    end
end

