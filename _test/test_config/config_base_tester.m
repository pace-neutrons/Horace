classdef config_base_tester <config_base
    %Test class representing some generig configuration
    
    properties(Dependent)
        my_prop;
        my_prop2;
    end
    properties(Access=private)
        my_prop_ = 'beee';
        my_prop2_ = 10;
    end
    methods
        function obj=config_base_tester()
            % constructor
            obj=obj@config_base(mfilename('class'));
        end
        function val = get.my_prop(this)
            val = get_or_restore_field(this,'my_prop');
            %val = this.my_prop;
        end
        function this = set.my_prop(this,val)
            config_store.instance().store_config(this,'my_prop',val);
        end
        function val = get.my_prop2(this)
            val = get_or_restore_field(this,'my_prop2');
            %val = this.my_prop;
        end
        function this = set.my_prop2(this,val)
            config_store.instance().store_config(this,'my_prop2',val);
        end
        %------------------------------------------------------------------
        % genetic test methods
              
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
    
        function fields = get_storage_field_names(class_instance)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            fields = {'my_prop','my_prop2'};
        end
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = this.([field_name,'_']);
        end
        
        
    end
    
end
