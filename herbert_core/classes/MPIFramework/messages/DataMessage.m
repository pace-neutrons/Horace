classdef DataMessage < aMessage
    % The class describes the message, which contains data.
    %
    % Usually, data are big, so copying efficiency is important.
    %
    %
    % $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
    %
    %    
    methods
        function obj = DataMessage(payload)
            % Construct the data message
            obj = obj@aMessage('data');
            obj.is_blocking_ = true;            
            if exist('payload','var')
                obj.payload = payload;
            end
        end
        
    end
    
end

