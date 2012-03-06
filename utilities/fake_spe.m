function fake_spe(varargin)
%Generates a fake .spe file so that simulations can be performed.
%
%   >> fake_spe(ndet,emin,de,emax,filename,filepath,psi)
% OR
%   >> fake_spe(ndet,ebins,filename,filepath,psi)
%
%   ndet        no. of detectors
%              e.g. ndet=36864 for MAPS.
%                   ndet=69632 for Merlin
%
%   emin        minimum neutron energy transfer (lower bin boundary)
%   de          energy bin width
%   emax        maximum neutron energy transfer
% OR
%   ebins       array of energy bin boundaries (all equally spaced bins)
%
%   filename    name of the spe file to be generated
%   filepath 	folder in which to place spe file
%

%RE 8/4/08. Tidied a bit by TGP 6/3/12 and different argument list permitted

if nargin==7
    ndet=varargin{1};
    energy=(varargin{2}:varargin{3}:varargin{4})';  % column vector
    filename=varargin{5};
    filepath=varargin{6};
    psi=varargin{7};
elseif nargin==5
    ndet=varargin{1};
    energy=varargin{2}; energy=energy(:);  % column vector
    filename=varargin{3};
    filepath=varargin{4};
    psi=varargin{5};
end

% Make S and ERR matrix of ones, so that when combined in an SQW file we
% should be able to work out how good the errorbars on our measurement will be.
S=psi.*(ones(numel(energy)-1,ndet));
ERR=ones(size(S));

temp.filename=filename; % needed here as constructor will not work otherwise
temp.filepath=filepath;
temp.S=S;
temp.ERR=ERR;
temp.en=energy;

newloc=fullfile(filepath,filename);
w=spe(temp);    % use mslice class @spe
save(w,newloc);
