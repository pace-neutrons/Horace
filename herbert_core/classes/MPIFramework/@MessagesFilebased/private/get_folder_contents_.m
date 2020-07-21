function fc = get_folder_contents_(obj,mess_folder)
% Utility function to retrieve folder contents under Windows
% trying not to open and block message files.
%
fc = dir(mess_folder);
