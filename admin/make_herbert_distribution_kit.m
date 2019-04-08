function make_herbert_distribution_kit(varargin)
% function creates Herbert distribution kit packing all files necessary for
% Herbert to work into single zip file
%
%Usage:
%>>make_herbert_distribution_kit(['-compact'])
% or
%>>make_herbert_distribution_kit([target_dir,'-run_by_horace',['-compact']])
%
%where optional arguments are:
%'-compact'      -- if present, request dropping the demo and test files
%                   with test folders, default -- compress demo and tests
%                   together with main code. 
%
% the second form is used when script is run within
% make_horace_distribution_kit script
%
% 
% To use Herbert  one has to unpack the resulting zip file and add the folder
% where the function herbert_init.m resides to the Matlab search path. 
% alternatively, you can edit the file herbert_init.m.template, file and 
% replace the variable $libisis_path$ and $Horathe_path$ by the actual
% folders  where the files herbert_init.m  and add to the search path the file
% herbert_on.m, 
% after renaming the file herbert_on.m.template to file herbert_on.
% 
% if called without parameters, this function p-codes Horace private
% folders, and removes C source code folders and if with parameter 
% -- compress everything as it is which makes code suitable for further 
% development. 
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)
%
%
keys = {'-compact','-run_by_horace'};
rootpath = fileparts(which('herbert_init')); % MUST have rootpath so that herbert_init, libisis_off included
if isempty(rootpath)
    error('MAKE_HERBERT_DISTRIBUTION_KIT:invalid_argument',' Herbert package have to be initiated to build herbert distribution kit');
end

no_tests    = false;
run_by_horace=false;
horace_target_path='';
if nargin>0
    ic=1;
    in_keys={};
    for i=1:nargin
        if strncmp(varargin{i},'-',1)
            in_keys{ic} = varargin{i};
            ic=ic+1;
        end
    end
    if ic>1
        if ~all(ismember(in_keys,keys))
            non_member=~ismember(in_keys,keys);
            for i=1:sum(non_member)
                if non_member(i)
                    disp(['Unrecognized key: ',in_keys{i}]);
                end
            end
            error('MAKE_HERBERT_DISTRIBUTION_KIT:invalid_argument',' unknown or unsupported key %s',in_keys{i});
        end
    end
   % interpret existing keys    
    if ismember('-compact',in_keys)
        no_tests=true;
    end 
    if ismember('-run_by_horace',in_keys)
        run_by_horace      = true;
        horace_target_path = varargin{1};
        if ~exist(horace_target_path,'dir')
            error('MAKE_HERBERT_DISTRIBUTION_KIT:invalid_argument',...
                'Herbert distribution is run by Horace but Horace target folder: %s does not exist',horace_target_path);
        end
    end
end
%
disp('!===================================================================!')
disp('!==> Preparing HERBERT distribution kit  ===========================!')
disp('!    Start collecting the Herbert program files ====================!')
%
current_dir  = pwd;
build_dir   =  current_dir; 
if run_by_horace
    build_dir = horace_target_path;
end

% if inside Herbert package dir, go away from there:
if strncmpi(build_dir,rootpath,numel(rootpath))
	cd(rootpath);
	cd('../');
    build_dir = pwd;
end

if run_by_horace
    target_Dir = build_dir;
else
    target_Dir=[build_dir,'/ISIS'];
end
her_dir = [target_Dir,'/Herbert'];
copy_files_list(rootpath,her_dir); 

% copy source code files from system directory
copy_files_list(fullfile(rootpath,'_LowLevelCode'),fullfile(her_dir,'_LowLevelCode'),'+_',...
                       'h','cpp','c','f','f90','FOR','sln','vcproj','vfproj','txt','m'); 
%copy_files_list(fullfile(rootpath,'_notes'),fullfile(her_dir,'_notes'),'+_'); 

% copy unit tests and unit test suite if necessary
if ~no_tests   
    copy_files_list(fullfile(rootpath,'_test'),fullfile(her_dir,'_test'),'+_'); 
end

%
disp('!    The HERBERT program files collected successfully ==============!')
% the file which should be modified to install Herbert
install_script=which('herbert_on.m.template');
%
if run_by_horace
    hor_install_script = fullfile(horace_target_path,'horace_on.m.template');
    merge_files(hor_install_script,install_script);
else
    %
    disp('!    Start compressing all necessary files together ================!')
    %     
    copyfile(install_script,fullfile(target_Dir,'herbert_on.m.template'),'f');
    
    her_file_name= 'herbert_distribution_kit.zip';
    if(exist(her_file_name,'file'))
        delete(her_file_name);
    end

    zip(her_file_name,target_Dir);
    if ~strcmp(pwd,current_dir)
        movefile(her_file_name,current_dir);
    end
    cd(current_dir);
%
    disp('!    Files compressed. Deleting the auxiliary files and directories=!')

    if ~strncmp(target_Dir,rootpath,numel(rootpath))
        rmdir(target_Dir,'s');
    end
    disp('!    All done folks ================================================!')
    sound(-1:0.001:1);
    disp('!===================================================================!')
    
end
