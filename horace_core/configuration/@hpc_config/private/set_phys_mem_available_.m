function obj = set_phys_mem_available_(obj,val,warn_on_settings)
%SET_PHYS_MEM_AVAILABLE_ stores the value of the calculated memory
%available in configuration for further usage
%
% Inputs:
% val              -- the assumed physical memory value available for
%                     application
% warn_on_settings -- if true, warn user that he is setting some value
%                     of memory which may be incorrect
% Returns
% obj              -- instance of hpc_config object used as gateway to
%                     change the phys_mem_available property value in
%                     config_store.
%

if isempty(val)
    val = hpc_config.calc_free_memory();
    warn_on_settings = false;
end

if val <=0
    error('HORACE:hpc_config:invalid_argument', ...
        'Physical memory available should be value larger then 0')
end
[mchs,fbs] = config_store.instance().get_value( ...
    'hor_config','mem_chunk_size','fb_scale_factor');
def_size = mchs*fbs*opt_config_manager.DEFAULT_PIX_SIZE;
if val<def_size
    warning('HORACE:insufficient_physical_memory', ...
        ['Estimated physical memory (%dMB) is smaller then size of default memory-based sqw object (%dMB)\n' ...
        'The default Membased object size defineded as production of mem_chunk_size (%d) and fb_scale_factor (%d) converted in MB'], ...
        floor(val/(1024*1024)),floor(def_size/(1024*1024)), ...
        mchs,fbs)
end
if warn_on_settings
    warning('HORACE:physical_memory_configured', ...
        ['You have specified the value for free physical memory.\n' ...
        ' If this value is too small, the code performance may be substantially degraded.\n' ...
        ' If it is too big, the application may fail.\n' ...
        ' Normally you should set empty value here and allow Horace to evaluate available memory by itself.'])
end
config_store.instance().store_config(obj,'phys_mem_available',val);
