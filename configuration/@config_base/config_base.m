classdef config_base
    %Basis class for configurations, which have single instance for the whole 
    %package and can be automatically stored/restored from hdd
    
    properties
    end
    properties(Dependent)
        class_name;
        saveable;
    end
    properties(Access=protected)    
        class_name_;
        is_saveable_=true;
    end
    methods
        function obj=config_base(class_name)
            if isstring(class_name)
                obj.class_name_ = class_name;
            else
                error('CONFIG_BASE:constructor','config_base has to be initiated with string, defining derived class name');
            end
        end
        %
        function name=get.class_name(this)
            name = this.class_name_;
        end
        %
        function is = get.saveable(this)
            is = this.is_saveable_;            
        end
        %
        function this=set.saveable(this,val)
            if val > 0
                this.is_saveable_=true;
            else
                this.is_saveable_=false;            
            end
        end
        %
        function is=eq(this,other)        
            all_fields = fieldnames(this);
            for i=1:numel(all_fields)
                field_name = all_fields{i};                
                % Matlab 2009b compatibility operator, as isfield does not work properly there
                try
                    other_val = other.(field_name);
                    if this.(field_name) ~= other_val
                        is = false;
                        return 
                    end                    
                catch
                    is=false;
                    return;                    
                end
            end
            is = true;
        end
    end
    
end

