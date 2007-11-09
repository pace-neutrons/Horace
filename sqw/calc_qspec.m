function qspec=calc_qspec (efix, emode, data, det)
% Calculate the components of Q in spectroemter fixed w.r.t. spectrometer
%
%   >> [qspec,eps]=calc_qspec (efix, emode, data, det)
%
%   efix    Fixed energy (meV)
%   emode   Direct geometry=1, indirect geometry=2
%   data    Data structure of spe file (see get_spe)
%   det     Data structure of par file (see get_par)
%
%   qspec(4,ne*ndet)    Momentum and energy transfer in spectrometer coordinates
%
%  Note: We sometimes use this routine with the energy bin boundaries replaced with 
%        bin centres i.e. have fudged the array data.en

% T.G.Perring 15/6/07

% *** May benefit from translation to fortran, partly for speed but mostly to reduced
% internal storage; could iomporve things in Matlab by unpacking the line that
% files qspec(1:3,:)

%k_to_e = 2.07214;
k_to_e = 2.07;  % value currently used in mslice

% Get components of Q in spectrometer frame (x || ki, z vertical)
[ne,ndet]=size(data.S);
qspec=zeros(4,ne*ndet);
if emode==1
    ki=sqrt(efix/k_to_e);
    if length(data.en)==ne+1
        eps=(data.en(2:end)+data.en(1:end-1))/2;    % get bin centres
    else
        eps=data.en;        % just pass the energy values as bin centres
    end
    kf=sqrt((efix-eps)/k_to_e); % [ne x 1]
    detdcn=[cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];   % [3 x ndet]
    qspec(1:3,:) = repmat([ki;0;0],[1,ne*ndet]) - ...
        repmat(kf',[3,ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    qspec(4,:)=repmat(eps',1,ndet);
else
    error('EMODE=2 not yet implemented')
end
