classdef MESS_NAMES
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
            {'any','failed','pending','queued','init',...
            'starting','started','log',...
            'barrier','data','canceled','completed'};
        % define job status messages, which should be processed within the
        % same queue, and have common tag.
        %log_messages_ = {'failed','log','canceled','completed'};
    end
    
    methods(Static)
        function [mess_list,is_blocking] = mess_factory()
            % The factory, containing the  instances  of all known messages.
            %
            % input: (Optional)
            % if present, message name.
            %
            % Returns:
            % mess_list   -- cellarray of all subscribed messages classes.
            % is_blocking -- boolean array indicating if messages are
            %                blocking or not
            
            persistent all_mess_list;
            persistent is_mess_blocking;
            %
            if isempty(all_mess_list)
                n_known_messages = numel(MESS_NAMES.mess_names_);
                all_mess_list = cell(1,n_known_messages);
                for i=1:n_known_messages
                    m_name = MESS_NAMES.mess_names_{i};
                    [~,cl] = MESS_NAMES.mess_class_name(m_name);
                    all_mess_list{i} = cl;
                end
                is_mess_blocking = cellfun(@(x)(x.is_blocking),all_mess_list,...
                    'UniformOutput',true);
            end
            mess_list = all_mess_list;
            is_blocking= is_mess_blocking;
            
        end
        %
        function [clName,mess_class] = mess_class_name(a_name)
            % build the name of the class, corresponding to the message
            % provided and instantiate this message class.
            %
            % if the class does not exist, return the name of the parent
            % class (aMessage) and initate aMessage with given message name
            
            try
                clName= [upper(a_name(1)),a_name(2:end),'Message'];
                mess_class = feval(clName);
            catch ME
                if strcmpi('MATLAB:UndefinedFunction',ME.identifier)
                    mess_class = aMessage(a_name);
                else
                    rethrow(ME);
                end
            end
            
        end
        %
        function [name2tag_map,tag2name_map]=name_tag_maps()
            % the persistent class builds relationship between message id
            % (tag) and the message name
            %
            % Returns:
            % name2tag_map -- the map, connecting symbolic message name
            %                 with the numeric tag;
            % tag2name_map -- the map, the numeric tag with corresponding
            %                 symbolic message names ;
            
            persistent name2code_map_;
            persistent code2name_map_;
            if isempty(name2code_map_)
                mess_codes = num2cell(-1:numel(MESS_NAMES.mess_names_)-2);
                name2code_map_ = containers.Map(MESS_NAMES.mess_names_,mess_codes);
                code2name_map_ = containers.Map(mess_codes,MESS_NAMES.mess_names_);
            end
            name2tag_map = name2code_map_;
            tag2name_map = code2name_map_;
        end
        %
        function names = all_mess_names()
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
            name2code_map=MESS_NAMES.name_tag_maps();
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
            [~,code2name_map]=MESS_NAMES.name_tag_maps();
            if isempty(mess_id)
                name  = {};
            elseif isnumeric(mess_id)
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
        function is = tag_valid(the_tag)
            % verify if the tag provided is valid message tag.
            if the_tag>=1 && the_tag <= numel(MESS_NAMES.mess_names_)
                is = true;
            else
                is = false;
            end
        end
        function is= is_blocking(mess_name)
            % check if the message with the name, provided as imput is
            % blocking message. (should be send-received synchroneously)
            %
            % Input:
            % mess_name -- a string with message name or cellarray of
            %              message names
            % Output
            % is        -- logical array, containing true if the corresponend
            %              message is blocking and false otherwise
            %
            [~,blocking] = MESS_NAMES.mess_factory();
            name2code_map = MESS_NAMES.name_tag_maps();
            if iscell(mess_name)
                ids = cellfun(@(x)(name2code_map(x)+2),mess_name,'UniformOutput',true);
                is = blocking(ids);
            elseif isnumeric(mess_name)
                is = blocking(mess_name+2);
            else
                id = name2code_map(mess_name)+2;
                is = blocking(id);
            end
        end
        %
        function names = get_all_names()
            % return all message names, subscribed to the factory
            names  = MESS_NAMES.mess_names_;
        end
    end
end

