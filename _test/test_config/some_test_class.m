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
        
        function obj = set_class_name(obj,new_name)
            % function sets new class name to test the object
            obj.class_name_=new_name;
        end
        function is =eq(obj,other)
            flds = fieldnames(obj);
            flds2 = fieldnames(other);
            if numel(flds) ~= numel(flds2)
                is = false;
                return;
            end
            for i=1:numel(flds)
                field = flds{i};
                try
                    val = obj.(field);
                    if other.(field) ~= val
                        is = false;
                        return;
                    end
                catch
                    is = false;
                    return;
                end
            end
            is = true;
        end
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function data=get_data_to_store(this)
            % method returns the structure with the data, expected to be stored
            % in configuration
            data = struct('a',this.a,'b',this.b);
            
        end
        function fields = get_storage_field_names(this)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            %this = set_internal_field(this,field_name,field_value)
            % method sets the internal class field value bypassing standard
            % get/set methods interface
            fields = {'a','b'};
        end
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = this.(field_name);
        end
    end
    
end

