function obj = set_real_memory_available_(obj,val,warn_on_settings)
%SET_REAL_MEMORY_AVAILABLE_ stores the value of the calculated memory
%available in configuration for further usage
%
% Inputs:
% val              -- the assumed physical memory value available for
%                     application
% warn_on_settings -- if true, warn user that he is setting some value
%
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
        'Attempt to set up physical memory estimate (%d), which is smaller then size of default memory-based sqw object (%d)', ...
        val,def_size)
end
if warn_on_settings
    warning('HORACE:physical_memory_configured', ...
        ['You have specified the value for free physical memory.\n' ...
        ' If this value is too small, the code performance may be substanially degraded\n' ...
        ' and if it is too big, the application may fail.\n' ...
        ' Normally you should set empty value here and allow Horace to evaluate avaliable memory by itself.'])
end
config_store.instance().store_config(obj,'real_memory_available',val);
