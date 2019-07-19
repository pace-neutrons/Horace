function [pc_type,nproc,mem_size] = find_comp_type_()
% find pc type as option of the pc properties.
types = opt_config_manager.known_pc_types_;
Gb = 1024*1024*1024;
nproc = 1;
if ispc
    [~,sys] = memory();
    mem_size = sys.PhysicalMemory.Total;
    if mem_size <  32*Gb
        pc_type = types{1}; %windows small
    else
        if sys.PhysicalMemory.Available >= 0.5*sys.PhysicalMemory.Total
            nproc = idivide(int64(mem_size),int64(obj.mem_size_per_worker_*Gb),'floor');
            if nproc >1
                pc_type = types{2}; %windows large
            else
                pc_type = types{1};  %windows small
            end
        else
            pc_type = types{1};%windows small
        end
    end
    
elseif isunix
    [ok,mem_string] = system('free | grep Mem');
    if ~ok
        mem_size = 16*Gb;
    else
        mem_size = parse_mem_string(mem_string);
    end
    if ismac %MAC
        pc_type = types{3};
        return;
    end
    [nok,mess] = system('lscpu');
    if nok  %still MAC or strange unix without lscpu. Assuming mac.
        pc_type = types{3};
        return;
    end
    
    rez=strfind(mess,'NUMA node');
    if numel(rez)>2; hpc_computer = true;
    else;          hpc_computer = false;
    end
    is_virtual = is_idaaas();
    if is_virtual
        n_profile = 6;
    else
        n_profile = 4;
    end
    
    if hpc_computer
        n_profile=n_profile+1;
    end
    pc_type = types{n_profile};

end

function mem_size = parse_mem_string(mem_string)
cont = regexp(mem_string,'\s+','split');
mem_size =  sscanf(cont{2},'%d');
