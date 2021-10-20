classdef serializableTester1 < serializable
    % Class used as test bench to unittest serializable class
    %
    
    properties
        Property1=10;
        Property2=20;
    end
    
    methods
        function obj = serializableTester1()
        end
    end
    methods(Access=public)
        % get independent fields, which fully define the state of the object
        function flds = indepFields(~)
            flds = serializableTester1.fields_to_save_;
        end
        % get class version, which would affect the way class is stored on/
        % /restore from an external media
        function ver  = classVersion(~)
            ver = 1;
        end
        
    end
    properties(Constant,Access=protected)
        fields_to_save_ = {'Property1','Property2'};
    end
    methods(Static)
        
        function obj = loadobj(S)
            class_instance = serializableTester1();
            obj = class_instance.loadobj_generic(S,class_instance);
        end
        %
    end
    
end

