function write_sqw(sqw_obj,filename)
% write sqw object into recent-format binary sqw file
% Input:
% sqw_obj -- proper sqw object
% filename -- file with the name to write
%

ldr = sqw_formats_factory.instance().get_pref_access(sqw_obj);
ldr = ldr.init(sqw_obj,filename);
ldr = ldr.put_sqw();
ldr.delete();
