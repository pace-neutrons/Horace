function phx=get_phx_matlab(phx_filename)
% function phx=get_phx_matlab(filename)
% used to read .phx detector file with angles of all detectors
% first line contains n, number of detector groups
% angles twotheta, psi, dtwotheta, dpsi (all in deg)
% are in a columns 3,4,5,6 of subsequent table
% (the other columns 1,2,7 contain redundant parameters hept for historical
% reasons of compatibility with other programs like phoenix)
% twotheta = total scattering angles always >0
% psi = azimuthal angle, defines such that
%       on HET 2.5m bank has psi=0(W), 90(N), 180(E) and 270(S)
%       on IRIS all PG002 detectors have psi=0
%       psi=0 defines the principal scattering plane
% dtwotheta = thickness of detector in 2theta (enlarged
%         compared to the physical detector thickness to cover
%         small gaps between adjacent detectors
% dpsi(deg) = azimuthal angular width (degrees)
% example file het\2m_32.phx for HET 2.5m West bank
%32
%10.0   0.0  9.31 0.0  0.63  6.9 1
%10.0   0.0  9.93 0.0  0.63  6.9 1
%10.0   0.0 10.56 0.0  0.63  6.9 1
% ...
% returned phx is
% phx=rows of [detector_number twotheta(deg) psi(deg) dtwotheta(deg) dpsi(deg)]
% [7 x nunmber of detectors]
%
% R. Coldea    ? 
% I.Bustinduy  17/08/08

% Remove blanks from beginning and end of filename
phx_filename=strtrim(phx_filename);

% === return if error opening phx_filename
if ~exist('phx_filename','var')|isempty(phx_filename),
   phx=[];
   return;
end
fid=fopen(phx_filename,'rt');
if fid==-1,
   disp(['Error opening file ' phx_filename]);
   phx=[];
   return
end
               
% === load detector information in .phx format
phx=fscanf(fid,'%f');
disp(['Loading .phx file with ' num2str(phx(1)) ' detectors : ' phx_filename]);
fclose(fid);
             
phx=reshape(phx(2:length(phx)),7,phx(1));
%phx=phx(:,[7 3 4 5 6]);
%phx=[detector_number theta psi dtheta dpsi] 3-column vector
%theta=total scattering angle (deg)
%psi=azimuthal scattering angle (deg)
end