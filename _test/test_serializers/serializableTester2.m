classdef serializableTester2 < serializable
    % Class used as test bench to unittest serializable class
    %

    properties
        Prop_class2_1
        Prop_class2_2;
        Prop_class2_3;
    end

    methods
        function [obj,remains] = serializableTester2(varargin)
            if nargin==0
                return;
            end
            positional_arg_names = obj.indepFields();
            val = {@isnumeric,@isnumeric,@ischar};
            [obj,remains] = ...
                set_positional_and_key_val_arguments(obj,...
                positional_arg_names,val,varargin{:});
        end
    end

    methods(Access=public)
        % get independent fields, which fully define the state of the object
        function flds = indepFields(~)
            flds = serializableTester2.fields_to_save_;
        end
        % get class version, which would affect the way class is stored on/
        % /restore from an external media
        function ver  = classVersion(~)
            ver = serializableTester2.version_holder();
        end
    end
    methods(Static)
        function obj = loadobj(S)
            obj = serializableTester2();
            obj = loadobj@serializable(S,obj);
        end
    end

    properties(Constant,Access=protected)
        fields_to_save_ = {'Prop_class2_1','Prop_class2_2','Prop_class2_3'};
    end
    methods(Static)
        function verr = version_holder(ver)
            persistent version;
            if nargin>0
                version = ver;
            end
            if isempty(version)
                version = 1;
            end
            verr = version;
        end
    end

end

