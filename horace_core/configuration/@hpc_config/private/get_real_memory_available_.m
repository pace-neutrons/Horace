function mem = get_real_memory_available_(obj)
%GET_REAL_MEMORY_AVAILABLE_ checks availability and returns real memory
%available to Horace if this memory has been pre-calculated or calculates
%this memory, stores it in configuration and returns it to users if this
%memory has not been stored before.
%

if obj.is_field_configured('real_memory_available')
    mem = config_store.instance.get_value(obj,'real_memory_available');
    try
        data = zeros(floor(mem/8),1);
        ok   = true;
    catch
        ok = false;
    end
    if ok
        clear data;
        return
    end
else
    mem  = [];
end
set_real_memory_available_(obj,mem,false);
