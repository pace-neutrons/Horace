function qspec=calc_qspec_emode1 (Detectors,efix,en,k_to_e)
% Calculate the components of Q in reference frame fixed w.r.t. spectrometer
%
%   >> qspec = calc_qspec (efix, emode, data, det)
%
%   efix    Fixed energy (meV)
%   k_to_e  constant of the neutron energy transformation into the the
%           neutron wave vector
%   emode   Direct geometry=1, indirect geometry=2, elastic=0
%   data    Data structure of spe file (see get_spe)
%   det     Data structure of par file (see get_par)
%
%   qspec(4,ne*ndet)    Momentum and energy transfer in spectrometer coordinates
%
%  Note: We sometimes use this routine with the energy bin boundaries replaced with 
%        bin centres i.e. have fudged the array data.en

% T.G.Perring 15/6/07

% *** May benefit from translation to fortran, partly for speed but mostly to reduced
% internal storage; could improve things in Matlab by unpacking the line that
% files qspec(1:3,:)
% *** the emode=1 has been translated to frotran at the version after 259;
%     ofher modes not yet (04/09/2009)
%
% $Revision$ ($Date$)
%

% Get components of Q in spectrometer frame (x || ki, z vertical)
ne  = numel(en);
ndet=getNDetectors(Detectors);
det  = getDetStruct(Detectors);
qspec=zeros(4,ne*ndet);
ki=sqrt(efix/k_to_e);
if length(en)==ne+1
     eps=(en(2:end)+en(1:end-1))/2;    % get bin centres
else
      eps=en;        % just pass the energy values as bin centres
end
kf=sqrt((efix-eps)/k_to_e); % [ne x 1]
detdcn=[cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];   % [3 x ndet]
qspec(1:3,:) = repmat([ki;0;0],[1,ne*ndet]) - ...
                      repmat(kf',[3,ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
qspec(4,:)=repmat(eps',1,ndet);
