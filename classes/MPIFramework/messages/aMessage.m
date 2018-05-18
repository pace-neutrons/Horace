classdef aMessage
    % Class used to distribute messages
    % between workers
    %
    properties(Dependent)
        % message contents (arbitrary data distributed from sender to
        % receiver)
        payload;
        % message name, describing the message category (e.g. starting,
        % running, etc...
        mess_name;
        tag;
    end
    properties(Access=protected)
        payload_ =[];
        mess_name_ = [];
    end
    
    
    methods
        function obj=aMessage(name)
            if MESS_NAMES.name_exist(name)
                obj.mess_name_ = name;
            else
                error('AMESSAGE:invalid_argument',...
                    ' message with name %s is not recognized',name);
            end
        end
        function rez = get.payload(obj)
            rez = obj.get_payload();
        end
        function name = get.mess_name(obj)
            name = obj.mess_name_;
        end
        function obj = set.payload(obj,val)
            obj.payload_  = val;
        end
        
        function tag = get.tag(obj)
            if isempty(obj.mess_name_)
                tag = -1;
            else
                tag = MESS_NAMES.mess_id(obj.mess_name_);
            end
        end
        %
        function not = ne(obj,b)
            % implementation of operator ~= for aMessage class
            if numel(obj) ~=numel(b)
                not = true;
                return;
            end
            if ~strcmp(class(obj),class(b))
                not = true;
                return;
            end
            fn1 = properties(obj);
            for i=1:numel(fn1)
                if (obj.(fn1{i})~=b.(fn1{i}))
                    not = true;
                    return
                end
            end
            not = false;
        end
    end
    methods(Access=protected)
        function pl = get_payload(obj)
            pl = obj.payload_;
        end
    end
end

