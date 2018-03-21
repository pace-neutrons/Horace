classdef MESS_NAMES
    % The class to connect between message names and message codes
    % used in Herbert MPI data exchange
    
    properties(Constant,Access=private)
        mess_names_ = {'failed','starting','started','running','data','canceled','completed'};
        mess_codes_ = {0,1,2,3,4,5,6};
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
        
        function id = mess_id(mess_name)
            % get message id derived from message name
            if iscell(mess_name)
                id = cellfun(@(nm)(MESS_NAMES.name2code_map_(nm)),...
                    mess_name,'UniformOutput',true);
            else
                id = MESS_NAMES.name2code_map_(mess_name);
            end
        end
        %
        function name = mess_name(mess_id)
            % get message name derived from message code
            if isnumeric(mess_id)
                name = MESS_NAMES.code2name_map_(mess_id);
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
    end
end

