function [qspec,en]=calc_qspec (obj,detdcn)
% Calculate the components of Q in reference frame fixed w.r.t. spectrometer
%
%   >> qspec = obj.calc_qspec (detdcn)
%
% Input:
% ------
%   obj     defined rundatah object with all data loaded in memory
%   detdcn  Direction of detector in spectrometer coordinates ([3 x ndet] array)
%             [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
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
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


% Get components of Q in spectrometer frame (x || ki, z vertical)
[ne,ndet]=size(obj.S);
c=neutron_constants;
k_to_e = c.c_k_to_emev;  % used by calc_projections_c;

if obj.emode==1
    ki=sqrt(obj.efix/k_to_e);
    if length(obj.en)==ne+1
        eps=(obj.en(2:end)+obj.en(1:end-1))/2;    % get bin centres
    else
        eps=obj.en;        % just pass the energy values as bin centres
    end
    kf=sqrt((obj.efix-eps)/k_to_e); % [ne x 1]
    qspec = repmat([ki;0;0],[1,ne*ndet]) - ...
        repmat(kf',[3,ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    en=repmat(eps',1,ndet);
    
elseif obj.emode==2
    %kf=sqrt(obj.efix(:)'/k_to_e);
    kf=sqrt(obj.efix/k_to_e);
    if length(obj.en)==ne+1
        eps=(obj.en(2:end)+obj.en(1:end-1))/2;    % get bin centres
    else
        eps=obj.en;        % just pass the energy values as bin centres
    end
    if numel(obj.efix) > 1
        ki = sqrt(bsxfun(@plus,obj.efix(:)',eps(:))/k_to_e); % [ne x n_det]
        if size(ki,2) ~=ndet
            error('RUNDATAH:invalid_argument',...
                'Number of detector''s energies in indirect mode(%d) must be equal to the number of detectors %d',...
                size(ki,2),ndet);
        end
        nde = ndet*ne;
        qspec = [reshape(ki,1,nde);zeros(2,nde)]  - ...
            reshape(repmat(kf,[ne,1,3]),[nde,3])'.*...
            reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,nde]);
    else
        ki=sqrt((obj.efix+eps(:))/k_to_e); % [ne x 1]
        % building sequence Det1{dE1,dE2,...dEN},Det2{dE1,dE2,...dEN}... DetN{dE1,dE2,...dEN}
        % note [3,_1_,ndet] vs [1,_ne_,1]
        qspec = repmat([ki';zeros(2,ne)],[1,ndet]) - ...
            kf*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    end
    en=repmat(eps',1,ndet);
    
elseif obj.emode==0
    % The data is assumed to have bin boundaries as the logarithm of wavelength
    if length(obj.en)==ne+1
        lambda=(exp(obj.en(2:end))+exp(obj.en(1:end-1)))/2;    % get bin centres
    else
        lambda=exp(obj.en);        % just pass the values as bin centres
    end
    k=(2*pi)./lambda;   % [ne x 1]
    Q_by_k = repmat([1;0;0],[1,ndet]) - detdcn;   % [3 x ndet]
    qspec = repmat(k',[3,ndet]).*reshape(repmat(reshape(Q_by_k,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    en=zeros(1,ne*ndet);
    
else
    error('RUNDATAH:invalid_argument','EMODE must =1 (direct geometry), =2 (indirect geometry), or =0 (elastic)')
end
