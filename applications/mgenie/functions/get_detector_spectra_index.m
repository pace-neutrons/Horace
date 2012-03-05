function [id,is]=get_detector_spectra_index(detpar,speclist)
% Get the indicies into detector structure of the detectors that contribute to a list spectra for the currently assigned run
%
%   >> [id,is]=get_detector_spectra_ind(detpar,speclist)
%
%   detpar      Detector structure (see get_detector_par)
%   speclist    List of spectrum numbers (must be unique)
%
%   id          Indicies of detectors that contribute to the spectra
%   is          Indicies, one per detector, into speclist

% Perform some checks
if min(speclist)<1 || max(speclist)>double(gget('nsp1'))    % Check the spectra are contained in the spectrum list
    error(['Spectrum numbers out of range 1-',num2str(gget('nsp1'))])
elseif ~numel(unique(speclist))==numel(speclist)
    error('Spectrum list does not contain unique spectrum numbers')
end

% Get indicies into detector structure and of the spectrum numbers to which the detectors contribute
spec=gget('spec');
[id,is]=array_filter(spec,speclist);    % detector indicies required, and index into speclist of corresponding spectrum (assumes uspeclist is unique for this to work)
udet=gget('udet');
[dummy,id]=array_filter(udet(id),detpar.det_no); % indicies into detector parameter arrays
