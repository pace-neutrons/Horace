classdef serializableTester1 < serializable
    % Class used as test bench to unittest serializable class
    %

    properties
        Prop_class1_1=10;
        Prop_class1_2 =20;
        Prop_class1_3 = 'new_value'
    end

    methods
        function obj = serializableTester1()
        end
    end
    methods(Static)
        function obj = loadobj(S)
            obj = serializableTester1();
            obj = loadobj@serializable(S,obj);
        end
        function ver = ver_holder(new_version)
            persistent version;
            if isempty(version)
                version = serializableTester1.class_version_;
            end
            if nargin > 0
                version = new_version;
            end

            ver = version;
        end
    end

    methods(Access=public)
        % get independent fields, which fully define the state of the object
        function flds = indepFields(obj)
            if obj(1).class_version_ == 1
                flds = serializableTester1.fields_to_save_(1:2);
            else
                flds = serializableTester1.fields_to_save_;
            end
        end
        % get class version, which would affect the way class is stored on/
        % /restore from an external media
        function ver  = classVersion(~)
           ver = serializableTester1.ver_holder();
        end

    end
    properties(Constant,Access=private)
        class_version_ = 2;
    end
    properties(Constant,Access=protected)
        fields_to_save_ = {'Prop_class1_1','Prop_class1_2','Prop_class1_3'};
    end
    methods(Access=protected)
        function obj = from_old_struct(obj,inputs)
            if (isfield(inputs,'version') && inputs(1).version ~= 2) || ...
                ~isfield(inputs,'version')
                obj = from_bare_struct(obj,inputs);
                for i=1:numel(obj)
                    obj(i).Prop_class1_3 = 'recovered_new_from_old_value';
                end
            else
                obj = from_old_struct@serializable(obj,inputs);
            end
        end
    end
end

