function [is_daas,size_suffix] = is_idaaas(comp_name)
% Function to verify if the computer is iDaaaS virtual machine.
%
% normally works without the arguments, and returns true if the computer is
% iDaaaS virtual machine.

% if input string is present, the route works in test mode and
% identifies if the computer is iDaaaS computer by parsing the input.
%
%
size_suffix = '';
test_mode = false;
if exist('comp_name', 'var')
    test_mode = true;
end

if ~test_mode
    if ispc || ismac
        is_daas = false;
        return;
    end
    comp_name = getComputerName();
end
name_templates = {'host_192_168_243','host_172_16'};
is_name = cellfun(@(nt)strncmpi(comp_name,nt,numel(nt)),...
    name_templates,'UniformOutput',true);
if any(is_name)
    is_daas = true;
else
    is_daas = false;
end
if nargout>1 && is_daas
    [nok,mess] = system('lscpu');
    if nok  % MAC or strange unix without lscpu
        is_daas = false;
        size_suffix = '';
        return;
    end

    cpu_pos = strfind(mess,'CPU(s)');
    mess = strsplit(mess(cpu_pos(1):end));
    n_cpu = str2double(mess{2});
    if n_cpu >= 10
        size_suffix = 'large';
    else
        size_suffix = 'small';
    end
end


