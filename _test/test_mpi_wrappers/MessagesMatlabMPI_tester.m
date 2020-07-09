classdef MessagesMatlabMPI_tester < MessagesParpool
    % Class to test protected methods of MessagesParpool class
    
    properties
    end
    
    methods
        function obj = MessagesMatlabMPI_tester(varargin)
            %
            if nargin>0
                if isnumeric(varargin{1})
                    labID = varargin{1};
                    if nargin>1
                        numLabs =varargin{2};
                    else
                        numLabs = 10;
                    end
                    control_struc = struct('job_id','test_MessagesMatlabMPI',...
                        'labID',labID ,'numLabs',numLabs);
                else
                    control_struc  = varargin{1};
                end
            else
                labID = 1;
                numLabs = 10;
                
                control_struc = struct('job_id','test_MessagesMatlabMPI',...
                    'labID',labID ,'numLabs',numLabs);
            end
            obj = obj@MessagesParpool(control_struc);
        end
        
        function [receive_now,mess_names,n_steps] = check_whats_coming_tester(obj,task_ids,mess_name,mess_array,n_steps)
            [receive_now,mess_names,n_steps] = obj.check_whats_coming(task_ids,mess_name,mess_array,n_steps);
        end
        
    end
end
