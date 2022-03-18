function [ok, mess,obj] = check_combo_arg(obj)
% Check interdependent fields of rundata class
%
%   >> [ok, mess] = check_combo_arg(w)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.
%
%

if isempty(obj.lattice)
    ok = true;
    mess = '';
else
    [ok,mess,obj.lattice] = obj.lattice.check_combo_arg();
end
%
obj.isvalid_ = ok;
if ok
    [undefined,~,fields_undef] = obj.check_run_defined();
    if undefined >1
        obj.isvalid_=false;
        ok = false;
        mf = strjoin(fields_undef,'; ');
        mess = sprintf('run is undefined. Need to define missing fields: %s',mf);
    end
end
