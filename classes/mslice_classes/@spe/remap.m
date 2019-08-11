function spe_out=remap(spe_data,map,opt)
% Remap an spe object according to a map object
%
%   >> spe_out=remap(spe,map)           % average the signal (default)
%   >> spe_out=remap(spe,map,'sum')     % sum the signal
%
% Input:
% ------
%   spe         spe data object
%   map         map object (as created or read from file by using IX_map)
%
% Optional keyword:
%  'sum'        By default, the signal is averaged i.e. the sum of the
%              contributing spectra to a workspace is divided by the number
%              of contributing spectra. If 'sum' is specified, then the
%              data is simply added together.
%
% Output:
% -------
%   spe_out     spe object with spectra added together as described by the
%              map object


% Original author: T.G.Perring 23 Sep 2013

% Sum or average?
% ---------------
if nargin==3
    if is_string(opt) && ~isempty(opt)...
            && strncmpi(opt,'sum',numel(opt))
        normalise=false;
    else
        error('Check keyword option is valid')
    end
else
    normalise=true;
end

% Check input OK
% ---------------
ne=size(spe_data.S,1);
ndet=size(spe_data.S,2);
nw=numel(map.ns);
if ndet<max(map.s)
    error('Number of detectors in spe data incompatible with maximum spectrum number in map')
end

% Initialise output signal and error arrays
% -----------------------------------------
S_out=zeros(ne,nw);
ERR_out=zeros(ne,nw);

% Accumulate data in output arrays
% --------------------------------
S=spe_data.S;
ERRsqr=(spe_data.ERR).^2;
s=map.s;
nend=cumsum(map.ns);
nbeg=nend-map.ns+1;
w=zeros(1,numel(map.s));
for i=1:nw
    w(nbeg(i):nend(i))=i;
end
for i=1:numel(map.s)
    S_out(:,w(i))=S_out(:,w(i))+S(:,s(i));
    ERR_out(:,w(i))=ERR_out(:,w(i))+ERRsqr(:,s(i));
end
ERR_out=sqrt(ERR_out);

% Normalise by spectrum count if required
if normalise
    normval=repmat(map.ns,ne,1);
    S_out=S_out./normval;
    ERR_out=ERR_out./normval;
end

% Set empty workspaces to default values
empty=(map.ns==0);
if any(empty)
    S_out(:,empty)=NaN;
    ERR_out(:,empty)=0;
end

% Create output spe object
% ------------------------
data.filename='';
data.filepath='';
data.S=S_out;
data.ERR=ERR_out;
data.en=spe_data.en;

spe_out=spe(data);
