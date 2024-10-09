classdef test_horace_install < TestCase

    properties
        this_folder;
    end

    methods

        function obj=test_horace_install(~)
            obj = obj@TestCase('test_horace_install');
            obj.this_folder = fileparts(mfilename('fullpath'));
        end
        function [hor_unpack,herbert_unpack]=find_hor_her_location(~)
            % Identify where actually Horace code is unpacked on the system
            % when code checked out from Github for developers or by
            % Jenkins
            %
            %WARNING! not absolute or smart. Relies on convention from
            %2022/06/15
            hor_unpack = fileparts(fileparts(which('horace_init')));
            herbert_unpack = fileparts(fileparts(which('herbert_init')));
            if isempty(herbert_unpack)
                [path0,hor_root] = fileparts(hor_unpack);
                if strcmp(hor_root,'Horace') % is Horace alongside Herbert or inside
                    herbert_unpack = fullfile(path0,'Horace');
                else
                    herbert_unpack = fullfile(hor_unpack,'Horace');
                end
            end
        end
        %
        function test_init_folder_provided_with_isis(obj)
            %
            new_init_path =fullfile(tmp_dir(),'ISIS');
            % check if somebody indeed installed Horace there.
            % Test verifies installation in new place.
            if strcmp(fullfile(new_init_path),fileparts(which('horace_on')))
                new_init_path = fullfile(new_init_path,'TestISIS');
            end

            [install_folder,hor_init_dir,use_old_init_path] = ...
                horace_install('init_folder',new_init_path,'-test_mode');

            [hor_unpack,herbert_unpack]=obj.find_hor_her_location();

            assertEqual(install_folder,fullfile(tmp_dir(),'ISIS'));
            assertEqual(hor_init_dir,fullfile(hor_unpack,'horace_core'));
            assertEqual(hor_unpack,herbert_unpack);

            assertFalse(use_old_init_path);
        end

        function test_init_folder_provided(obj)
            %
            new_init_path = tmp_dir();
            % check if somebody indeed installed Horace there.
            % Test verifies installation in new place.
            if strcmp(fullfile(new_init_path,'ISIS'),fileparts(which('horace_on')))
                new_init_path = fullfile(new_init_path,'TestISIS');
            end

            [init_folder,hor_init_dir,use_old_init_path] = ...
                horace_install('init_folder',new_init_path,'-test_mode');

            [hor_unpack,herbert_unpack]=obj.find_hor_her_location();

            assertEqual(init_folder,fullfile(tmp_dir(),'ISIS'));
            assertEqual(hor_unpack,herbert_unpack);
            assertEqual(hor_init_dir,fullfile(hor_unpack,'horace_core'));
            assertFalse(use_old_init_path);
        end
        %
        function test_warning_on_nonadmin_install(obj)
            %
            % hide tested warnings from being displayed when the test runs
            ws = struct('identifier',{'MATLAB:DELETE:Permission','HORACE:installation'},...
                'state',{'off','off'});
            warning(ws)
            ws(1).state = 'on';
            ws(2).state = 'on';
            % do not forget to recover the warnings when finished with
            % tests
            clob = onCleanup(@()warning(ws));

            % throw DELETE warning and test
            warning('MATLAB:DELETE:Permission','test delete permission warning');
            [init_folder,hor_init_dir,use_old_init_folder] = horace_install('-test_mode');
            [~,id]=lastwarn();
            assertEqual(id,'HORACE:installation');


            [hor_unpack,herbert_unpack]=obj.find_hor_her_location();

            % despite we are testing non-accessible warning, the
            % installation is actually into old init folder
            assertEqual(init_folder,fileparts(which('horace_on')));
            assertFalse(use_old_init_folder)
            assertEqual(hor_unpack,herbert_unpack);
            assertEqual(hor_init_dir,fullfile(hor_unpack,'horace_core'));
        end
        function test_files_in_folder_like_cloned_repo_with_spinW(obj)
            % prepare fake Horace/Herbert code installation tree
            [clOb,hor_root,test_admin,hor_test_source] = ...
                obj.prepare_install_package_structure('folder2install_repo_spinW','admin','horace_core','herbert_core');

            path_list_recover = cell(1,1);
            n_path = 0;
            % clear path to existing Horace init files
            old_hor_path = fileparts(which('horace_on.m'));
            while ~isempty(old_hor_path)
                rmpath(old_hor_path);
                n_path = n_path+1;
                path_list_recover{n_path} = old_hor_path;
                old_hor_path = fileparts(which('horace_on.m'));
            end
            % do not forget to recover path to existing installation
            clob2 = onCleanup(@()addpath(path_list_recover{:}));

            current_dir = pwd;
            cd(test_admin);
            clob1 = onCleanup(@()cd(current_dir));

            spinw_foler = fullfile(hor_root,'spinw_folder');
            [install_folder,hor_init_dir,use_old_init_folder,modified_hor_on_contents] = horace_install('-test_mode','spinW_folder',spinw_foler);
            new_install = fullfile(hor_root,'ISIS');
            assertFalse(use_old_init_folder);

            assertEqual(new_install,install_folder);
            assertEqual(hor_test_source,hor_init_dir);

            clear clob1;
            clear clob2;
            clear clOb;
            assertTrue(contains(modified_hor_on_contents,spinw_foler));
        end
        %
        function test_files_in_folder_like_Jenkins_repo_clean(obj)
            % prepare fake Horace/Herbert code tree
            [clOb,hor_root,test_admin,test_hor_init] = obj.prepare_install_package_structure('folder2install_jenkins_repo','admin','horace_core','herbert_core');

            path_list_recover = cell(1,1);
            n_path = 0;
            % clear path to existing Horace init files
            old_hor_path = fileparts(which('horace_on.m'));
            while ~isempty(old_hor_path)
                rmpath(old_hor_path);
                n_path = n_path+1;
                path_list_recover{n_path} = old_hor_path;
                old_hor_path = fileparts(which('horace_on.m'));
            end
            % do not forget to recover path to existing installation
            clob2 = onCleanup(@()addpath(path_list_recover{:}));

            current_dir = pwd;
            cd(test_admin);
            clob1 = onCleanup(@()cd(current_dir));


            [install_folder,hor_init_dir,use_old_init_folder] = horace_install('-test_mode');
            new_install = fullfile(hor_root,'ISIS');
            assertFalse(use_old_init_folder);

            assertEqual(new_install,install_folder);
            assertEqual(test_hor_init,hor_init_dir);

            clear clob1;
            clear clob2;
        end
        %
        function test_files_in_folder_like_cloned_repo_clean(obj)
            % prepare fake Horace/Herbert code installation tree
            [clOb,hor_root,test_admin,hor_test_source] = obj.prepare_install_package_structure('folder2install_repo','admin','horace_core','herbert_core');

            path_list_recover = cell(1,1);
            n_path = 0;
            % clear path to existing Horace init files
            old_hor_path = fileparts(which('horace_on.m'));
            while ~isempty(old_hor_path)
                rmpath(old_hor_path);
                n_path = n_path+1;
                path_list_recover{n_path} = old_hor_path;
                old_hor_path = fileparts(which('horace_on.m'));
            end
            % do not forget to recover path to existing installation
            clob2 = onCleanup(@()addpath(path_list_recover{:}));

            current_dir = pwd;
            cd(test_admin);
            clob1 = onCleanup(@()cd(current_dir));


            [install_folder,hor_init_dir,use_old_init_folder] = horace_install('-test_mode');
            new_install = fullfile(hor_root,'ISIS');
            assertFalse(use_old_init_folder);

            assertEqual(new_install,install_folder);
            %assertEqual(her_test_source,her_init_dir);
            assertEqual(hor_test_source,hor_init_dir);

            clear clob1;
            clear clob2;
            clear clOb;
        end

        function test_files_in_folder_like_installation_dir(obj)
            % prepare fake horace installation package
            [clOb,install_root,hor_admin,hor_test_source] = obj.prepare_install_package_structure( ...
                'folder_to_install_from_package','','Horace','Horace');
            % move to install folder and test installation

            current_dir = pwd;
            cd(install_root);
            clob1 = onCleanup(@()cd(current_dir));

            [install_folder,hor_init_dir,use_old_init_folder] = horace_install('-test_mode');
            % init folder remains the folder for tested installation
            assertEqual(fileparts(which('horace_on')),install_folder);
            assertTrue(use_old_init_folder);

            assertEqual(install_root,hor_admin);
            assertEqual(hor_test_source,hor_init_dir);

            clear clob1;
            clear clOb;
        end

        function test_folder_provided_old_install_exist(~)
            horace_code = fileparts(fileparts(which('horace_init')));
            %disp('*********** horace code:')
            %disp(horace_code)

            [install_folder,hor_init_dir,use_old_init_path] = horace_install(...
                'horace_root',horace_code,'-test_mode');
            assertEqual(fileparts(which('horace_on')),install_folder);

            assertEqual(fullfile(horace_code,'horace_core'),hor_init_dir);
            assertTrue(use_old_init_path);
        end

    end
    methods(Access=protected)
        function [clOb,fake_install_root,admin_folder,hor_test_init] = ...
                prepare_install_package_structure(obj,source_folder,admin_folder,hor_folder,her_folder)
            % function builds fake directory tree and key files, which represents
            % structure of Horace package obtained from different sources,
            % e.g. GitHub, package or old directory tree and used for
            % running horace_install script on this tree.
            %
            fake_install_root = fullfile(obj.this_folder,source_folder);
            admin_folder      = fullfile(fake_install_root,admin_folder);
            mkdir(admin_folder);
            clOb = onCleanup(@()(rmdir(fake_install_root,'s')));

            template_files = {'horace_install.m','horace_on.m.template',...
                'worker_v4.m.template','spinw_on.m.template'};
            obj.copy_install_files(template_files,admin_folder);
            hor_test_init = fullfile(obj.this_folder,source_folder,hor_folder);
            mkdir(hor_test_init);
            init_files = {'horace_init.m'};
            obj.copy_install_files(init_files ,hor_test_init);

            init_files = {'herbert_init.m'};
            if isempty(her_folder) || strcmp(her_folder,hor_folder)
                her_test_source = hor_test_init;
            else
                her_test_source = fullfile(obj.this_folder,source_folder,her_folder);
                mkdir(her_test_source);
            end

            obj.copy_install_files(init_files ,her_test_source);
        end
        %
        function copy_install_files(~,source_files,target_folder)

            for i=1:numel(source_files)
                source = which(source_files{i});
                [~,tn,te] = fileparts(source);
                targ = fullfile(target_folder,[tn,te]);
                copyfile(source,targ,'f');
            end
        end
    end

end
