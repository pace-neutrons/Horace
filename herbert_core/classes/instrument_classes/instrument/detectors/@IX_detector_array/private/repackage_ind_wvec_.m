function [ix, ibank, nind_bank, ind, wvec] = repackage_ind_wvec_ (obj, ind_in, wvec_in)
% Repackage the detector and wavevector arguments
%
%   >> [sz, ix, ibank, ind, wvec] = repackage_ind_args (obj, ind_in, wvec_in)
%
% The repackaging divides the detector indices and wavevector arrays into
% arguments suitable for looping over the contributing detector banks in
% an IX_detector_array object when making calculations of detector
% functions.
%
% Input:
% ------
%   obj         Scalar instance of IX_detector_array object, which may
%               contain one or more detector banks.
%
%   ind_in      Indices of detectors for which to calculate. Scalar or array.
%
%   wvec_in     Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%               If both ind and wvec are arrays, then they must have the same
%               number of elements, but not necessarily the same shape.
%
%
% Output:
% -------
%   ix          Indices that give the positions in ind_in corresponding to
%               the values in ind below. (Column vector)
%
%   ibank       Detector bank indices from which there is at least one
%               detector selected by ind_in. A bank index only appears once
%               no matter how many detectors from that bank are selected by
%               ind_in. The bank indices in ibank are ordered in increasing
%               value of ibank. (Column vector)
%
%   nind_bank   Vector with the number of indices for each of the
%               contributing detector banks: nind_bank(i) is the number of
%               detector indices from ibank(i). (Column vector)
%
%   ind         If the detector indices came from only one detector bank
%               (that is, ibank is a scalar), then ind is an array the same
%               size as ind_in but with the indices converted to the local
%               indexing in that detector bank. (Note that this means if
%               ind_in was scalar, then ind is a scalar.)
%
%               If detector indices came from two or more detector banks,
%               then ind is a column cell array of column vectors, where
%               the nth column vector gives the detector indices within the
%               detector bank ibank(n) converted to the values local to 
%               that detector bank.
%
%   wvec        If wvec_in was scalar, then wvec is scalar: it applies to
%               all detectors whether they came from one bank or more.
%               Otherwise:
%
%               If the detector indices came from only one detector bank
%               (that is, ibank is a scalar), then wvec is a column vector.
%
%               If detector indices came from two or more detector banks,
%               then wvec is a column cell array of column vectors, where
%               the nth column vector gives the values of wvec for the
%               corresponding detector indices in the nth column vector of 
%               ind.
%
%
%   An alternative summary of the output ind and wvec is
%   - If ind_in and wvec_in were both scalar, then ind and wvec are both
%     scalars.
%   - If ind_in was scalar and wvec_in an array, then ind is a scalar and
%     wvec is a column vector.
%   - If ind_in was a vector and wvec_in a scalar, then ind_in is either a
%     column vector (if all in the one detector bank) or a cell array of
%     column vectors (if from two or more detector banks), and wvec is a
%     scalar.
%   - If ind_in and wvec were both arrays (and must have had the same
%     number of elements), then they must have both be either column
%     vectors (detectors all in in one bank) or both be a cell array of
%     column vectors (detectors from two or more detector banks).


% Get the array that gives detector bank for each detector in ind
ndet_bank = arrayfun(@(x)(numel(x.id)), obj.det_bank_);
ind2bank = replicate_iarray(1:numel(ndet_bank), ndet_bank);

% Sort indices by bank index
% Note that if ind_in all come from the one bank, then ix will be
% 1:numel(ind_in) i.e. no reordering
[ibank, ix, nind_bank, nbeg, nend] = unique_extra (ind2bank(ind_in(:)));

% Split indices by bank index, getting local indices within the banks
% There is no need to index via ix if all the ind came from one detector
% bank because in that case ix = 1:numel(ind_in)
ind_offset = cumsum(ndet_bank) - ndet_bank + 1;
if numel(ibank) > 1
    ind = arrayfun(@(ilo,ihi,ioffset)(ind_in(ix(ilo:ihi)) - ioffset + 1), ...
        nbeg, nend, ind_offset(ibank), 'uniformOutput', false);
else 
    ind = ind_in - ind_offset(ibank(1)) + 1;
end

% Repackage wvec_in
if numel(ibank) > 1 && ~isscalar(wvec_in)
    wvec = arrayfun(@(ilo,ihi,ioffset)(wvec_in(ix(ilo:ihi)) - ioffset + 1), ...
        nbeg, nend, ind_offset(ibank), 'uniformOutput', false);
else
    wvec = wvec_in;     % ix=[1,2,..]=>no indexing by ix needed
end
