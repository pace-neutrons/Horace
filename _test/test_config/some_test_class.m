classdef some_test_class<config_base
    %Test class to store/restore
    
    properties
        a=10;
        b='beee'
    end
    methods
        function obj=some_test_class(varargin)
            if nargin == 0
                class_name = mfilename('class');
            else
                class_name =varargin{1};
            end
            
            obj = obj@config_base(class_name);
        end
        
        function this=set_saveable(this,val)
            this.is_saveable_ = val;
        end
        function this=set_class_name(this,val)
            this.class_name_ = val;
        end
    end
    
end

