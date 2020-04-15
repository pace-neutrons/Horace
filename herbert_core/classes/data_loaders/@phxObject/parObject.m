function par=parObject(phx,x2)
% Convert a phxObject to a parObject
%
%   >> parObject(phx,x2)
%
% Input:
% ------
%   phx     phxObject (i.e. object with .phx detector parameters)
%   x2      Sample-detector distances (m)
%          Array with number of elements equal to the number of 
%          detectors in the phxObject, or a scalar when all distances will
%          be set to this value.
%
% Output:
% -------
%   par     parObject (i.e. object with .par detector information)

ndet=numel(phx.group);
if isscalar(x2)
    x2=x2*ones(1,ndet);
elseif numel(x2)==ndet
    x2=x2(:)';  % ensure x2 is a row vector
else
    error('Number of sample-detector distances must be equal to number of detectors, or a scalar')
end

dummy=parObject;
par.filename=dummy.filename;    % Ensures default dehaviour
par.filepath=dummy.filepath;
par.group=phx.group;
par.x2=x2;
par.phi=phx.phi;
par.azim=phx.azim;
par.width=2*x2.*tand(0.5*phx.dphi);
par.height=2*x2.*tand(0.5*phx.danght);

par=parObject(par);
