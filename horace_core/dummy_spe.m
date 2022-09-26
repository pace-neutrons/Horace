function varargout = dummy_spe(varargin)
% Generates a fake .spe data, optionally writing to file
%
% Generate data structure only:
%   >> data = dummy_spe (ndet,ebins)
%   >> data = dummy_spe (ndet,emin,de,emax)
%
% Create spe file only (no data structure returned)
%   >> dummy_spe (ndet,ebins,filename,filepath))
%   >> dummy_spe (ndet,emin,de,emax,filename,filepath)
%
% Options
%   >> data = dummy_spe (...,S0)         % set all signal values to S0
%   >> data = dummy_spe (...,'mask',ind) % mask the detectors given in ind
%
%
% Input:
% ------
%   ndet        Number of detectors
%              e.g. ndet=36864 for MAPS, ndet=69632 for Merlin
%
%   ebins       Array of energy bin boundaries (all equally spaced bins)
% *OR*
%   emin        Minimum neutron energy transfer (lower bin boundary)
%   de          Energy bin width
%   emax        Maximum neutron energy transfer
%
%   filename    Name of the spe file to be generated
%   filepath 	Folder in which to place spe file
%
% Optional arguments:
%   S0        	Scalar intensity: set the signal to this value
%               and error bars to unity;
%
%   'mask',arr  Logical array length ndet. Where true, set the signal
%               to NaN (his indicates msked detectors)
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


% Strip off 'mask' option
if nargin>=2 && is_string(varargin{end-1}) && strncmpi(varargin{end-1},'mask',min(numel(varargin{end-1}),4))
    narg=nargin-2;
    mask=varargin{end};
else
    narg=nargin;
    mask=[];
end

% Parse the other arguments
if narg>=4 && isnumeric(varargin{1}) && isnumeric(varargin{2}) &&...
        isnumeric(varargin{3}) && isnumeric(varargin{4})  % arg list is (ndet,emin,de,emax,...
    ndet=varargin{1};
    energy=(varargin{2}:varargin{3}:varargin{4})';  % column vector
    filename='';
    filepath='';
    if narg==4
        file_given=false;
        signal_given=false;
    elseif narg==5 && isnumeric(varargin{5})
        file_given=false;
        signal_given=true;
        S0=varargin{5};
    elseif narg==6 || narg==7
        if ischar(varargin{5}) && ischar(varargin{6})
            file_given=true;
            filename=varargin{5};
            filepath=varargin{6};
        else
            error('Check finepath and filename are character strings')
        end
        if narg==7
            signal_given=true;
            S0=varargin{7};
        else
            signal_given=false;
        end
    else
        error('Check input arguments')
    end
    
elseif narg>=2 && isnumeric(varargin{1}) && isnumeric(varargin{2})    % arg list is (ndet,ebins,...
    ndet=varargin{1};
    energy=varargin{2}(:);  % column vector
    filename='';
    filepath='';
    if narg==2
        file_given=false;
        signal_given=false;
    elseif narg==3 && isnumeric(varargin{3})
        file_given=false;
        signal_given=true;
        S0=varargin{3};
    elseif narg==4 || narg==5
        if ischar(varargin{3}) && ischar(varargin{4})
            file_given=true;
            filename=varargin{3};
            filepath=varargin{4};
        else
            error('Check finepath and filename are character strings')
        end
        if narg==5
            signal_given=true;
            S0=varargin{5};
        else
            signal_given=false;
        end
    else
        error('Check input arguments')
    end
    
else
    error('Check number of input arguments')
end

% Check the number of elements in the mask array
if ~isempty(mask)
    if islognum(mask) && numel(mask)==ndet  % valid logical mask
        if ~islogical(mask)
            mask=logical(mask);
        end
    elseif isnumeric(mask)
        if all(mod(mask(:),1)==0) && min(mask(:))>=1 && max(mask(:))<=ndet && numel(unique(mask))==numel(mask)
            ind=mask;
            mask=false(ndet,1);
            mask(ind)=true;
        else
            error(['Masked detector index number(s) must be unique and lie in the range 1 - ',num2str(ndet)])
        end
    else
        error('Check length and data type of mask array')
    end
end

% Make S and ERR matrix of ones, so that when combined in an sqw file we
% should be able to work out how good the errorbars on our measurement will be.
if signal_given
    S=S0.*(ones(numel(energy)-1,ndet));
    ERR=ones(size(S));
else
    S=randn(numel(energy)-1,ndet);
    ERR=rand(size(S));
end

% Mask signal and error as required
if ~isempty(mask)
    S(:,mask)=NaN;
    ERR(:,mask)=NaN;
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
    w=spe(data);
    save(w,newloc);
end
