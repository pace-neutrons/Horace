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
    %
    % WARNING! failed message needs to have tag==0, as this is hardcoded in
    % filebased messages framework.
    %
    properties(Constant,Access=private)
        % define list of the messages, known to the factory.
        mess_names_ = ...
            {'any','completed','pending','queued','init',...
            'starting','started','log',...
            'barrier','data','canceled','failed'};
        % define persistent messages, which should be retained until
        % clearAll operation is performed for the communications with
        % current source. These messages also have the same tag to be
        % transparently received through MPI
    end
    properties(Access = private,Hidden=true)
        % the map, between message meaningful name and message class
        mess_class_map_;
        % the map between message meaningful and message tag
        name_to_tag_map_;
        % the map between messge tag and message meaningful name
        tag_to_name_map_;
    end
    methods(Access = private)
        function obj = MESS_NAMES()
            % Private factory constructor.
            %
            % Builds message names constistent with messages factory
            %
            %
            n_known_messages = numel(MESS_NAMES.mess_names_);
            % Define tag for message 'any' to be -1;
            mess_tags = num2cell(-1:n_known_messages-2);
            obj.name_to_tag_map_ = containers.Map(MESS_NAMES.mess_names_,mess_tags);
            obj.tag_to_name_map_ = containers.Map(mess_tags,MESS_NAMES.mess_names_);
            
            for i=1:n_known_messages
                m_name = MESS_NAMES.mess_names_{i};
                try
                    clName= [upper(m_name(1)),lower(m_name(2:end)),'Message'];
                    if nargout>1
                        mess_class = feval(clName);
                    end
                catch ME
                    if strcmpi('MATLAB:UndefinedFunction',ME.identifier)
                        mess_class = aMessage(a_name);
                    else
                        rethrow(ME);
                    end
                end
                obj.mess_class_map_(m_name) = mess_class;
            end
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
            obj = inst;
            
        end
        %
        function [clName,mess_class] = mess_class_name(a_name)
            % return the name(s) of the class, corresponding to the message
            % name(s) provided as input
            %
            mn = MESS_NAMES.instance();
            is_name = isKey(mn.mess_class_map_,a_name);
            if all(is_name)
                if iscell(a_name)
                    clName = cell(1,numel(a_name));
                    mess_class = cell(1,numel(a_name));
                    for i=1:numel(a_name)
                        mess_class{i} =  mn.mess_class_map_(a_name{i});
                        clName{i} = class(mess_class{i});
                    end
                else
                    mess_class =  mn.mess_class_map_(a_name);
                    clName  = class(mess_class);
                end
                
            else
                error('MESS_NAMES:invalid_argument',....
                    'The name %s is not a registered message name',a_name);
            end
            
        end
        
        %
        function mess_class = gen_empty_message(mess_name)
            % generate empty message class instance given message name
            %
            [~,mess_class] = MESS_NAMES.instance().mess_class_map_(mess_name);
        end
        function names = all_mess_names()
            % return all message names, subscribed to the factory
            names = MESS_NAMES.mess_names_;
        end
        
        function id = mess_id(varargin)
            % get message id (tag) derived from message name
            % usage:
            % id = MESS_NAMES.mess_id('completed')
            % or
            % ids = MESS_NAMES.mess_id('completed','log','started')
            %
            % where id-s is the array of message id-s (tags)
            %
            mn = MESS_NAMES.instance();
            name2code_map = mn.name_to_tag_map_;
            
            if iscell(varargin{1})
                id = cellfun(@(nm)(name2code_map(nm)),...
                    varargin{1},'UniformOutput',true);
            elseif nargin > 1
                id = cellfun(@(nm)(name2code_map(nm)),...
                    varargin,'UniformOutput',true);
            else
                %disp(['MEss name: ',mess_name])
                %if isempty(mess_name)
                %    dbstack
                %end
                id = name2code_map(varargin{1});
            end
        end
        %
        function name = mess_name(mess_id)
            % get message name derived from message code (tag)
            %
            if isempty(mess_id)
                name  = {};
                return
            end
            
            mn = MESS_NAMES.instance();
            code2name_map= mn.tag_to_name_map_;
            
            if isnumeric(mess_id)
                if numel(mess_id) > 1
                    name = arrayfun(@(x)(code2name_map(x)),mess_id,...
                        'UniformOutput',false);
                else
                    name = {code2name_map(mess_id)};
                end
            elseif ischar(mess_id)
                if ismember(mess_name,MESS_NAMES.mess_names_)
                    name = mess_id;
                else
                    error('MESS_NAMES:invalid_argument',...
                        'name %s is not recognized message name',messname)
                end
            else
                error('MESS_NAMES:invalid_argument',...
                    'name %s is not recognized as a message name',messname)
            end
        end
        %
        function is = name_exist(name)
            % verify if the name provided is a valid message name, i.e.
            % is already subscribed to the messages name factory
            %
            if all(ismember(name,MESS_NAMES.mess_names_))
                is = true;
            else
                is = false;
            end
        end
        %
        function is = tag_valid(the_tag)
            % verify if the tag provided is valid message tag.
            mn = MESS_NAMES.instance();
            is = isKey(mn.tag_to_name_map_,the_tag);
        end
        %
        function is= is_blocking(mess_name_or_tag)
            % check if the message with the name, provided as imput is
            % blocking message. (should be send-received synchroneously)
            %
            % Input:
            % mess_name -- a string with message name or cellarray of
            %              message names, or a number defining the message
            %              tag, or cellarray of the messages or array of
            %              tags or cellarray of message classes.
            % Output
            % is        -- logical array, containing true if the corresponend
            %              message is blocking and false otherwise
            %
            if isa(mess_or_name_or_tag,'aMessage')
                is = mess_or_name_or_tag.is_blocking;
                return
            end
            
            mni = MESS_NAMES.instance();
            if isnumeric(mess_name_or_tag)
                if numel(mess_name_or_tag) > 1
                    is = arrayfun(@(mn)MESS_NAMES.is_blocking(mn),mess_name_or_tag,...
                        'UniformOutput',true);
                else
                    name = mni.tag_to_name_map_(mess_name_or_tag);
                    mc = mni.mess_class_map_(name);
                    is = mc.is_blocking();
                end
            elseif ischar(mess_name_or_tag)
                mc = mni.mess_class_map_(mess_name_or_tag);
                is = mc.is_blocking();
            elseif iscell(mess_name_or_tag)
                is = cellfun(@(mn)MESS_NAMES.is_blocking(mn),mess_name_or_tag,...
                    'UniformOutput',true);
            end
            
        end
        %
        function is = is_persistent(mess_or_name_or_tag)
            % check if given message is a persistent message
            %
            %
            if isa(mess_or_name_or_tag,'aMessage')
                is = mess_or_name_or_tag.is_persistent;
                return
            end
            
            mni = MESS_NAMES.instance();
            if isnumeric(mess_name_or_tag)
                if numel(mess_name_or_tag) > 1
                    is = arrayfun(@(mn)MESS_NAMES.is_persistent(mn),mess_name_or_tag,...
                        'UniformOutput',true);
                else
                    name = mni.tag_to_name_map_(mess_name_or_tag);
                    mc = mni.mess_class_map_(name);
                    is = mc.is_persistent();
                end
            elseif ischar(mess_name_or_tag)
                mc = mni.mess_class_map_(mess_name_or_tag);
                is = mc.is_persistent();
            elseif iscell(mess_name_or_tag)
                is = cellfun(@(mn)MESS_NAMES.is_persistent(mn),mess_name_or_tag,...
                    'UniformOutput',true);
            end
            
        end
        %
        
    end
end

