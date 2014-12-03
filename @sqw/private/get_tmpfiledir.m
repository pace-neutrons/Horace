function tmpfiledir=get_tmpfiledir
% Get folder for temporary files. Apparently tempdir alone can cause problems
% on (some?) unix as the space allocated can be very small.

% Original author: T.G.Perring
%
% $Revision: 909 $ ($Date: 2014-09-12 18:20:05 +0100 (Fri, 12 Sep 2014) $)

if ispc
    tmpfiledir=tempdir;
else
    [status,val]=fileattrib(pwd);
    if val.UserWrite && val.UserRead
        tmpfiledir=pwd;
    else
        tmpfiledir=tempdir;
    end
end
