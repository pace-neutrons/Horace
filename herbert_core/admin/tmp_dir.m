function the_dir= tmp_dir()
% Substitute standard tmp folder with users tmp folder
% for iDaaaS machines where standard tmp folder is randomly clearned up.
%
% Returns:
% tmp_dir   tempdir value on any machine
%
%            userpath()/tmp    (usually /home/user_name/Documents/MATLAB/tmp)
%            folder if the machine is identified as iDaaaaS machine.
%
%            workspace_location//tmp if the machine is identified as Jenkins
%
[is_jen,~,workspace] = is_jenkins();
if is_jen
    the_dir = build_tmp_dir(workspace);
    return
end

if is_idaaas()
    location = userpath();
    if isempty(location)
        location = fileparts(which('startup.m'));
    end
    if isempty(location)
        location = getenv('HOME');
    end
    the_dir = build_tmp_dir(location);
    
    % dereference simulinks and obtain real path
    [~,fatr] = fileattrib(the_dir);
    the_dir = [fatr.Name,filesep];
    if ~(is_folder(the_dir))
        mkdir(the_dir);
    end
else
    the_dir = tempdir();
end
%
function the_dir = build_tmp_dir(location)
the_dir = fullfile(location,'tmp');
if ~(is_folder(the_dir))
    [ok,the_dir,mess] = try_to_create_folder(location,'tmp');
    if ~ok
        warning('HERBERT:tmp_dir:runtime_error',...
            ' Can not create temporary folder in user directory: %s. Reason: %s Reverting to system tmp folder',...
            location,mess);
        the_dir = tempdir();
    end
end
