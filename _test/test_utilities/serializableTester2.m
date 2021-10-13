classdef serializableTester2 < serializable
    % Class used as test bench to unittest serializable class
    %
    
    properties
        Property1
        Property2;
        version_setter =1 
    end
    
    methods
        function obj = serializableTester2()
        end
    end
    methods(Access=protected)
        % get independent fields, which fully define the state of the object
        function flds = indepFields(~)
            flds = serializableTester2.fields_to_save_;
        end
        % get class version, which would affect the way class is stored on/
        % /restore from an external media
        function ver  = classVersion(obj)
            ver = obj.version_setter;
        end
        
    end
    properties(Constant,Access=protected)
        fields_to_save_ = {'Property1','Property2'};
    end
    methods(Static)
        
        function obj = loadobj(S)
            class_instance = serializableTester2();
            obj = class_instance.loadobj_generic(S,class_instance);
        end
        %
    end
    
end

