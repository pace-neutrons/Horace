function the_dir= tmp_dir()
% Substitute standard tmp folder with users tmp folder
% for iDaaaS machines where standard tmp folder is randomly clearned up.
%
% Returns:
% tmp_dir     tempdir value on any machine  and (userpath()/tmp)
%            (usually /home/user_name/Documents/MATLAB/tmp) folder if the machine is
%            identified as iDaaaaS machine.
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
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
    if ~(exist(the_dir,'dir') == 7)
        mkdir(the_dir);
    end
else
    the_dir = tempdir();
end