classdef some_test_class2<some_test_class
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        c='other_property'
    end
    
    methods
        function this=some_test_class2()
            this=this@some_test_class(mfilename('class'));
        end
    end
    
end

