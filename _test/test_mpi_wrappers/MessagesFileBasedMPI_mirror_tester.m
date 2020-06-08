classdef MessagesFileBasedMPI_mirror_tester < MFTester & handle
    properties(Access=protected)
        mirror_labNum_;
    end
    
    methods
        function obj = MessagesFileBasedMPI_mirror_tester()
            % create intialization structure, which would represent 10
            % workers, communicating over file-based MPI messages
            init_struct = iMessagesFramework.build_worker_init(tmp_dir, ...
                'test_FB_message', 'MessagesFilebased', 1, 10,'test_mode');
            obj=obj@MFTester(init_struct);
            obj.mirror_labNum_ = 1;
        end
        
        function [ok,err_mess,message] = receive_message(obj,varargin)
            obj.mirror_labNum_ = varargin{1};
            [ok,err_mess,message] = receive_message@MessagesFilebased(obj,varargin{:});
        end
        
    end
    methods (Access=protected)
        function ind = get_lab_index_(obj)
            ind = obj.mirror_labNum_;
        end
    end
    
    
end

