function [phys_memory,free_memory]=sys_memory()
%SYS_MEMORY Simple system-independent utility used by Horace to identify
% machine memory and the machine type as function of memory for proper 
% auto-configuration
%
% Returns:
% phys_memory  -- physical memory installed on the computer
% free_memory  -- free memory available for utilities.
%                 Returns these parameters empty if the memory
%                 identification does not work.
% If routine have not able to identify memory size from external calls, it assumes 
% 8Gb machine

if ispc
    [~,sys] = memory();
    phys_memory = sys.PhysicalMemory.Total;
    free_memory = sys.PhysicalMemory.Available;
    ok = true;
elseif isunix
    if ismac
        [err,mem_string] = system('top -l 1 -n 0');
        ok = err == 0;
        if ok
            [phys_memory,free_memory] = parse_mac_mem_string(mem_string);
        end
    else % normal Unix
        [err,mem_string] = system('free | grep Mem');
        ok = err == 0;
        if ok
            [phys_memory,free_memory] = parse_mem_string(mem_string);
        end
    end
end
if ~ok || isempty(phys_memory)
    Gb = 1024*1024*1024;
    phys_memory = 8*Gb;
    free_memory = 8*Gb;
end


function [phys_memory,free_memory] = parse_mem_string(mem_string)
% Analyse result of "free | grep Mem" function on linux
try
    cont = regexp(mem_string,'\s+','split');
    phys_memory =  1024*sscanf(cont{2},'%d');
    free_memory =  1024*sscanf(cont{4},'%d');
catch
    phys_memory = [];
    free_memory = [];
end

function [phys_memory,free_memory] = parse_mac_mem_string(mem_string)
% Analyse result of "top -l 1 -n 0" function on MAC.
%
try
    mem_ind = strfind(mem_string,'PhysMem');
    cont = regexp(mem_string(mem_ind:end),'\s+','split');

    phys_memory = extract_dig(cont{2});
    free_memory = extract_dig(cont{4}); % unclear if it is correct, probably not
    %                                   % this value contains something different
    %                                   % As this value is not yet used
    %                                   % properly -- keep it as it is.
catch
    phys_memory = [];
    free_memory = [];
end

function dig = extract_dig(str)
str_pos = regexp(str,'\d*');
str = str(str_pos:end);
dig = sscanf(str,'%d');
if isempty(dig)
    error('HORACE:utilities:horace_memory', ...
        'can not extract digits, describing memory size from input string: %s',str);
end
Mb = 1024*1024;
Gb = 1024*Mb;
if strcmp(str(end),'G')
    dig=Gb*dig;
else
    dig=Mb*dig;
end

