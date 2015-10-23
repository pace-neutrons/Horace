function ok = isequal_par(det1,det2)
% Checks if two detector structures are identical apart from the names of the files from which they were read
%
%   >> ans = isequal_par(det1,det2)
%
% Input:
% ------
%   det1, det2      Detector parameter structures of Tobyfit format (see (get_par)
%
% Output:
% -------
%   ok              Logical, set to true if the structures are equal (apart from the
%                  name and path to the files)

ok=true;

%Old code:
% ok = ok && all(size(det1.group)==size(det2.group)) && all(det1.group==det2.group);
% ok = ok && all(size(det1.x2)==size(det2.x2)) && all(det1.x2==det2.x2);
% ok = ok && all(size(det1.phi)==size(det2.phi)) && all(det1.phi==det2.phi);
% ok = ok && all(size(det1.azim)==size(det2.azim)) && all(det1.azim==det2.azim);
% ok = ok && all(size(det1.width)==size(det2.width)) && all(det1.width==det2.width);
% ok = ok && all(size(det1.height)==size(det2.height)) && all(det1.height==det2.height);

%RAE code - introduce tolerance on diff of parameters, apart from group, to
%allow for specific case of hyspec where encoder noise can result in
%different detector parameter data.
tol=1e-3;
ok = ok && all(size(det1.group)==size(det2.group)) && all(det1.group==det2.group);
ok = ok && all(size(det1.x2)==size(det2.x2)) && all(abs(det1.x2-det2.x2)<tol);
ok = ok && all(size(det1.phi)==size(det2.phi)) && all(abs(det1.phi-det2.phi)<tol);
ok = ok && all(size(det1.azim)==size(det2.azim)) && all(abs(det1.azim-det2.azim)<tol);
ok = ok && all(size(det1.width)==size(det2.width)) && all(abs(det1.width-det2.width)<tol);
ok = ok && all(size(det1.height)==size(det2.height)) && all(abs(det1.height-det2.height)<tol);
