function mem_size = sys_memory()
% Return approximated computer memory size in bytes.
%
% Wraps Matlab memory command on Windows and tries to execute appropriate
% system commands on linux-like os.
%
% if nothing works, assumes 8Gb size
%
Gb = 1024*1024*1024;
if ispc
    [~,sys] = memory();
    mem_size = sys.PhysicalMemory.Total;
elseif isunix

    [nok,mem_string] = system('free | grep Mem');
    if nok
        mem_size = 8*Gb;
    else
        mem_size = parse_mem_string(mem_string);
    end
else
    mem_size = 8*Gb;
end

function mem_size = parse_mem_string(mem_string)
cont = regexp(mem_string,'\s+','split');
mem_size =  sscanf(cont{2},'%d')*1024;
