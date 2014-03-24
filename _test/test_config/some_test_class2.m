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
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------        
        function data=get_data_to_store(this)            
            % method returns the structure with the data, expected to be stored
            % in configuration
            data = get_data_to_store@some_test_class(this);
            data.c = this.c;            
        end
        % method places the data, provided as second argument, into
        % internal class storage. (the operation opposite to
        % get_data_to_store operation
        function fields = get_storage_field_names(this)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            %this = set_internal_field(this,field_name,field_value)
            % method sets the internal class field value bypassing standard
            % get/set methods interface
            fields = {'a','b','c'};
        end
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = this.(field_name);
        end
        
    end
    
end

