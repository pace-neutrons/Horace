function ok=is_horace_data_object(w)
% Determine if an argument is a Horace object (sqw, d0d, d1d, d2d, d3d, d4d)
if isa(w,'sqw')||isa(w,'d0d')||isa(w,'d1d')||isa(w,'d2d')||isa(w,'d3d')||isa(w,'d4d')
    ok=true;
else
    ok=false;
end
