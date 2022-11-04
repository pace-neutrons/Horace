classdef serializableTesterWithInterdepProp < serializable
    % Class used as test bench to unit-test serializable class
    %

    properties(Dependent)
        Prop_class2_1
        Prop_class2_2;
        Prop_class2_3;
    end
    properties(Access=protected)
        Prop_class2_1_
        Prop_class2_2_;
        Prop_class2_3_;
    end

    methods
        function [obj,remains] = serializableTesterWithInterdepProp(varargin)
            if nargin==0
                return;
            end
            positional_arg_names = obj.saveableFields();
            [obj,remains] = ...
                set_positional_and_key_val_arguments(obj,...
                positional_arg_names,true,varargin{:});
        end

        function val = get.Prop_class2_1(obj)
            val = obj.Prop_class2_1_;
        end
        function val = get.Prop_class2_2(obj)
            val = obj.Prop_class2_2_;
        end
        function val = get.Prop_class2_3(obj)
            val = obj.Prop_class2_3_;
        end
        function obj = set.Prop_class2_1(obj,val)
            obj.Prop_class2_1_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        function obj = set.Prop_class2_2(obj,val)
            obj.Prop_class2_2_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        function obj = set.Prop_class2_3(obj,val)
            obj.Prop_class2_3_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function obj=check_combo_arg(obj)
            % invent some verid dependencies between properties
            if ~isempty(obj.Prop_class2_1)&&isempty(obj.Prop_class2_2) || ...
                isempty(obj.Prop_class2_3)  || ... 
                (obj.Prop_class2_1 > obj.Prop_class2_2)
                
                error('HERBERT:serializableTester:invalid_argument', ...
                    'inconsisten interdependent properties')
            end
        end
        % get independent fields, which fully define the state of the object
        function flds = saveableFields(~)
            flds = serializableTesterWithInterdepProp.fields_to_save_;
        end
        % get class version, which would affect the way class is stored on/
        % /restore from an external media
        function ver  = classVersion(~)
            ver = 1;
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function obj = loadobj(S)
            obj = serializableTesterWithInterdepProp();
            obj = loadobj@serializable(S,obj);
        end
    end

    properties(Constant,Access=protected)
        fields_to_save_ = {'Prop_class2_1','Prop_class2_2','Prop_class2_3'};
    end

end

