function copy_git_hooks(pack_name)
% Function installs git hooks for users who is going to push into
% git repository
%
init_file = [lower(pack_name),'_init'];
root_folder = fileparts(fileparts(which(init_file)));
if isempty(root_folder)
    error('COPY_GIT_HOOKS:invalid_argument',' Can not find package %s init file',init_file);
end
if ~(exist(fullfile(root_folder,'.git'),'dir') == 7) || ...
        ~(exist(fullfile(root_folder,'.githooks'),'dir') == 7)
    % not a git repository
    return;
end

source_folder = fullfile(root_folder,'.githooks');
target_folder = fullfile(root_folder,'.git','hooks');

copyfile([source_folder ,filesep,'*'],target_folder);


