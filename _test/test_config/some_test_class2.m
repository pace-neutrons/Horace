classdef some_test_class2<some_test_class
    %some_test_class2 used in test to validate how the configuration works

    properties
        c='other_property'

    end

    methods
        function this=some_test_class2()
            this=this@some_test_class(mfilename('class'));
        end
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function data=get_data_to_store(obj)
            % method returns the structure with the data, expected to be stored
            % in configuration
            data = get_data_to_store@some_test_class(obj);
            data.c = obj.c;
        end
        % method places the data, provided as second argument, into
        % internal class storage. (the operation opposite to
        % get_data_to_store operation
        function fields = get_storage_field_names(~)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            %this = set_internal_field(this,field_name,field_value)
            % method sets the internal class field value bypassing standard
            % get/set methods interface
            fields = {'a','b','c'};
        end
        function value = get_default_value(obj,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            % talk to public interface -- test class for simplicity
            value = obj.(field_name);
        end
    end
end

