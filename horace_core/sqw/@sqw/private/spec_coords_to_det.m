function [d_mat, detdcn] = spec_coords_to_det (detpar)
% Matrix to convert coordinates in spectrometer (or laboratory) frame into detector frame
%
%   >> d_mat = spec_coords_to_det (detpar)
%
% Input:
% ------
%   detpar      Detector parameter structure with fields as read by get_par
%
% Output:
% -------
%   d_mat       Matrix size [3,3,ndet] to take coordinates in spectrometer
%              frame and convert in detector frame.
%
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%               [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%
% The detector frame is one with x axis along kf, y radially outwards. This is the
% original Tobyfit detector frame.

ndet=numel(detpar.x2);
cp=reshape(cosd(detpar.phi),[1,1,ndet]);
sp=reshape(sind(detpar.phi),[1,1,ndet]);
cb=reshape(cosd(detpar.azim),[1,1,ndet]);
sb=reshape(sind(detpar.azim),[1,1,ndet]);

d_mat=[             cp, cb.*sp, sb.*sp;...
                   -sp, cb.*cp, sb.*cp;...
       zeros(1,1,ndet),    -sb,     cb];
   
detdcn=[cp; cb.*sp; sb.*sp];
