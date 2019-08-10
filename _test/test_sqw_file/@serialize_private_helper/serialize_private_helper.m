classdef serialize_private_helper
    % class to test private function serialization
    
    properties
        a_property = 10;
        b_property = 1;
        fun_handle;
    end
    
    methods
        function obj = serialize_private_helper(varargin)
            obj.fun_handle = @private_test_fun1_;
   
            if nargin >0
                in = varargin{1};
                flds = fieldnames(in);
                for i=1:numel(flds)
                    obj.(flds{i})= in.(flds{i});
                end
            end
            
        end
        function obj = switch_fun(obj,num)
            switch num
                case 1
                    obj.fun_handle = @private_test_fun1_;
                case 2
                    obj.fun_handle = @private_test_fun2_;
                otherwise
                    error('SERIALIZE_PRIVATE_HELPER:invalid_argument',...
                        ' function accepts 1 or 2 only');
            end
        end
        
        function outputArg = call_private(obj)
            outputArg = obj.fun_handle(obj);
        end
    end
end

