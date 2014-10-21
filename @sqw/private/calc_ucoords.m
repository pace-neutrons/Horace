function ucoords=calc_ucoords (efix, k_to_e, emode, en, detdcn, id, ie)
% Calculate the components of Q in reference frame fixed w.r.t. spectrometer
%
%   >> qspec = calc_qspec (efix, k_to_e, emode, data, det)
%
% Input:
% ------
%   efix        Fixed energy (meV)
%   k_to_e      Constant in the relation energy (meV) = k_to_e *(wavevector^2)
%   emode       Direct geometry=1, indirect geometry=2, elastic=0
%               If elastic, then interprets energy bins as logarithm of wavelength (Ang)
%   en          Energy transfer at bin centres
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%               [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%   spec_to_pix Matrix to convert spectrometer coordinates
%               (x-axis along ki, z-axis vertically upwards) to pixel coordinates.
%               Need to account for the possibility that the crystal has been reoriented,
%               in which case the pixels are no longer in crystal Cartesian coordinates.
%   id          Index of detector into detdcn
%   ie          Index of energy bin
%
% Output:
% -------
%   ucoords     Coordinate of pixels (size=[4,numel(id)])


% Original author: T.G.Perring
%
% $Revision: 882 $ ($Date: 2014-07-20 10:12:36 +0100 (Sun, 20 Jul 2014) $)

    
% Get components of Q in spectrometer frame (x || ki, z vertical)
if emode==1
    en=en(ie)';
    ki=sqrt(efix/k_to_e);
    kf=sqrt((efix-en)/k_to_e);
    qspec = repmat([ki;0;0],1,numel(id)) - repmat(kf,3,1).*detdcn(:,id);
    
elseif emode==2
    en=en(ie)';
    ki=sqrt((efix+en)/k_to_e);
    kf=sqrt(efix/k_to_e);
    qspec = [ki;zeros(2,numel(id))] - kf*detdcn(:,id);

elseif emode==0
    lambda=exp(en(ie)');    % The en array is assumed to have bin centres as the logarithm of wavelength
    k=(2*pi)./lambda;
    Q_by_k = repmat([1;0;0],1,numel(id)) - detdcn;
    qspec = repmat(k',[3,ndet]).*Q_by_k;
    en=zeros(1,numel(id));
    
else
    error('EMODE must =1 (direct geometry), =2 (indirect geometry), or =0 (elastic)')
    
end

ucoords = [spec_to_u*qspec;en];
