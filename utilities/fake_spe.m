function varargout = fake_spe(varargin)
% Generates a fake .spe data, optionally writing to file, so that simulations can be performed.
%
% Generate data structure only:
%   >> data = fake_spe (ndet,ebins)
%   >> data = fake_spe (ndet,emin,de,emax)
%   >> data = fake_spe (...,psi)
%
% Create spe file
%   >> fake_spe (ndet,ebins,filename,filepath))
%   >> fake_spe (ndet,emin,de,emax,filename,filepath)
%   >> fake_spe (...,psi)
%
% Input:
% ------
%   ndet        no. of detectors
%              e.g. ndet=36864 for MAPS, ndet=69632 for Merlin
%
%   emin        minimum neutron energy transfer (lower bin boundary)
%   de          energy bin width
%   emax        maximum neutron energy transfer
% *OR*
%   ebins       array of energy bin boundaries (all equally spaced bins)
%
%   filename    name of the spe file to be generated
%   filepath 	folder in which to place spe file
%
% Optional argument (specialists only)
%   psi         If give psi angle, set the signal to this value
%               and error bars to unity;
%
% Output:
% -------
%   data        Data structure with fields:
%                   filename    Name of spe file (excluding path)
%                   filepath    Path to spe file
%                   en          Energy bin boundaries
%                   S           Signal array (ne x ndet)
%                   ERR         Error bars (ne x ndet)

% RE 8/4/08.
% TGP 6/3/12: Tidied a bit and different argument list permitted.
% TGP 8/2/13: Return data structure alone as an option.

if nargin>=4 && isnumeric(varargin{1}) && isnumeric(varargin{2}) &&...
        isnumeric(varargin{3}) && isnumeric(varargin{4})  % arg list is (ndet,emin,de,emax,...
    ndet=varargin{1};
    energy=(varargin{2}:varargin{3}:varargin{4})';  % column vector
    filename='';
    filepath='';
    if nargin==4
        file_given=false;
        psi_given=false;
    elseif nargin==5 && isnumeric(varargin{5})
        file_given=false;
        psi_given=true;
        psi=varargin{5};
    elseif nargin==6 || nargin==7
        if ischar(varargin{5}) && ischar(varargin{6})
            file_given=true;
            filename=varargin{5};
            filepath=varargin{6};
        else
            error('Check finepath and filename are character strings')
        end
        if nargin==7
            psi_given=true;
            psi=varargin{7};
        else
            psi_given=false;
        end
    else
        error('Check input arguments')
    end
    
elseif nargin>=2 && isnumeric(varargin{1}) && isnumeric(varargin{2})    % arg list is (ndet,emin,de,emax,...
    ndet=varargin{1};
    energy=varargin{2}(:);  % column vector
    filename='';
    filepath='';
    if nargin==2
        file_given=false;
        psi_given=false;
    elseif nargin==3 && isnumeric(varargin{3})
        file_given=false;
        psi_given=true;
        psi=varargin{3};
    elseif nargin==4 || nargin==5
        if ischar(varargin{3}) && ischar(varargin{4})
            file_given=true;
            filename=varargin{3};
            filepath=varargin{4};
        else
            error('Check finepath and filename are character strings')
        end
        if nargin==5
            psi_given=true;
            psi=varargin{5};
        else
            psi_given=false;
        end
    else
        error('Check input arguments')
    end
    
else
    error('Check number of input arguments')
end

% Make S and ERR matrix of ones, so that when combined in an sqw file we
% should be able to work out how good the errorbars on our measurement will be.
if psi_given
    S=psi.*(ones(numel(energy)-1,ndet));
    ERR=ones(size(S));
else
    S=randn(numel(energy)-1,ndet);
    ERR=rand(size(S));
end

% Create data structure
data.filename=filename; % needed here as constructor will not work otherwise
data.filepath=filepath;
data.S=S;
data.ERR=ERR;
data.en=energy;

% Fill output, if present
if nargout>0
    varargout{1}=data;
end

% Create output file, if requested
if file_given
    newloc=fullfile(filepath,filename);
    w=spe(data);    % use mslice class @spe
    save(w,newloc);
end
