function display_single (w)
% Display useful information from phx object
%
%   >> display_single(w)

% Original author: T.G.Perring

ndet=numel(w.group);
if ndet==1
    disp(['Detector data for ',num2str(ndet),' detector in .phx format'])
else
    disp(['Detector data for ',num2str(ndet),' detectors in .phx format'])
end
disp(' ')
