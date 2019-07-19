function is_daas = is_idaaas(comp_name)
% Function to verify if the computer is iDaaaS virtual machine.
%
% normaly works without the arguments, and returns true if the computer is
% iDaaaS virtual machine.

% if input string is present, the routie works in test mode and
% identifies if the computer is iDaaaS computer by parsing the input.
%
%
test_mode = false;
if exist('comp_name','var')
    test_mode = true;
end

if ~test_mode
    if ispc || ismac
        is_daas = false;
        return;
    end
    comp_name = getComputerName();
end
name_template = 'host_192_168_243';
if strncmpi(comp_name,name_template,numel(name_template))
    is_daas = true;
else
    is_daas = false;
end
