function [obj,mess] = isvalid(obj)
% Check common fields for data_array object are consistent between each
% other
%
%   >> [obj, mess] = isvalid (w)
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
%  was changed properly. Throws IX_dataset:invalid_argument if the
%  dataset has inconsistent fields or returns validated object otherwise.
%
% validated object has valid_ field set up to true to not invoke repetative
% checks at repetative calls to the objecs.
%
%
% Original author: T.G.Perring
%

if ~obj.valid_
    [ok,mess] = obj.check_joint_fields();
    if nargout < 2
        if ok
            obj.valid_ = true;
        else
            error('IX_dataset:invalid_argument',mess);
        end
    end
else
    mess = [];
end

