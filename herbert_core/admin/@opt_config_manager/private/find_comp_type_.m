function [pc_type,nproc,phys_mem] = find_comp_type_(obj)
% find pc type as function of the pc properties, like memory size number of
% processors, etc.
%
% TO DO:
% Does not currently identify number of processors properly. Only rough
% estimate or no estimate at all. (Dealt with this issue elsewhere, but future
% improvements/merging may be necessary to address this)
%

Gb = 1024*1024*1024;
types = obj.known_pc_types_;

% if routine was not able to identify the memory size, it assumes 8*Gb
[phys_mem,free_mem] = sys_memory();
%
nproc = idivide(int64(phys_mem),int64(obj.mem_size_per_worker_*Gb),'floor');
if ispc
    if phys_mem <  32*Gb
        pc_type = types('win_small'); %windows small
    else
        if free_mem >= 0.5*phys_mem
            if nproc >2
                pc_type = types('win_large'); %windows large
            else
                pc_type = types('win_small');  %windows small
            end
        else
            pc_type = types('win_small');%windows small
        end
    end
    if is_jenkins()
        pc_type = types('jenkins_win');  % 'jenkins_win'
    end
elseif isunix
    if ismac %MAC
        pc_type = types('a_mac');
        return;
    end
    [nok,mess] = system('lscpu');
    if nok  %still MAC or strange unix without lscpu. Assuming mac.
        pc_type = types('a_mac');
        return;
    end

    rez=strfind(mess,'NUMA node');
    % if lscpu returns more then one numa node strings, first string defines
    % the number of numa nodes and all subsequent strings describe each
    % node. So, if there are more then 2 string, its more then one numa
    % node and we consider this computer to be an hpc system.
    hpc_computer = numel(rez)>2 || nproc>4;
    
    [is_virtual,size_type] = is_idaaas();
    if is_virtual
        if strcmp(size_type,'large')
            pc_type = types('idaaas_large');            
        else
            pc_type = types('idaaas_small');                        
        end        
    else
        if hpc_computer
            size_type = 'large';
        end
        if strcmp(size_type,'large')
            pc_type = types('unix_large');            
        else
            pc_type = types('unix_small');                        
        end                       
    end
    %
    if is_jenkins()
        pc_type = types('jenkins_unix');  % 'jenkins_unix'
        return;
    end
end

