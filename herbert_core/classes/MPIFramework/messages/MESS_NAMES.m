classdef MESS_NAMES < handle
    % The class lists and subscribes all message names and message codes
    % (tags) used in Herbert MPI data exchange
    % and provides connection between the message names and the message
    % codes
    %
    % The parent class of all classes should be aMessage and all children
    % message classes, which have special features and derived from
    % aMessage should follow have the following names:
    % The class name is defined as combination of [MessageName,'Message']
    % where MessageName is the name of the message, first letter capitalized
    % and 'Message' is the symbolic world "Message"
    
    %
    % it also manages list of asynchronous and synchronous messages, and
    % specify what kind of message should be transferred in which way.
    %
    % there is agreement within  the code that 'any' message has tag -1
    %
    %
    %
    properties
        % list of the messages, registered with the factory.
        known_messages;
        
        % true when all messages subscribed to the factory through their
        % names have instantiated their classes and registered them with
        % the factory.
        is_initialized
        
        % list of the names of the persistent messages, which represent
        % interrupts:
        interrupts
        
        % tags of the messages, which are the interrupts messages
        interrupt_tags;
        
        % The tags of the messages, used by Matlab MPI to find Matlab MPI
        % framework messages.
        pool_fixture_tags;
        
    end
    properties(Constant,Access=public)    
        % define the name of the persistent messages channel
        interrupt_channel_name = 'interrupt';
    end
    
    properties(Constant,Access=private)
        % define list of the messages, known to the factory. Any new
        % message to use in system needs to be added here.
        mess_names_ = ...
            {'any','completed','pending','queued','init',...
            'ready','starting','started','log',...
            'barrier','data','cancelled','failed'};
        
        % the messages which may communicate when Matlab MPI job is running
        % and which should be checked by probe_all for presence. The
        % fixture is necessary because of Matlab labProbe(labIndex) command
        % does not return tag of the message available, so check for every
        % message is necessary to identify which one is present. Failed
        % message can also me present but its already verified explicitly.
        matlab_pool_fixture_ = {'completed','started','log','data','cancelled'}
    end
    properties(Access = private,Hidden=true)
        %
        mess_class_map_ = containers.Map('UniformValues',false);
        
        % the map between message meaningful name and the message tag
        name_to_tag_map_ = containers.Map('KeyType','char','ValueType','double');
        
        % the map between messge tag and message meaningful name
        tag_to_name_map_ = containers.Map('KeyType','double','ValueType','char');
        
        % list of the defined and initialised messages
        interrupts_map_ = containers.Map('KeyType','double','ValueType','char')
        
        % property containing the list or registered message names.
        % If all messages are registered properly and factory is activated,
        % all messages from mess_names_ are registered and known_messages_
        % == mess_names_. Used as helper to debug factory and as check for
        % is_initialized property.
        known_messages_ = {};
        
        % helper property. When true, used to  disable recursive call to
        % the factory in the process of registering message classes with
        % the factory.
        initializing_ = false;
        

    end
    
    methods(Access = private)
        function obj = MESS_NAMES()
        end
        function obj = init(obj)
            % Private factory constructor.
            %
            % Builds message names constistent with messages factory
            %
            %
            obj.initializing_= true;
            %
            % Define tag for message 'any' to be -1;
            tags_list = num2cell(-1:numel(MESS_NAMES.mess_names_)-2);
            obj.name_to_tag_map_ = containers.Map(MESS_NAMES.mess_names_,tags_list);
            obj.tag_to_name_map_ = containers.Map(tags_list,MESS_NAMES.mess_names_);
            obj.known_messages_ = {};
            
            
            n_known_messages = numel(MESS_NAMES.mess_names_);
            %mess_tags = num2cell(-1:n_known_messages-2);
            %
            % any message does not have class and used only for assigning
            % the tag to it
            obj.mess_class_map_('any') = struct('is_blocking',false,...
                'is_persistent',false,'mess_name','any','tag',tags_list(1));
            obj.known_messages_{1} = 'any';
            
            for i=2:n_known_messages
                m_name = MESS_NAMES.mess_names_{i};
                clName = MESS_NAMES.get_class_name(m_name);
                
                if strcmp(clName,'aMessage')
                    mess_class  = aMessage(m_name);
                else
                    mess_class = feval(clName);
                end
                obj.mess_class_map_(m_name) = mess_class;
                obj.known_messages_{end+1} = m_name;
                
                % register all interrupts messages with interupts map.
                if mess_class.is_persistent
                    inter_tag = obj.name_to_tag_map_(m_name);
                    obj.interrupts_map_(inter_tag) = m_name;
                end
            end
            obj.initializing_ = false;
        end
    end
    methods
        function mess_list = get.known_messages(obj)
            % return list of the messages, known to the factory and
            % registered with it.
            %
            % used to check if factory registration is completed.
            %
            mess_list = obj.known_messages_;
        end
        %
        function is = get.is_initialized(obj)
            % return true if all messages are subscribed to the factory
            is = numel(obj.known_messages_)==numel(MESS_NAMES.mess_names_);
        end
        %
        function lst = get.interrupts(obj)
            % return list of the messages, which considered as interrupt
            % messages
            lst = obj.interrupts_map_.values;
        end
        %
        function tgs = get.interrupt_tags(obj)
            % return the tags of the messages, which considered as interrupt
            % messages
            tgs = obj.interrupts_map_.keys;
            tgs = [tgs{:}];
        end
        %   
        %----------------------------------------------------------------
        function is = is_registered(obj,name)
            % return true, if message with the name, provided as input
            % is registered with the factory.
            %
            % Used in the factory initialization.
            %
            is = isKey(obj.mess_class_map_,name);
        end
        %
        function is = is_subscribed(obj,name)
            % verify if the name provided is a valid message name, i.e.
            % is already subscribed to the messages name factory.
            %
            is = all(ismember(name,obj.mess_names_));
        end
        %
        function mess_class = get_mess_class(obj,a_name)
            % get empty message class instance corresponting to the message name
            % provided as input
            %
            is_name = isKey(obj.mess_class_map_,a_name);
            if all(is_name)
                if iscell(a_name)
                    mess_class = cellfun(@(name)(obj.mess_class_map_(name)),...
                        a_name,'UniformOutput',false);
                else
                    mess_class =  obj.mess_class_map_(a_name);
                end
            else
                if ~iscell(a_name)
                    a_name = {a_name};
                end
                error('MESS_NAMES:invalid_argument',....
                    'The name %s is not a registered message name\n',a_name{:});
            end
        end
        %
        function ft = get.pool_fixture_tags(obj)
            name2code_map = obj.name_to_tag_map_;
            ft = cellfun(@(nm)(name2code_map(nm)),...
                obj.matlab_pool_fixture_,'UniformOutput',true);
        end
        
    end
    
    
    methods(Static)
        function obj = instance()
            % Function containing and returning single instance of a given
            % message.
            %
            persistent inst;
            
            if isempty(inst)
                inst = MESS_NAMES();
            end
            
            % intitializing_ indicates subsequent calls to this function
            % within recursive messages constructor
            if ~inst.is_initialized && ~inst.initializing_
                inst = inst.init();
            end
            obj = inst;
            
        end
        %
        function cl_name = get_class_name(m_name)
            % given message name return correspondent message class name
            %
            %
            if ~ischar(m_name)
                error('MESS_NAMES:invalid_argument',...
                    'The method accepts only strings correstponding to a message class names');
            end
            if ~ismember(m_name,MESS_NAMES.mess_names_)
                error('MESS_NAMES:invalid_argument',...
                    'The message name %s is not registered with messages',...
                    m_name);
                
            end
            cl_name = [upper(m_name(1)),lower(m_name(2:end)),'Message'];
            if ~(exist(cl_name,'class')==8)
                cl_name = 'aMessage';
            end
            
        end
        
        function id = mess_id(mess_names,varargin)
            % get message id (tag) corresponding to the message name
            %
            % Input:
            % single name or sequence of the name to get id-s
            % Returns:
            % array of id-s correspondent to names.
            %
            % usage:
            % id = MESS_NAMES.mess_id('completed')
            % or
            % ids = MESS_NAMES.mess_id({'completed','log','started'})
            % ids = MESS_NAMES.mess_id({'completed','log','started'},interrupt_channel)            
            %
            mn = MESS_NAMES.instance();
            name2code_map = mn.name_to_tag_map_;
            if nargin>1
                if ~isnumeric(varargin{1})
                    error('MESS_NAMES:invalid_argument',...
                        'Second parameter (if any) for mess_id function should be number of interrupt channel. Got: %s',...
                    evalc('disp(varargin{1})'));
                end
                f = @(x)MESS_NAMES.name_to_id_or_interrupt(x,name2code_map,varargin{1});
            else
                f = @(x)name2code_map(x);
            end
            
            if iscell(mess_names)
                id = cellfun(f, mess_names,'UniformOutput',true);
            elseif ischar(mess_names)
                id = f(mess_names);
            else
                error('MESS_NAMES:invalid_argument',...
                    'input for mess_id should be a name or cellarray of names. Got: %s',...
                    evalc('disp(mess_names)'));
            end
        end
        %
        function name = mess_name(mess_id,varargin)
            % get message name derived from message code (tag)
            %
            % Input:
            % mess_id -- array of message id(s)
            % Optional
            %  Interrupt_channel_tag -- the number of the channel to transfer
            %                           interrupt messages.
            %                           Should be present if this channel 
            %                           name can occur
            %                           as input of mess_name function. 
            % Returns:
            % name    -- cellarray of message names in case of array of
            %            message id-s or single name(char) for single
            %            element message id-s.
            %
            if isempty(mess_id)
                name  = 'any';
                return
            end
            if ~isnumeric(mess_id)
                error('MESS_NAMES:invalid_argument',...
                    'input has to be a numeric tag or tags. got: %s ',...
                    fevalc('disp(mess_id)'))
            end
            mn = MESS_NAMES.instance();
            code2name_map= mn.tag_to_name_map_;
            
            if nargin>1
                f = @(x)MESS_NAMES.id_to_name_or_interrupt(x,code2name_map,varargin{1});
            else
                f = @(x)code2name_map(x);
            end
            
            if numel(mess_id) > 1
                name = arrayfun(f,mess_id,...
                    'UniformOutput',false);
            else
                name = f(mess_id);
            end
        end
        %
        function is = tag_valid(the_tag)
            % verify if the tag provided is valid message tag.
            %
            %
            mn = MESS_NAMES.instance();
            is = isKey(mn.tag_to_name_map_,the_tag);
        end
        %
        function is= is_blocking(mess_or_name_or_tag)
            % check if the message with the name, provided as imput is
            % blocking message. (should be send-received synchroneously and
            % can not be dropped (needed for result)
            %
            % Input:
            % mess_or_name_or_tag -- a string
            %              with message name or instance of message
            %              class or cellarray of message names, or a number
            %              defining the message tag, or cellarray of the
            %              messages names or array of tags or cellarray of
            %              message classes.
            % Output
            % is        -- logical array, containing true if the corresponend
            %              message is blocking and false otherwise
            %
            if isa(mess_or_name_or_tag,'aMessage')
                is = mess_or_name_or_tag.is_blocking;
                return
            end
            
            mni = MESS_NAMES.instance();
            if isnumeric(mess_or_name_or_tag)
                if numel(mess_or_name_or_tag) > 1
                    is = arrayfun(@(mn)mni.tag_to_name_map_(mn),mess_or_name_or_tag,...
                        'UniformOutput',true);
                else
                    name = mni.tag_to_name_map_(mess_or_name_or_tag);
                    mc = mni.mess_class_map_(name);
                    is = mc.is_blocking();
                end
            elseif ischar(mess_or_name_or_tag)
                mc = mni.mess_class_map_(mess_or_name_or_tag);
                is = mc.is_blocking();
            elseif iscell(mess_or_name_or_tag)
                is = cellfun(@(mn)(~isempty(mn)&& MESS_NAMES.is_blocking(mn)),mess_or_name_or_tag,...
                    'UniformOutput',true);
            end
            
        end
        %
        function is = is_persistent(mess_or_name_or_tag)
            % check if given message is a persistent message (interrupt
            % message)
            %
            % mess_or_name_or_tag --  a string with
            %              message name or instance of message
            %              class or cellarray of message names, or a number
            %              defining the message tag, or cellarray of the
            %              messages names or array of tags or cellarray of
            %              message classes.
            % Output
            % is        -- logical array, containing true if the corresponend
            %              message is persistent and false otherwise
            %
            if isa(mess_or_name_or_tag,'aMessage')
                is = mess_or_name_or_tag.is_persistent;
                return
            end
            
            mni = MESS_NAMES.instance();
            if isnumeric(mess_or_name_or_tag)
                if numel(mess_or_name_or_tag) > 1
                    is = arrayfun(@(mn)MESS_NAMES.is_persistent(mn),mess_or_name_or_tag,...
                        'UniformOutput',true);
                else
                    name = mni.tag_to_name_map_(mess_or_name_or_tag);
                    mc = mni.mess_class_map_(name);
                    is = mc.is_persistent();
                end
            elseif ischar(mess_or_name_or_tag)
                mc = mni.mess_class_map_(mess_or_name_or_tag);
                is = mc.is_persistent();
            elseif iscell(mess_or_name_or_tag)
                is = cellfun(@(mn)MESS_NAMES.is_persistent(mn),mess_or_name_or_tag,...
                    'UniformOutput',true);
            end
        end
        %
    end
    methods(Static,Access=private)
        function name=id_to_name_or_interrupt(id,code2name_map,interrupt_chan)
            if id == interrupt_chan
                name = MESS_NAMES.interrupt_channel_name;
            else
                name = code2name_map(id);
            end
        end
        function id=name_to_id_or_interrupt(name,name2code_map,interrupt_chan)
            if strcmp(name,MESS_NAMES.interrupt_channel_name)
                id  = interrupt_chan;
            else
                id = name2code_map(name);
            end
        end
        
    end
    
end
