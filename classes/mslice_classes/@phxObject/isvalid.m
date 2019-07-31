function [ok, mess, wout] = isvalid (w)
% Check fields for data_array object
%
%   >> [ok, mess] = isvalid (w)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.

% Generic method. Needs specific private function checkfields

% Original author: T.G.Perring
%
% 	15 August 2009  Pass w to checkfields, so that checkfields can alter fields
%                   of object. Because checkfields is a private method, the fields
%                   can be altered using w.x=<new value> *without* calling
%                   set.m. (T.G.Perring)

[ok,mess,wout] = checkfields(w);
