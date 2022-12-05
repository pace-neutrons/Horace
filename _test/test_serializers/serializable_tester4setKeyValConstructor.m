classdef serializable_tester4setKeyValConstructor < serializable
    % Class used as test bench to unit test serializable class
    %

    properties(Access=protected)
        prop1_char_ = ''
        prop2_char_ = ''
        prop3_char_ = ''
    end
    properties(Dependent)
        prop1_char
        prop2_char
        prop3_char
    end

    methods
        function obj = serializable_tester4setKeyValConstructor(old_keyval_compat,varargin)

            pos_par_names = obj.saveableFields();
            [obj,remains] = set_positional_and_key_val_arguments(obj,...
                pos_par_names,old_keyval_compat,varargin{:});
            if ~isempty(remains)
                error('HERBERT:serializable_class_tests:invalid_argument',...
                    'unrecognized property provided as input: %s', ...
                    disp2str(remains));
            end
        end
        function val = get.prop1_char(obj)
            val = obj.prop1_char_;
        end
        function val = get.prop2_char(obj)
            val = obj.prop2_char_;
        end
        function val = get.prop3_char(obj)
            val = obj.prop3_char_;
        end
        %
        function obj = set.prop1_char(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HERBERT:tests:invalid_argument',...
                    'This property accepts only char value')
            end
            obj.prop1_char_ = val;
        end
        function obj = set.prop2_char(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HERBERT:tests:invalid_argument',...
                    'This property accepts only char value')
            end
            obj.prop2_char_ = val;
        end
        function obj = set.prop3_char(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HERBERT:tests:invalid_argument',...
                    'This property accepts only char value')
            end
            obj.prop3_char_ = val;
        end

    end
    methods(Static)
        function obj = loadobj(S)
            obj = serializable_tester4setKeyValConstructor();
            obj = loadobj@serializable(S,obj);
        end
    end

    methods(Access=public)
        % get independent fields, which fully define the state of the object
        function ver  = classVersion(~)
            ver = 1;
        end
        function flds = saveableFields(~)
            flds = {'prop1_char','prop2_char','prop3_char'};
        end
    end
end
