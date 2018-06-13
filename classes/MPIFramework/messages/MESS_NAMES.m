classdef MESS_NAMES
    % The class lists all message names and message codes (tags)
    % used in Herbert MPI data exchange
    % and provides connection between the message names and message codes
    
    properties(Constant,Access=private)
        mess_names_ = {'failed','pending','init','starting','started','running',...
            'barrier','data','cancelled','completed'};
        mess_codes_ = {0,1,2,3,4,5,6,7,8,9};
        name2code_map_ = containers.Map(MESS_NAMES.mess_names_,MESS_NAMES.mess_codes_);
        code2name_map_ = containers.Map(MESS_NAMES.mess_codes_,MESS_NAMES.mess_names_);
    end
    
    methods(Static)
        function ids = all_mess_ids()
            ids = [MESS_NAMES.mess_codes_{:}];
        end
        function names = all_mess_names()
            names = MESS_NAMES.mess_names_;
        end
        
        function id = mess_id(varargin)
            % get message id (tag) derived from message name
            % usage:
            % id = MESS_NAMES.mess_id('completed')
            % or
            % ids = MESS_NAMES.mess_id('completed','running','started')
            %
            % where id-s is the array of message id-s (tags)
            %
            if iscell(varargin{1})
                id = cellfun(@(nm)(MESS_NAMES.name2code_map_(nm)),...
                    varargin{1},'UniformOutput',true);
            elseif nargin > 1
                id = cellfun(@(nm)(MESS_NAMES.name2code_map_(nm)),...
                    varargin,'UniformOutput',true);
            else
                %disp(['MEss name: ',mess_name])
                %if isempty(mess_name)
                %    dbstack
                %end
                id = MESS_NAMES.name2code_map_(varargin{1});
            end
        end
        %
        function name = mess_name(mess_id)
            % get message name derived from message code (tag)
            %            
            if isempty(mess_id)
                name  = {};
            elseif isnumeric(mess_id)
                if numel(mess_id) > 1
                    name = arrayfun(@(x)(MESS_NAMES.code2name_map_(x)),mess_id,...
                        'UniformOutput',false);
                else
                    name = {MESS_NAMES.code2name_map_(mess_id)};
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
        function [is] = name_exist(name)
            % verify if the name provided is valid message name.
            %
            if all(ismember(name,MESS_NAMES.mess_names_))
                is = true;
            else
                is = false;
            end
        end
        function is = tag_valid(the_tag)
            % verify if the tag provided is valid message tag.
            if all(ismember(the_tag,MESS_NAMES.mess_codes_))
                is = true;
            else
                is = false;
            end
        end
    end
end

