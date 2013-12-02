function [ok,mess,Sout] = isvalid (this,S)
% Dummy isvalid routine to be called if there is not for a configuration class
%
%   >> [ok,mess,Sout] = isvalid (this,S)
%
% Input:
% ------
%   this    An instance of the class
%   S       A structure with fieldnames that are configuration parameters
%          and values that are to be tested as valid
%
% Output:
% -------
%   ok      True if all OK, false otherwise
%   mess    Message if not ok, empy otherwise
%   Sout    A structure with the fields possibly updated
%          For example, it may be that a field is required to be a logical
%          but this routine can be used to convert a numeric to a logical
%          as Sout.myflag=logical(S.myflag)

% Default return
ok=true;
Sout=S;
mess='';
