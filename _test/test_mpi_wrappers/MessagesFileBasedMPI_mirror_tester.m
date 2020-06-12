classdef MessagesFileBasedMPI_mirror_tester < MFTester
    % The class, which mimicks the file-based messages mirroring, i.e.
    % when one sends message to a particular worker, the class reflects it and
    % provides the same message as available from this worker.
    properties(Access=protected)
        mess_name_fun_
    end
    
    methods
        function obj = MessagesFileBasedMPI_mirror_tester(varargin)
            % create intialization structure, which would represent 10
            % workers, communicating over file-based MPI messages
            if nargin == 0
                init_struct = iMessagesFramework.build_worker_init(tmp_dir, ...
                    'test_FB_message', 'MessagesFilebased', 1, 10,'test_mode');
            else
                init_struct = varargin{1};
            end
            obj=obj@MFTester(init_struct);
            obj.mess_name_fun_  = @(name,lab_to,lab_from)sprintf('mess_%s_FromN%d_ToN%d.mat',...
                name,lab_from,lab_to);
        end
        function [ok,err_mess,message] = send_message(obj,targ,varargin)
            obj.mess_name_fun_  = @(name,lab_to,lab_from)sprintf('mess_%s_FromN%d_ToN%d.mat',...
                name,lab_to,lab_from);
            [ok,err_mess,message] = send_message@MessagesFilebased(obj,targ,varargin{:});
            obj.mess_name_fun_  = @(name,lab_to,lab_from)sprintf('mess_%s_FromN%d_ToN%d.mat',...
                name,lab_from,lab_to);
            
        end
        
    end
    %
    methods (Access=protected)
        function mess_fname = job_stat_fname_(obj,lab_to,mess_name,lab_from)
            %build filename for a specific message
            if ~exist('lab_from','var')
                lab_from = obj.labIndex;
            end
            mess_fname= fullfile(obj.mess_exchange_folder,...
                obj.mess_name_fun_(mess_name,lab_to,lab_from));
            
        end
        
    end
    
    
end

