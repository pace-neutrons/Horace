classdef test_job_dispatcher_herbert < job_dispatcher_common_tests
    %
    % $Revision: 696 $ ($Date: 2018-02-06 13:59:38 +0000 (Tue, 06 Feb 2018) $)
    %
    
    properties
    end
    methods
        %
        function this=test_job_dispatcher_herbert(name)
            if ~exist('name','var')
                name = 'test_job_dispatcher_herbert';
            end
            this = this@job_dispatcher_common_tests(name,'herbert');
        end
        function test_split_job_struct(obj)        
            common_par = [];
            l1= {'aaa','bbbb','s','aaanana'};
            l2 = {10,20,3,14};
            
            loop_par = cell2struct({l1;l2},{'text_param','num_param'});
            
            jd = JDTester('test_split_job_struct');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));

            [task_ids,init_mess]= jd.split_tasks(common_par,loop_par,true,1);

            n_workers = numel(task_ids);
            
            assertEqual(n_workers,1);
            assertEqual(numel(init_mess{1}.loop_data),1)
            assertEqual(numel(init_mess{1}.loop_data.text_param),numel(l1));
            assertEqual(init_mess{1}.loop_data,loop_par);
           
            [task_ids,init_mess]= jd.split_tasks(common_par,loop_par,false,4);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,4);
            assertEqual(numel(init_mess),4);
            assertEqual(init_mess{1}.n_first_step,1);
            assertEqual(init_mess{1}.n_steps,1);            
            assertEqual(init_mess{4}.n_first_step,1);
            assertEqual(init_mess{4}.n_steps,1);
            
            s2 = init_mess{2}.loop_data;
            assertEqual(s2.text_param,{'bbbb'});
            assertEqual(s2.num_param,{20});            

            
            [task_ids,init_mess]= jd.split_tasks(common_par,loop_par,false,3);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,3);
            assertEqual(numel(init_mess),3);
            assertEqual(init_mess{1}.n_first_step,1);
            assertEqual(init_mess{1}.n_steps,1);
            assertEqual(init_mess{3}.n_first_step,1);
            assertEqual(init_mess{3}.n_steps,2);
            s3 = init_mess{3}.loop_data;
            assertEqual(s3.text_param,{'s','aaanana'});
            assertEqual(s3.num_param,{3,14});            

            
        end
        %
        function test_split_job_list(this)
            % split job list into batches and prepare init messages
            %
            common_par = [];
            loop_par = {'aaa','bbbb','s','aaanana'};
            
            jd = JDTester('test_split_job_list');
            clo = onCleanup(@()(jd.mess_framework.finalize_all()));
            
            [task_ids,init_mess]= jd.split_tasks(common_par,loop_par,true,1);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,1);
            assertEqual(numel(init_mess{1}.loop_data),numel(loop_par));
            assertEqual(init_mess{1}.loop_data,loop_par);
            
            [task_ids,init_mess]= jd.split_tasks(common_par,4,false,1);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,1);
            assertEqual(numel(init_mess),1);
            assertEqual(init_mess{1}.n_first_step,1);
            assertEqual(init_mess{1}.n_steps,4);
            
            %-------------------------------------------------------------
            
            loop_par = {'aaa',[1,2,3,4],'s',10};
            [task_ids,init_mess] = jd.split_tasks(common_par,loop_par,true,2);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,2);
            assertEqual(numel(init_mess{1}),1)
            assertEqual(numel(init_mess{2}),1)
            assertEqual(init_mess{1}.loop_data,loop_par(1:2))
            assertEqual(init_mess{2}.loop_data,loop_par(3:4))
            
            
            [task_ids,init_mess] = jd.split_tasks(common_par,4,true,2);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,2);
            assertEqual(init_mess{1}.n_first_step,1)
            assertEqual(init_mess{1}.n_steps,2)
            
            assertEqual(init_mess{2}.n_first_step,3)
            assertEqual(init_mess{2}.n_steps,2)
            %-------------------------------------------------------------
            
            [task_ids,init_mess] = jd.split_tasks(common_par,loop_par,true,3);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,3);
            assertEqual(init_mess{1}.loop_data,loop_par(1))
            assertEqual(init_mess{2}.loop_data,loop_par(2))
            assertEqual(init_mess{3}.loop_data,loop_par(3:4))
            assertEqual(init_mess{3}.n_first_step,1)
            assertEqual(init_mess{3}.n_steps,2)
            
            
            [task_ids,init_mess] = jd.split_tasks(common_par,4,false,3);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,3);
            assertEqual(init_mess{1}.n_first_step,1)
            assertEqual(init_mess{1}.n_steps,1)
            
            assertEqual(init_mess{2}.n_first_step,2)
            assertEqual(init_mess{2}.n_steps,1)
            
            assertEqual(init_mess{3}.n_first_step,3)
            assertEqual(init_mess{3}.n_steps,2)
            
            %-------------------------------------------------------------
            
            [task_ids,init_mess] = jd.split_tasks(common_par,loop_par,true,4);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,4);
            assertEqual(init_mess{1}.loop_data,loop_par(1))
            assertEqual(init_mess{2}.loop_data,loop_par(2))
            assertEqual(init_mess{3}.loop_data,loop_par(3))
            assertEqual(init_mess{4}.loop_data,loop_par(4))
            
            [task_ids,init_mess] = jd.split_tasks(common_par,4,true,4);
            n_workers = numel(task_ids);
            
            assertEqual(n_workers,4);
            assertEqual(init_mess{1}.n_first_step,1)
            assertEqual(init_mess{1}.n_steps,1)
            assertEqual(init_mess{2}.n_first_step,2)
            assertEqual(init_mess{2}.n_steps,1)
            assertEqual(init_mess{3}.n_first_step,3)
            assertEqual(init_mess{3}.n_steps,1)
            assertEqual(init_mess{4}.n_first_step,4)
            assertEqual(init_mess{4}.n_steps,1)
            
            
            %-------------------------------------------------------------
            [task_ids,init_mess] = jd.split_tasks(common_par,loop_par,true,5);
            n_workers = numel(task_ids);
            assertEqual(n_workers,4);
            assertEqual(init_mess{1}.loop_data,loop_par(1))
            assertEqual(init_mess{2}.loop_data,loop_par(2))
            assertEqual(init_mess{3}.loop_data,loop_par(3))
            assertEqual(init_mess{4}.loop_data,loop_par(4))
            assertEqual(init_mess{4}.n_first_step,1)
            assertEqual(init_mess{4}.n_steps,1)
            %-------------------------------------------------------------
            
        end
        
        
    end
end

