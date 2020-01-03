classdef test_CPP_MPI_exchange< TestCase
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties
    end
    methods
        %
        function obj=test_CPP_MPI_exchange(name)
            if ~exist('name','var')
                name = 'test_CPP_MPI_exchange';
            end
            obj = obj@TestCase(name);
        end
        function test_JobExecutor(obj)
            if isempty(which('cpp_communicator'))
                return
            end
            serverfbMPI  = MessagesFilebased('test_JE_CppMPI');
            serverfbMPI.mess_exchange_folder = tmp_dir;
            
            [data_exchange_folder,JOB_id] = fileparts(serverfbMPI.mess_exchange_folder);
            cs = iMessagesFramework.build_worker_init(fileparts(data_exchange_folder),...
                JOB_id,'MessagesCppMPI',1,1,true);
            
            % intercomm constructor invoked here.
            [fbMPI,intercomm] = JobExecutor.init_frameworks(cs);
            clob1 = onCleanup(@()(finalize_all(intercomm)));
            clob2 = onCleanup(@()(finalize_all(fbMPI)));
            
            assertTrue(isa(intercomm,'MessagesCppMPI'));
            assertEqual(intercomm.labIndex,uint64(1));
            assertEqual(intercomm.numLabs,uint64(1));
            
            
            je = JETester();
            common_job_param = struct('filepath',data_exchange_folder,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt',...
                'fail_for_labsN',2:3);
            im = InitMessage(common_job_param,1,1,1);
            
            je = je.init(fbMPI,intercomm,im,true);
            
            
            [ok,err_mess,message] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertEqual(message.mess_name,'started')
            
            
        end
        function test_SendProbeReceive(obj)
            % Test communications in test mode
            if isempty(which('cpp_communicator'))
                return
            end
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertEqual(mf.labIndex,uint64(1));
            assertEqual(mf.numLabs,uint64(10));
            
            mess = LogMessage(1,10,1,[]);
            [ok,err_mess]  = mf.send_message(5,mess);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [mess_names,source_id_s] = mf.probe_all('all','all');
            assertEqual(numel(mess_names),1);
            assertEqual(numel(source_id_s),1);
            assertEqual(source_id_s(1),int32(5));
            assertEqual(mess_names{1},mess.mess_name);

            [ok,err_mess]  = mf.send_message(7,mess);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));

            [mess_names,source_id_s] = mf.probe_all('all','all');
            assertEqual(numel(mess_names),2);
            assertEqual(numel(source_id_s),2);
            assertEqual(source_id_s(1),int32(5));
            assertEqual(source_id_s(1),int32(7));            
            assertEqual(mess_names{1},mess.mess_name);
            
        end
        
        function test_MessagesCppMPI_constructor(obj)
            if isempty(which('cpp_communicator'))
                return
            end
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertEqual(mf.labIndex,uint64(1));
            assertEqual(mf.numLabs,uint64(10));
            [labNum,nLabs] = mf.get_lab_index();
            
            assertEqual(labNum,uint64(1));
            assertEqual(nLabs,uint64(1));
            
            %             mess = LogMessage(1,10,1,[]);
            %             [ok,err_mess]  = mf.send_message(1,mess);
        end
        
        
    end
end


