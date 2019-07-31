function [ok, mess,this] = isvalid (this)
% Check fields for data_array object
%
%   >> [ok, mess] = isvalid (w)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.
%
%
% Original author: T.G.Perring
%
% 	15 August 2009  Pass w to checkfields, so that checkfields can alter fields
%                   of object. Because checkfields is a private method, the fields
%                   can be altered using w.x=<new value> *without* calling
%                   set.m. (T.G.Perring)

% check numeric
numeric_fld = {'S','ERR','efix','en','emode','n_detectors'};
lattice_fld = {'alatt','angdeg','u','v','psi','omega','dpsi','gl','gs'};

for i=1:numel(numeric_fld)
    [ok,mess]=check_field(this,numeric_fld{i});
    if ~ok
        return;
    end
end

if this.is_crystal
    for i=1:numel(lattice_fld)
        [ok,mess]=check_field(this.lattice,lattice_fld{i});
        if ~ok
            return;
        end
        
    end
    
end

function [ok,mess]=check_field(class,field_name)
ok = true;
mess='';
if ~isempty(class.(field_name))
    if ~isa(class.(field_name),'numeric')
        ok = false;
        val = class.(field_name);
        if ~ischar(val)
            if isemtpy(val)
                val = 'empty';
            else
                val = 'unexpected (not empty and not error string)';
            end
        end
        mess = [' field: ',field_name,' has to be numeric but its value is: ',val];
        return
    end
end


