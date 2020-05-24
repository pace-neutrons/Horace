function the_dir= tmp_dir()
% Substitute standard tmp folder with users tmp folder
% for iDaaaS machines where standard tmp folder is randomly clearned up.
%
% Returns:
% tmp_dir     tempdir value on any machine  and (userpath()/tmp)
%            (usually /home/user_name/Documents/MATLAB/tmp) folder if the machine is
%            identified as iDaaaaS machine.
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
%

if is_idaaas()
    location = userpath();
    if isempty(location)
        location = fileparts(which('startup.m'));
    end
    if isempty(location)
        location = getenv('HOME');        
    end
    the_dir = fullfile(location,'tmp');
    % dereference simulinks and obtain real path
    [~,fatr] = fileattrib(the_dir);
    the_dir = [fatr.Name,filesep];
    if ~(exist(the_dir,'dir') == 7)
        mkdir(the_dir);
    end
else
    the_dir = tempdir();
end