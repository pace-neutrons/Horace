function f_mat = spec_to_secondary (obj)
% Matrix to convert coordinates in spectrometer frame into secondary spectrometer frame
%
%   >> f_mat = spec_to_secondary (obj)
%
% Input:
% ------
%   obj     IX_detector_array object
%
% Output:
% -------
%   f_mat   Array size [3,3,ndet] that gives the matricies to convert from
%           primary spectrometer (or laboratory) coordinate frame into those
%           in the secondary spectrometer frame (i.e. x axis along kf,
%           y radially outwards.


if ~isscalar(obj)
    error('Only operates on a single detector array object (i.e. object must be scalar');
end

if numel(obj.det_bank_)>1
    tmp = arrayfun(@spec_to_secondary, obj.det_bank_,'uniformOutput',false);
    f_mat = cat(3,tmp{:});
else
    f_mat = spec_to_secondary(obj.det_bank_);
end
