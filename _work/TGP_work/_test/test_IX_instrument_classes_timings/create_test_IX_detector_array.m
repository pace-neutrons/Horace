function D = create_test_IX_detector_array (nbank, ndet, opt)
% Create a test IX_detector_array
%
%   >> D = create_test_IX_detector_array (nbank, ndet)
%
%   >> D = create_test_IX_detector_array (nbank, ndet, 'rand')      % same as above
%   >> D = create_test_IX_detector_array (nbank, ndet, 'norand')
%
% Input:
% ------
%   nbank   Number of nanks (scalar)
%   ndet    Number of detectors in each bank (scalar or array)
%  'rand'   Random variation in detector data from call to call [default]
%  'norand' Deterministic output


% Parse input
if isscalar(ndet)
    ndet = ndet*ones(1,numel(nbank));
end

if nargin==2
    rand_data = true;
else
    if strncmpi(opt,'rand',numel(opt))
        rand_data = true;
    elseif strncmpi(opt,'norand',numel(opt))
        rand_data = false;
    else
        error('Check option')
    end
end


% Create detector array
dbank = repmat(IX_detector_bank,1,nbank);

nend = cumsum(ndet);
nbeg = nend - ndet + 1;
for i=1:nbank
    if rand_data
        x2 = 6+rand(1,ndet(i));
        phi = 10+160*rand(1,ndet(i));
        azim = 360*rand(1,ndet(i));
        hdet = 0.03+0.005*rand(1,ndet(i));
        det = IX_det_He3tube(0.0254,hdet,6.35e-4,10);
    else
        x2 = 6+((1:ndet(i))/1e6);
        phi = 10+160*((1:ndet(i))/1e6);
        azim = 360*((1:ndet(i))/1e6);
        hdet = 0.03+0.005*((1:ndet(i))/1e6);
        det = IX_det_He3tube(0.0254,hdet,6.35e-4,10);
    end
    dbank(i) = IX_detector_bank (nbeg(i):nend(i),x2,phi,azim,det);
end

D = IX_detector_array(dbank);
