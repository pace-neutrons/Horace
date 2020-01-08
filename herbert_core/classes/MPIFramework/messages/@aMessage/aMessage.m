classdef aMessage
    % Class describes messages transferable
    % between workers using any framework.
    %
    % All children classes, whcih have special features and derived from
    % this message should follow have the following naming convention:
    %
    % The class name is defined as combination of [MessageName,'Message']
    % where MessageName is the name of the message, first letter capitalized
    % and 'Message' is the symbolic world "Message"
    %
    properties(Dependent)
        % message contents (arbitrary data distributed from sender to
        % receiver)
        payload;
        % message name, describing the message category (e.g. starting,
        % running, etc...
        mess_name;
        % Numerical representation of the message name
        tag;
        % the message is a non-blocking message, i.e. the next
        % message of the same type overwrites this message, if this message
        % has not been received.
        is_blocking;
        
    end
    properties(Access=protected)
        payload_     = [];
        mess_name_   = [];
        is_blocking_ = false;
    end
    properties(Constant)
    end
    
    methods
        function obj=aMessage(name)
            % constructor, which may return any children messages.
            is = MESS_NAMES.name_exist(name);
            if is
                obj.mess_name_ = name;
            else
                error('AMESSAGE:invalid_argument',...
                    ' message with name %s is not recognized',name);
            end
        end
        %------------------------------------------------------------------
        function rez = get.payload(obj)
            rez = obj.get_payload();
        end
        %
        function name = get.mess_name(obj)
            name = obj.mess_name_;
        end
        %
        function is = get.is_blocking(obj)
            is = obj.is_blocking_;
        end
        %
        function tag = get.tag(obj)
            if isempty(obj.mess_name_)
                tag = -1;
            else
                tag = MESS_NAMES.mess_id(obj.mess_name_);
            end
        end        
        %------------------------------------------------------------------
        function obj = set.payload(obj,val)
            if iscell(val)
                if numel(val)==1 && isempty(val{1})
                    val = [];
                end
            end
            obj.payload_  = val;
        end
        %
        %------------------------------------------------------------------
        function not = ne(obj,b)
            % implementation of operator ~= for aMessage class
            not = ~equal_to_tol(obj,b);
        end
        function ln = saveobj(obj)
            % Define information, necessary for message serialization
            cln = class(obj);
            if (strcmp(cln,'aMessage'))
                ser_struc = struct('mess_name',obj.mess_name_,...
                    'is_blocking',obj.is_blocking_);
            else
                ser_struc = struct('class_name',cln);
            end
            ser_struc.payload = obj.payload_;
            ln = hlp_serialize(ser_struc);
        end
    end
    %
    methods(Static)
        function obj = loadobj(ls)
            % Define information, necessary for message de-serialization
            
            ser_struc = hlp_deserialize(ls);
            if numel(ser_struc) >1
                ss = ser_struc(1);
                pp = {ser_struc(:).payload};
            else
                ss = ser_struc;
                pp = ser_struc.payload;
            end
            if (isfield(ss,'mess_name'))
                obj = aMessage(ss.mess_name);
                obj.is_blocking_ = ss.is_blocking;
            else
                obj = feval(ss.class_name);
            end
            obj.payload_ = pp;
        end
        
    end
    %
    methods(Access=protected)
        function pl = get_payload(obj)
            pl = obj.payload_;
        end
    end
end

