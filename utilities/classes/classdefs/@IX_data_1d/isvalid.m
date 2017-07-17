function [ok,mess] = isvalid(obj)
% Check common fields for data_array object are consistent between each
% other
%
%   >> [ok, mess] = isvalid (w)
%
% or throwing form:
%   >> obj = isvalid (w)
%   >> isvalid(w)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.
%
%  second (throwing) form should be called from a program after changing
%  x,signal, error using set operations to make sure the object
%  was changed properly. Throws IX_dataset_1d:invalid_argument if the
%  dataset has inconsistent fields or return valid object otherwise.
%
% Original author: T.G.Perring
%
% 	15 August 2009  Pass w to checkfields, so that checkfields can alter fields
%                   of object. Because checkfields is a private method, the fields
%                   can be altered using w.x=<new value> *without* calling
%                   set.m. (T.G.Perring)

if ~obj.valid_
    [ok,mess] = check_common_fields_(obj);
    if nargout < 2
        if ok
            obj.valid_ = true;
        else
            error('IX_dataset_1d:invalid_argument',mess);
        end
        ok = obj;
    end
else
    ok = true;
    mess = [];
end

