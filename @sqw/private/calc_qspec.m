function [qspec,en]=calc_qspec (efix, k_to_e, emode, data, detdcn)
% Calculate the components of Q in reference frame fixed w.r.t. spectrometer
%
%   >> qspec = calc_qspec (efix, k_to_e, emode, data, det)
%
% Input:
% ------
%   efix    Fixed energy (meV)
%   k_to_e  Constant in the relation energy (meV) = k_to_e *(wavevector^2)
%   emode   Direct geometry=1, indirect geometry=2, elastic=0
%           If elastic, then interprets energy bins as logarithm of wavelength (Ang)
%   data    Data structure of spe file (see get_spe)
%   detdcn  Direction of detector in spectrometer coordinates ([3 x ndet] array)
%               [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%
% Output:
% -------
%   qspec   Momentum in spectrometer coordinates
%           (x-axis along ki, z-axis vertically upwards) ([3,ne*ndet] array)
%   en      Energy transfer for all pixels ([1,ne*ndet] array)
%
%  Note: We sometimes use this routine with the energy bin boundaries replaced with 
%        bin centres i.e. have fudged the array data.en

% T.G.Perring 15/6/07

% *** Only emode=1 has been translated to c++ as of 04/09/2009
%
% $Revision$ ($Date$)

    
% Get components of Q in spectrometer frame (x || ki, z vertical)
[ne,ndet]=size(data.S);
if emode==1
    ki=sqrt(efix/k_to_e);
    if length(data.en)==ne+1
        eps=(data.en(2:end)+data.en(1:end-1))/2;    % get bin centres
    else
        eps=data.en;        % just pass the energy values as bin centres
    end
    kf=sqrt((efix-eps)/k_to_e); % [ne x 1]
    qspec = repmat([ki;0;0],[1,ne*ndet]) - ...
        repmat(kf',[3,ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    en=repmat(eps',1,ndet);
    
elseif emode==2
    kf=sqrt(efix/k_to_e);
    if length(data.en)==ne+1
        eps=(data.en(2:end)+data.en(1:end-1))/2;    % get bin centres
    else
        eps=data.en;        % just pass the energy values as bin centres
    end
    ki=sqrt((efix+eps)/k_to_e); % [ne x 1]
    qspec = repmat([ki';zeros(1,ne);zeros(1,ne)],[1,ndet]) - ...
        repmat(kf,[3,ne*ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    en=repmat(eps',1,ndet);

elseif emode==0
    % The data is assumed to have bin boundaries as the logarithm of wavelength
    if length(data.en)==ne+1
        lambda=(exp(data.en(2:end))+exp(data.en(1:end-1)))/2;    % get bin centres
    else
        lambda=exp(data.en);        % just pass the values as bin centres
    end
    k=(2*pi)./lambda;   % [ne x 1]
    Q_by_k = repmat([1;0;0],[1,ndet]) - detdcn;   % [3 x ndet]
    qspec = repmat(k',[3,ndet]).*reshape(repmat(reshape(Q_by_k,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    en=zeros(1,ne*ndet);
    
else
    error('EMODE must =1 (direct geometry), =2 (indirect geometry), or =0 (elastic)')
    
end
