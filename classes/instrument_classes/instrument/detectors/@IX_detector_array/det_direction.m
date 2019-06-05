function detdcn = det_direction (obj)
% Matrix to convert coordinates in spectrometer frame into secondary spectrometer frame
%
%   >> detdcn = det_direction (obj)
%
% Input:
% ------
%   obj         IX_detector_array object
%
% Output:
% -------
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%               [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]


if ~isscalar(obj)
    error('Only operates on a single detector array object (i.e. object must be scalar');
end

if numel(obj.det_bank_)>1
    tmp = arrayfun(@det_direction, obj.det_bank_,'uniformOutput',false);
    detdcn = cat(2,tmp{:});
else
    detdcn = det_direction(obj.det_bank_);
end
