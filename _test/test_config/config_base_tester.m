classdef config_base_tester <config_base
    %Test class representing some generic configuration
    properties(Dependent)
        my_prop;
        my_prop2;
        unsaveable_property;
    end
    properties(Access=private)
        my_prop_ = 'beee';
        my_prop2_ = 10;
        unsaveable_property_ = 'abra_cadabra'
    end
    methods
        function obj=config_base_tester()
            % constructor
            obj=obj@config_base(mfilename('class'));
            obj.mem_only_prop_list_ = {'unsaveable_property'};
        end
        function val = get.my_prop(obj)
            val = get_or_restore_field(obj,'my_prop');
            %val = this.my_prop;
        end
        function obj = set.my_prop(obj,val)
            config_store.instance().store_config(obj,'my_prop',val);
        end
        function val = get.my_prop2(obj)
            val = get_or_restore_field(obj,'my_prop2');
            %val = this.my_prop;
        end
        function obj = set.my_prop2(obj,val)
            config_store.instance().store_config(obj,'my_prop2',val);
        end
        %------------------------------------------------------------------
        % genetic test methods

        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function fields = get_storage_field_names(~)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            fields = {'my_prop','my_prop2'};
        end
        function value = get_default_value(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = this.([field_name,'_']);
        end
    end

    methods % unsaveable property
        function up = get.unsaveable_property(obj)
            up = get_or_restore_field(obj,'unsaveable_property',false);
        end
        function obj = set.unsaveable_property(obj,val)
            config_store.instance().store_config(obj,'unsaveable_property',val,'-no_save');
        end
    end
end
