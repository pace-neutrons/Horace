function ucoords=calc_ucoords (kfix, emode, k, en, detdcn, id, ie)
% Calculate the components of Q in reference frame fixed w.r.t. spectrometer
%
%   >> qspec = calc_qspec (efix, k_to_e, emode, data, det)
%
% Input:
% ------
%   kfix        Fixed wavevector (Ang^-1)
%   emode       Direct geometry=1, indirect geometry=2, elastic=0
%   k           Wavevector at bin centres (Ang^-1)
%   en          Energy transfer at bin centres (meV)
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
    qspec = repmat([kfix;0;0],1,numel(id)) - repmat(k(ie')',3,1).*detdcn(:,id);
    eps=en(ie')';   % ensures is a row vector, even if en is scalar
    
elseif emode==2
    qspec = [k(ie')';zeros(2,numel(id))] - kfix*detdcn(:,id);
    eps=en(ie')';   % ensures is a row vector, even if en is scalar

elseif emode==0
    Q_by_k = repmat([1;0;0],1,numel(id)) - detdcn;
    qspec = repmat(k(ie')',[3,ndet]).*Q_by_k;
    eps=zeros(1,numel(id));
    
else
    error('EMODE must =1 (direct geometry), =2 (indirect geometry), or =0 (elastic)')
    
end

ucoords = [spec_to_u*qspec; eps];
