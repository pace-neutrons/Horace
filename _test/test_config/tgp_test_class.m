classdef tgp_test_class<config_base
    % Create the test configuration.
    %
    % To see the list of current configuration option values:
    %   >> test1_config
    %
    % To set values:
    %   >> set(test1_config,'name1',val1,'name2',val2,...)
    %
    % To fetch values:
    %   >> [val1,val2,...]=get(test1_config,'name1','name2',...)
    %
    %
    % Fields are:
    % -----------
    %   v1      A user alterable field
    %   v2      Another user alterable field
    %
    % Type >> test_config  to see the list of current configuration option values.
    %
    %Test class to store/restore
    
    properties(Dependent)
        v1
        v2
    end
    properties(Access=protected)
        v1_=10000000
        v2_=9
    end
    
    methods
        function obj=tgp_test_class(varargin)
            if nargin == 0
                class_name = mfilename('class');
            else
                class_name =varargin{1};
            end
            obj = obj@config_base(class_name);
        end
        function val = get.v1(this)
            val = get_or_restore_field(this,'v1');
            %val = this.my_prop;
        end
        function this = set.v1(this,val)
            config_store.instance().store_config(this,'v1',val);
        end
        function val = get.v2(this)
            val = get_or_restore_field(this,'v2');
            %val = this.my_prop;
        end
        function this = set.v2(this,val)
            config_store.instance().store_config(this,'v2',val);
        end
        
        %-----------------------------------------------------------------
        % function for testing
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
        function fields = get_storage_field_names(this)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            %this = set_internal_field(this,field_name,field_value)
            % method sets the internal class field value bypassing standard
            % get/set methods interface
            fields = {'v1','v2'};
        end
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = this.([field_name,'_']);
        end
    end
    
end

