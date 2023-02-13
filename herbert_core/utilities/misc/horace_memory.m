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
    [nok,mem_string] = system('free | grep Mem');
    if nok
        phys_memory = [];
        free_memory = [];
    else
        [phys_memory,free_memory] = parse_mem_string(mem_string);
    end
end

function [phys_memory,free_memory] = parse_mem_string(mem_string)
cont = regexp(mem_string,'\s+','split');
phys_memory =  1024*sscanf(cont{2},'%d');
free_memory =  1024*sscanf(cont{4},'%d');
