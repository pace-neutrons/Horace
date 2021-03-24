function [ok,sqw_obj,dnd_obj]=is_horace_data_object(w)
% Determine if an argument is a Horace object (sqw, d0d, d1d, d2d, d3d, d4d)
sqw_obj=isa(w,'sqw');
dnd_obj=(isa(w,'d0d')||isa(w,'d1d')||isa(w,'d2d')||isa(w,'d3d')||isa(w,'d4d'));
ok=sqw_obj|dnd_obj;
