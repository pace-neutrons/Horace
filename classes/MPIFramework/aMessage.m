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
            obj.mess_name_ = name;
        end
        function rez = get.payload(obj)
            rez = obj.payload_;
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
    end   
end

