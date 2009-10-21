function ok = isequal_par(det1,det2)
% Checks if the detector parameters are equal for two detector structures
% (apart from the names of the files from which they were read)
%
%   >> ans = isequal_par(det1,det2)
%
%   det1, det2      Detector parameter structures of Tobyfit format (see (get_par)
%   ok              Logical, set to true if the structures are equal (apart from the
%                  name and path to the files)

ok=true;

ok = ok && all(size(det1.group)==size(det2.group)) && all(det1.group==det2.group);
ok = ok && all(size(det1.x2)==size(det2.x2)) && all(det1.x2==det2.x2);
ok = ok && all(size(det1.phi)==size(det2.phi)) && all(det1.phi==det2.phi);
ok = ok && all(size(det1.azim)==size(det2.azim)) && all(det1.azim==det2.azim);
ok = ok && all(size(det1.width)==size(det2.width)) && all(det1.width==det2.width);
ok = ok && all(size(det1.height)==size(det2.height)) && all(det1.height==det2.height);
