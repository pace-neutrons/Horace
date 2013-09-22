function phx=phxObject(par)
% Convert a parObject to a phxObject
%
%   >> phxObject(par)
%
% Input:
% ------
%   par     parObject (i.e. object with .par detector information)
%
% Output:
% -------
%   phx     phxObject (i.e. object with .phx detector parameters)

dummy=phxObject;
phx.filename=dummy.filename;    % Ensures default dehaviour
phx.filepath=dummy.filepath;
phx.group=par.group;
phx.phi=par.phi;
phx.azim=par.azim;
phx.dphi=(360/pi)*atan(0.5*par.width./par.x2);
phx.danght=(360/pi)*atan(0.5*par.height./par.x2);

phx=phxObject(phx);
