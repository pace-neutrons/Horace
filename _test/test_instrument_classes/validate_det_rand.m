function [ok, mess] = validate_det_rand (det, nsamples, ntol, npath, wvec)
% Test statistics of random sampling of points of absorbtion in detectors.
% Checks that the random point sampling algorithm and deterministic calculations
% of moments agree within statistic errors.
%
% Independent of detector type 
%
%   >> [ok, mess] = validate_det_rand (det, nsamples, ntol, npath, wvec)
%
% Input:
% ------
%   det         Instance of IX_det_abstractType (e.g. IX_det_He3tube) for a
%               single detector.
%   nsamples    Number of sampling points e.g. 10^5
%   ntol        Tolerance: difference between computed moments and those
%               calculated from random sampling must agree to within a multiple
%               of ntol of the estimated standard error computed from the random
%               sampling. A good value is e.g. 5
%   npath       Vector giving the direction of travel of the neutron with
%               respect to the detector coordinate frame (need not be
%               normalised, as this is performed internally)
%   wvec        Neutron wavevector at which to perform the calculation (scalar)
%
% Output:
% -------
%   ok          True if tolerance criteria are met for all moments (mean and 
%               covariance of the sampling point vectors)
%   mess        Empty string if ok==true, error message if ok==false


npath = npath / norm(npath);
X = det.rand(ones(nsamples,1), npath, wvec);

% Statistical analysis of random points
[mean_val, sig_mean, sig_val, sig_sig, cov_val, sig_cov] = ...
    sampling_statistics (X');

% Expected values
mean_pos = det.mean(npath, wvec)';
sig_pos = sqrt(diag(det.covariance(npath, wvec))');
cov_pos = det.covariance(npath, wvec);

% Check agreement within statistical error
ok = true;
mess = '';
if ~all (abs(mean_val - mean_pos) < ntol * sig_mean)
    ok = false;
    mess = [mess, 'mean point of absorption from random sampling is outside tolerance\n'];
end

if ~all (abs(sig_val - sig_pos) < ntol * sig_sig)
    ok = false;
    mess = [mess, 'mean point of absorption from random sampling is outside tolerance\n'];
end

if ~all (abs(cov_val - cov_pos) < ntol * sig_cov)
    ok = false;
    mess = [mess, 'mean point of absorption from random sampling is outside tolerance\n'];
end
