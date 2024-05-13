function mem = set_phys_mem_available_(obj,mem,warn_on_settings)
%SET_PHYS_MEM_AVAILABLE_ stores the value of the calculated memory
%available in configuration for further usage
%
% Inputs:
% mem              -- the assumed physical memory value available for
%                     application. Expressed in bytes.
%                     Empty value causes memory recalculation.
%
% warn_on_settings -- if true, warn user that he is setting some value
%                     of memory which may be incorrect.
% Returns
% mem              -- value of physical memory stored in config_store.
%
%

if isempty(mem)
    mem = hpc_config.calc_free_memory();
    warn_on_settings = false;
end

if mem <=0
    error('HORACE:hpc_config:invalid_argument', ...
        'Physical memory available should be value larger then 0')
end
[mchs,fbs] = config_store.instance().get_value( ...
    'hor_config','mem_chunk_size','fb_scale_factor');
def_size = mchs*fbs*PixelDataBase.DEFAULT_PIX_SIZE;
%
enable_warning = ~obj.disable_setup_warnings;
if mem<def_size && enable_warning
    warning('HORACE:insufficient_physical_memory', ...
        ['Estimated free physical memory (%dMB) is smaller then size of default memory-based sqw object (%dMB)\n' ...
        'The default mem-based object size defined as the product of hor_config: mem_chunk_size (%d) and fb_scale_factor (%d) converted in MB'], ...
        floor(mem/(1024*1024)),floor(def_size/(1024*1024)), ...
        mchs,fbs)
end
if warn_on_settings && enable_warning
    warning('HORACE:physical_memory_configured', ...
        ['You have specified the value for free physical memory.\n' ...
        ' If this value is too small, the code performance may be substantially degraded.\n' ...
        ' If it is too big, the application may fail.\n' ...
        ' Normally you should set empty value here and allow Horace to evaluate available memory by itself.'])
end
config_store.instance().store_config(obj,'phys_mem_available',mem);
