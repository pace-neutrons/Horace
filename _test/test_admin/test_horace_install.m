classdef test_horace_install < TestCase
    
    properties
        this_folder;
    end
    
    methods
        
        function obj=test_horace_install(~)
            obj = obj@TestCase('test_horace_install');
            obj.this_folder = fileparts(mfilename('fullpath'));
        end
        function copy_install_files(~,source_files,target_folder)
            
            for i=1:numel(source_files)
                source = which(source_files{i});
                [~,tn,te] = fileparts(source);
                targ = fullfile(target_folder,[tn,te]);
                copyfile(source,targ,'f');
            end
        end
        function test_files_in_folder_like_cloned_repo_clean(obj)
            test_install = fullfile(obj.this_folder,'folder_for_install_repo');
            mkdir(test_install);
            test_admin = fullfile(test_install,'Horace','admin');
            mkdir(test_admin);
            clob = onCleanup(@()(rmdir(test_install,'s')));
            
            template_files = {'horace_install.m','horace_on.m.template',...
                'worker_v2.m.template'};
            obj.copy_install_files(template_files,test_admin);
            hor_test_source = fullfile(test_install,'Horace','horace_core');
            mkdir(hor_test_source);
            init_files = {'horace_init.m'};
            obj.copy_install_files(init_files ,hor_test_source);
            
            her_test_source= fullfile(test_install,'Herbert','herbert_core');
            mkdir(her_test_source);
            init_files = {'herbert_init.m'};
            obj.copy_install_files(init_files ,her_test_source);
            her_admin = fullfile(fileparts(her_test_source),'admin');
            mkdir(her_admin);
            obj.copy_install_files({'herbert_on.m.template'} ,her_admin);
            
            path_list_recover = cell(1,1);
            n_path = 0;
            old_hor_path = fileparts(which('horace_on.m'));
            while ~isempty(old_hor_path)
                rmpath(old_hor_path);
                n_path = n_path+1;
                path_list_recover{n_path} = old_hor_path;
                old_hor_path = fileparts(which('horace_on.m'));
            end
            clob2 = onCleanup(@()addpath(path_list_recover{:}));
            
            current_dir = pwd;
            cd(test_admin);
            clob1 = onCleanup(@()cd(current_dir));
            
            
            [install_folder,her_init_dir,hor_init_dir] = horace_install('-test_mode');
            new_install = fullfile(test_install,'ISIS');
            assertEqual(new_install,install_folder);
            assertEqual(her_test_source,her_init_dir);
            assertEqual(hor_test_source,hor_init_dir);
            clear clob1;
            clear clob2;
        end
        
        function test_files_in_folder_like_installation_dir(obj)
            test_install = fullfile(obj.this_folder,'folder_for_install_tests');
            mkdir(test_install);
            clob = onCleanup(@()(rmdir(test_install,'s')));
            
            template_files = {'horace_install.m','horace_on.m.template',...
                'worker_v2.m.template','herbert_on.m.template'};
            obj.copy_install_files(template_files,test_install);
            hor_test_source = fullfile(test_install,'Horace');
            mkdir(hor_test_source);
            init_files = {'horace_init.m'};
            obj.copy_install_files(init_files ,hor_test_source);
            
            her_test_source= fullfile(test_install,'Herbert');
            mkdir(her_test_source);
            init_files = {'herbert_init.m'};
            obj.copy_install_files(init_files ,her_test_source);
            
            current_dir = pwd;
            cd(test_install);
            clob1 = onCleanup(@()cd(current_dir));
            
            [install_folder,her_init_dir,hor_init_dir] = horace_install('-test_mode');
            assertEqual(fileparts(which('horace_on')),install_folder);
            assertEqual(her_test_source,her_init_dir);
            assertEqual(hor_test_source,hor_init_dir);
            clear clob1;
        end
        
        function test_folder_provided(~)
            herbert_code = fileparts(fileparts(which('herbert_init')));
            %disp('*********** herbert code:')
            %disp(herbert_code)
            horace_code = fileparts(fileparts(which('horace_init')));
            %disp('*********** horace code:')
            %disp(horace_code)
            
            [install_folder,her_init_dir,hor_init_dir] = horace_install(...
                'herbert_root',herbert_code,...
                'horace_root',horace_code,'-test_mode');
            assertEqual(fileparts(which('horace_on')),install_folder);
            assertEqual(fullfile(herbert_code,'herbert_core'),her_init_dir);
            assertEqual(fullfile(horace_code,'horace_core'),hor_init_dir);
        end
        
    end
    
end
