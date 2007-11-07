function [keep,pixmask]=mask_spe(data)
% Determine the un-masked detectors in an SPE data file, and a logical array of
% any other pixels to mask in other detectors
%
%   >> [keep,pixmask]=mask_spe(data)
%   
%   data        spe data structure as read by load_spe
%   
%   keep        Row vector of the detector groups that are unmasked
%              These are the groups where all pixels are masked
%   pixmask 	Logical array, size(pixmask)=data.S(:,keep), with true
%              at those pixels with need to masked. This is returned as
%              empty if there are no pixels to be masked.

null_data=-1e30;    % conventional null in the VMS spe file format

[ne,ndet]=size(data.S);
pixmask=(~isfinite(data.S) | data.S<=null_data);
keep=1:ndet;
keep=keep(sum(pixmask,1)~=ne);  % List of detector groups where not all pixels are masked
if length(keep)==ndet
    disp('No detectors were masked')
else
    disp(['Masked ',num2str(ndet-length(keep)),' detector groups out of ',num2str(ndet)])
end

if ~isempty(keep)
    pixmask=pixmask(:,keep);        % Logical array of pixels to be masked in the unmasked detector groups
    npixmask=sum(pixmask(:));
    if npixmask~=0
        disp(['Masked additional ',num2str(npixmask),' pixels out of ',num2str(ne*length(keep)), ' pixels'])
    else
        pixmask=[]; % return as empty if no pixels masked
    end
else
    pixmask=[]; % return as empty if no pixels masked
end
    
