classdef tgp_test_class1<tgp_test_class
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        v3='hello'
        v4=[13,14]
        
    end
    
    methods
        function this=tgp_test_class1()
            this=this@tgp_test_class(mfilename('class'));
        end
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function fields = get_storage_field_names(this)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            %this = set_internal_field(this,field_name,field_value)
            % method sets the internal class field value bypassing standard
            % get/set methods interface
            fields = get_storage_field_names@tgp_test_class(this);
        end
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            if ismember(field_name,{'v3','v4'})
                value = this.(field_name);
            else
                value = get_internal_field@tgp_test_class(this,field_name);
            end
        end
        
    end
    
end

