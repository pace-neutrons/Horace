classdef common_state_holder < handle
    % Class holds the common states, to be removed/restored when all tests get
    % completed
    properties
    end
    
    methods
        function obj = common_state_holder()
            %
            count = obj.call_count('+');
            if count == 1
                % Swallow any warnings for when pixel page size set too small
                % and nxspe having old version
                ws = struct('identifier',...
                    {'HORACE:PixelData:memory_allocation','LOAD_NXSPE:old_version'},...
                    'state',{'off','off'});
                old_warn_state = warning(ws);
                obj.store_holder(old_warn_state);
                
                % add path for deterministic pseudorandom sequence and
                % common Herbert utilities
                search_path_herbert_shared = fullfile(herbert_root, '_test/shared');
                obj.store_holder(search_path_herbert_shared);
                addpath(search_path_herbert_shared);
            end
        end
        function delete(obj)
            call_count = obj.call_count('-');
            if call_count == 0
                % clear storage for previous warning state and
                % return old warning state to the initial state
                old_warm = obj.store_holder('','old_warn_state');
                warning(old_warm);
                %
                % Seemps this path is needed by number of other utilities
                % so let's not remove it
                %search_path_herbert_shared = obj.store_holder('','search_path_herbert_shared');
                %rmpath(search_path_herbert_shared);
            end
        end
    end
    methods (Static)
        function stor_val = store_holder(var_to_store,field_name)
            % provides persistent data storage.
            % Usage:
            %>> output = common_state_holder.store_holder(var_value,[field_name]);
            %where
            % var_value  -- the value necessary to store. Replaces previous
            %               value, if any, stored under the specified
            %               field_name earlier.
            % Optional:
            % field_name -- the name of the field, this value will be
            %               stored with and can be restored from. If not
            %               provided, attempts to retrieve the field name
            %               from the name of the variable, defining the
            %               var_value (use inputname)
            % Returns    -- the value, previously stored under the specified
            %               field name or empty string if nothing was
            %               stored before
            %
            persistent storage;
            if isempty(storage)
                storage = struct();
            end
            if ~exist('field_name','var')
                field_name= inputname(1);
            end
            if isempty(field_name)
                warning('Can not store variable without name. Nothing is stored');
                stor_val = '';
                return
            end
            
            if isfield(storage,field_name)
                stor_val = storage.(field_name);
            else
                stor_val  = '';
            end
            storage.(field_name) = var_to_store;
            
        end
        function count = call_count(direction)
            % return persistent call counter
            %
            % If called without arguments, reutrns current state of the
            % counter. If this is the first call to the function, the value
            % will be 0;
            %
            % Optional inputs:
            % direction -- if '+' increnent and return counter's
            %              incremented value
            %              if '-' decrement and return counter
            %              decremented value
            %
            %              any other input -- return unchanged counter's
            %              value
            %
            persistent count_holder;
            if isempty(count_holder)
                count_holder = 0;
            end
            if exist('direction','var') && ischar(direction)
                if direction(1) == '+'
                    count_holder =  count_holder +1;
                elseif direction(1) == '-'
                    count_holder =  count_holder -1;
                end
            end
            count = count_holder;
        end
    end
end

