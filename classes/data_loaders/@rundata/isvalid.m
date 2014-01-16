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
numeric_fld = {'S','ERR','efix','en','emode','n_detectors',...
    'alatt','angldeg','u','v','psi','omega','dpsi','gl','gs'};
ok=true;
mess='';
for i=1:numel(numeric_fld)
    if ~isempty(this.(numeric_fld{i}))
        if ~isa(this.(numeric_fld{i}),'numeric')
            ok = false;
            val = this.(numeric_fld{i});
            if ~isstring(val)
                if isemtpy(val)
                    val = 'emtpy';
                else
                    val = 'unexpected (not empty and not error string)';
                end
            end
            mess = [' field: ',numeric_fld{i},' has to be numeric but its value is: ',val];
            return
        end
    end
end


