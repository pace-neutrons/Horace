function [efix_val,ok,mess] = efix(win)
% Return the fixed neutron energy for an array of sqw objects. Error if not the same in all objects.
%
%   >> [efix_val,ok,mess] = efix(win)
%
% Input:
% ------
%   win         Array of sqw objects of sqw type
% 
% Output:
% -------
%   efix_val    Fixed neutron energy (meV)
%   ok          Logical flag: =true if all ok, otherwise =false;
%   mess        Error message; empty if OK, non-empty otherwise

[efix_val,ok,mess]=efix_single(win(1));
if ~ok
    if nargout<2, error(mess), else return, end
end
for i=2:numel(win)
    [efix_tmp,ok,mess]=efix_single(win(i));
    if ~ok
        if nargout<2, error(mess), else return, end
    elseif efix_tmp~=efix_val
        ok=false; mess='Not all efix in the array of sqw objects are the same';
        if nargout<2, error(mess), else return, end
    end
end

%------------------------------------------------------------------------------
function [efix_val,ok,mess]=efix_single(w)
% Get efix for a single sqw object, returning an error status if they are not all the same
if ~iscell(w.header)
    efix_val=w.header.efix;
    ok=true; mess='';
else
    header=w.header;
    nrun=numel(header);
    efix_val=header{1}.efix;
    for i=2:nrun
        if header{i}.efix~=efix_val;
            efix_val=0;
            ok=false; mess='Not all efix are the same within one sqw object';
            return
        end
    end
    ok=true; mess='';
end
