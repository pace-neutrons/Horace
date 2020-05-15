classdef MessagesMatlabMPI_tester < MessagesParpool
    % Class to test protected methods of MessagesParpool class
    
    properties
        
    end
    
    methods
        function obj = MessagesMatlabMPI_tester(labID,numLabs)
            % make tester look like 10 workers
            if ~exist('labID','var')
                labID = 1;
                numLabs = 10;
            end
            if ~exist('numLabs','var')
                numLabs = 10;
            end
            obj = obj@MessagesParpool(...
                struct('job_id','test_MessagesMatlabMPI',...
                'labID',labID ,'numLabs',numLabs));
        end
    end
end

