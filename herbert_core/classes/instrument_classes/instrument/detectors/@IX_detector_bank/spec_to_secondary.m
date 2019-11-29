function f_mat = spec_to_secondary (obj)
% Matrix to convert coordinates in spectrometer frame into secondary spectrometer frame
%
%   >> f_mat = spec_to_secondary (obj)
%
% Input:
% ------
%   obj     IX_detector_bank object
%
% Output:
% -------
%   f_mat   Array size [3,3,ndet] that gives the matricies to convert from
%           primary spectrometer (or laboratory) coordinate frame into those
%           in the secondary spectrometer frame (i.e. x axis along kf,
%           y radially outwards.

ndet = obj.ndet;
cp=reshape(cosd(obj.phi_),[1,1,ndet]);
sp=reshape(sind(obj.phi_),[1,1,ndet]);
cb=reshape(cosd(obj.azim_),[1,1,ndet]);
sb=reshape(sind(obj.azim_),[1,1,ndet]);

f_mat=[             cp, cb.*sp, sb.*sp;...
                   -sp, cb.*cp, sb.*cp;...
       zeros(1,1,ndet),    -sb,     cb];
