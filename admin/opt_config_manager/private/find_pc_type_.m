function [pc_type,nproc] = find_pc_type_(obj)
% find pc type as option of the pc properties.
types = obj.known_pc_types_;
Gb = 1024*1024*1024;
nproc = 0;
if ispc
    [~,sys] = memory();
    if sys.PhysicalMemory.Total <  32*Gb
        pc_type = types{1}; %windows small
    elseif sys.PhysicalMemory.Total  >= 32*Gb
        if sys.PhysicalMemory.Available >= 0.5*sys.PhysicalMemory.Total
            nproc = idivide(int64(sys.PhysicalMemory.Total),int64(32*Gb),'floor');
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
    if ismac %MAC
        pc_type = types{3};
        return;
    end
    [nok,mess] = system('lscpu');
    if nok  %still MAC or strange unix without lscpu
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

