classdef DataMessage < aMessage
    % The class describes the message, which contains data.
    %
    % Usually, data are big, so copying efficiency is important.
    %
    %
    % $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
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

