classdef genieplot < handle
    % Singleton class to hold configuration of graphics options
    % This is a very lean implementation of a singleton. It permits the setting
    % and getting of values but without any checks on values
    properties (Access=private)
        XScale = 'linear'
        YScale = 'linear'
        ZScale = 'linear'
    end
    
    methods (Access=private)
        % The constructor is private, preventing external invocation.
        % Only a single instance of this class is created. This is
        % ensured by getInstance() calling the constructor only once.
        function newObj = genieplot()
            % Initialize here if setting values in the properties block is not
            % feasible
        end
    end
    
    %---------------------------------------------------------------------------
    % No need to touch below this line
    
    methods (Static)
        function set(property, newData)
            obj = getInstance();
            obj.(property) = newData;
        end
        
        function data = get(property)
            obj = getInstance();
            if nargin>0
                data = obj.(property);
            else
                % Turn off a warning about heavy-handed use of struct but
                % cleanup to turn back on when exit
                state = warning('query','MATLAB:structOnObject');
                reset_warning = onCleanup(@()warning(state));
                warning('off','MATLAB:structOnObject')
                data = orderfields(structIndep(obj));
            end
        end
    end
    
end

% Note: this is deliberately placed *outside* the class, so that it
% ^^^^  is not exposed to the user. If we do not mind this, we could
%       place getInstance() in the class's static methods group.
function obj = getInstance()
persistent uniqueInstance
if isempty(uniqueInstance)
    obj = genieplot();
    uniqueInstance = obj;
else
    obj = uniqueInstance;
end
end
