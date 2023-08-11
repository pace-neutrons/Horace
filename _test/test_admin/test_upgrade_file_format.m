classdef test_upgrade_file_format< TestCase
    
    properties
        source_mat = 
    end
    methods
        %
        function this=test_upgrade_file_format(name)
            if nargin<1
                name = 'test_upgrade_file_format';
            end
            this = this@TestCase(name);            
        end

        function test_upgrade_single_mat(~)
        end
    end
end

