function [phys_memory,free_memory]=horace_memory()
%HORACE_MEMORY Simple system-indepentent utility used by Horace to identify
% its type for proper auto-configuration
%
% Returns:
% phys_memory  -- physical memory installed on the computer
% free_memory  -- free memory available for utilites.
%                 Returns these parameters empty if the memory
%                 identification does not work.

if ispc
    [~,sys] = memory();
    phys_memory = sys.PhysicalMemory.Total;
    free_memory = sys.PhysicalMemory.Available;
elseif isunix
    if ismac
        [nok,mem_string] = system('top -l 1 -n 0');
        if ~nok
            [phys_memory,free_memory] = parse_mac_mem_string(mem_string);
        end
    else % normal Unix
        [nok,mem_string] = system('free | grep Mem');
        if ~nok
            [phys_memory,free_memory] = parse_mem_string(mem_string);
        end
    end
    if nok
        phys_memory = [];
        free_memory = [];
    end
end

function [phys_memory,free_memory] = parse_mem_string(mem_string)
% Analyze result of free function on linux
try
    cont = regexp(mem_string,'\s+','split');
    phys_memory =  1024*sscanf(cont{2},'%d');
    free_memory =  1024*sscanf(cont{4},'%d');
catch
    phys_memory = [];
    free_memory = [];

end

function [phys_memory,free_memory] = parse_mac_mem_string(mem_string)
% Analyze result of MAC top -l 1 -n 0 function.
%
try
    mem_ind = strfind(mem_string,'PhysMem');
    cont = regexp(mem_string(mem_ind:end),'\s+','split');

    phys_memory = extract_dig(cont{2});
    free_memory =  extract_dig(cont{4});% unclear if it is correct, probably not
    %                                   % this value contains something different
    %                                   % as this value is not yet used
    %                                   properly -- keep it as it is
catch
    phys_memory = [];
    free_memory = [];
end

function dig = extract_dig(str)
str_pos = regexp(str,'\d*');
str = str(str_pos:end);
dig = sscanf(str,'%d');
if isempty(dig)
    dig = 0;
    return;
end
Mb = 1024*1024;
Gb = 1024*Mb;
if strcmp(str(end),'G')
    dig=Gb*dig;
else
    dig=Mb*dig;
end

