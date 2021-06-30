classdef aMessage
    % Class describes messages transferable
    % between workers using any MPI framework, recognized by Herbert.
    %
    % All children classes, which have special features and derived from
    % this message should follow the following naming convention:
    %
    % The class name is defined as combination of [MessageName,'Message']
    % where MessageName is the name of the message, first letter capitalized
    % and 'Message' is the symbolic world "Message"
    %
    properties(Dependent)
        % message name, describing the message category (e.g. starting, started
        % etc...)
        mess_name;

        % Numerical representation of the message name
        tag;

        % message contents (arbitrary data distributed from sender to
        % receiver. The data have to be serializable
        payload;

        %-- Static class properties:
        %

        % If the message is a blocking message. If false, the next
        % message of the same type overwrites this message, if this message
        % has not been received. If true, the system waits for message to
        % be received.
        is_blocking;

        % If the message stays in the system until task is completed
        % playing the role of parallel interrupt, which sticks until the
        % task is reset
        is_persistent;
    end
    properties(Access=protected,Hidden=true)
        payload_     = [];
        mess_name_   = [];
    end

    methods
        function obj=aMessage(name)
            % constructor, which may return any children messages classes
            mfi = MESS_NAMES.instance();
            mess_class_name = MESS_NAMES.get_class_name(name);

            if ~strcmp(class(obj),mess_class_name) % called from constructor
                error('HERBERT:aMessage:invalid_argument',...
                    [' Message with name %s has specialized constructor %s',...
                    ' but instantiated trough generic aMessage interface'],...
                    name,mess_class_name);
            end
            if mfi.is_registered(name)
                % use factory to obtain subscribed instance of the class
                obj = mfi.get_mess_class(name);
            else
                obj.mess_name_ = name;
            end
        end
        %
        function ser_struc = saveobj(obj)
            % Define information, necessary for message serialization
            %
            % Do not! modify to send tag instead of the name!
            % -- some special messages have the same tags but different
            %    names

            ser_struc = struct('message_name',obj.mess_name);

            ws = warning('off','MATLAB:structOnObject');
            clob = onCleanup(@()warning(ws));
            ser_struc.payload = parce_payload_(obj.payload_);
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
            is = obj.get_blocking_state();
        end
        %
        function is = get.is_persistent(obj)
            is = obj.get_persist_state();
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
    end
    %
    methods(Static)
        function obj = loadobj(ser_struc)
            % Retrieve message object from the structure
            % produced by saveobj method.

            if numel(ser_struc) >1
                ss = ser_struc(1);
                pp = {ser_struc(:).payload};
            else
                ss = ser_struc;
                pp = ser_struc.payload;
            end
            obj = MESS_NAMES.instance().get_mess_class(ss.message_name);
            obj.payload_ = restore_payload_(pp);
        end
    end
    %
    methods(Access=protected)
        function pl = get_payload(obj)
            pl = obj.payload_;
        end
    end
    methods(Static,Access=protected)
        function isblocking = get_blocking_state()
            % return the blocking state of a message
            isblocking = false;
        end
        function is_pers = get_persist_state()
            % return the persistent state for a message
            is_pers = false;
        end
    end
end

