function [ok, mess] = checkfields (d)
% Check fields for sigvar object
%
%   >> [ok, mess] = checkfields (d)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid sqw object, empty string if is valid.

% Original author: T.G.Perring
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)

fields = {'s';'e'};  % column

ok=false;
mess='';
if isequal(fieldnames(d),fields)
    if ~(isnumeric(d.s) && isnumeric(d.e) && (isequal(size(d.s),size(d.e))||isequal(size(d.e),[0,0])))
        mess='Numeric array sizes for fields ''y'' and ''e'' incompatible';
        return
    end
    if any(d.e<0)
        mess='One or more elements of field ''e'' <0';
        return
    end
else
    mess='fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
