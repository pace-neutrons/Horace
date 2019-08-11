classdef tgp_test_class2<tgp_test_class
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Dependent)
        v3
        v4
    end
    properties(Access=protected)
        v3_='hello'
        v4_=[13,14]
        
    end
    
    
    methods
        function this=tgp_test_class2()
            this=this@tgp_test_class(mfilename('class'));
        end
        function val = get.v3(this)
            val = get_or_restore_field(this,'v3');
            %val = this.my_prop;
        end
        function this = set.v3(this,val)
            config_store.instance().store_config(this,'v3',val);
        end
        function val = get.v4(this)
            val = get_or_restore_field(this,'v4');
            %val = this.my_prop;
        end
        function this = set.v4(this,val)
            config_store.instance().store_config(this,'v4',val);
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
            fields = [fields,{'v3','v4'}];
        end
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = this.([field_name,'_']);
        end
        
    end
    
end

