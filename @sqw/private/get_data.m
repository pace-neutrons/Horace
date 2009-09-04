function [data,det,keep,det0]=get_data(spe_data,par_file)
% Load spe file and detector parameter file to create data structure, removing
% masked detector groups and masking any other pixels that contain null data
%
%   >> [data,det,keep,det0]=get_data(spe_file,par_file)
%
%   spe_file        File name of spe file
%   par_file        File name of detector parameter file
%   
%   data            Data structure containing data for unmasked detectors
%                  (see get_spe for list of fields)
%   det             Data structure containing detector parameters for unmasked
%                  detectors (see get_par for fields)
%   keep            List of the detector groups that were unmasked
%   det0            Data structure of detector parameters before masking

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
[data,spe_data]=exportData(spe_data);   % export spe into the format requested, 
                                        % if data have not been loaded before, 
                                        % they are loaded from the linked
                                        % file now
deflate(spe_data); % delete spe data from memory to save space in the memory, 
                   % if data were in spe format only, this operation
                   % generates h5 from the spe too;
det0=get_par(par_file);

% Check length of detectors in spe file and par file are same
ndet=size(data.S,2);
if ndet~=length(det0.phi)
   disp(['.spe file ' data.filename ' and .par file ' det0.filename ' not compatible']);
   disp(['Number of detectors is different: ' num2str(ndet) ' and ' num2str(length(det0.phi))]);
   return
end

% Determine detector groups and other pixels to mask
[keep,pixmask]=mask_spe(data);
data=section_spe(data,keep);% Remove masked detectors from data
if ~isempty(pixmask)        % Mask other pixels if necessary
    data.S(pixmask)=NaN;
    data.ERR(pixmask)=0;
end
det=section_par(det0,keep); % Remove masked detectors from detector parameters
