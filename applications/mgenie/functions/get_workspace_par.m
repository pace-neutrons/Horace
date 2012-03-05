function [delta, twotheta, azimuth, x2, posn] = get_workspace_par (detpar, varargin)
% Get secondary spectrometer information for a list of workspaces for the currently assigned data source
%
%   >> [delta, twotheta, azimuth, x2, posn] = get_workspace_par (detpar, map)
%   >> [delta, twotheta, azimuth, x2, posn] = get_workspace_par (detpar, speclist, ns)
%
%   >> [delta, twotheta, azimuth, x2, posn] = get_workspace_par (...,av_mode)
%
% Input
% -----
%   detpar      Structure containing detector information (as read by get_detector_par)
%
%   map         Cell array of row vectors of spectra, one vector per workspace. Workspaces can be empty.
% *OR*
%   speclist    List of spectrum numbers in the workspaces
%                first workspace:  speclist(1:ns(1))
%                second workspace: speclist(ns(1)+1:ns(2))
%                       :
%               If not present, or empty, assumes 1:1 mapping os spectra to workspaces.
%
%                - Can have repeated entries i.e. a spectrum can appear in more than one workspace,
%                 and more than once in a single workspace.
%                - Spectra can appear in any valid period number e.g. if no spectra=10000, then
%                 spectrum 15000 is valid so long as the run has at least two periods.
%                - Any empty workspace will be given NaN information in the output.
%                - Any workspace containing spectrum zero will be given NaN information in the output.
%               
%   ns          List of numbers of spectra in each workspace.
%                - if not present, or empty, assumes 1:1 mapping of workspaces to spectra
%
%  Keyword:
%   av_mode     Averaging scheme (default is 'average')
%               = 'average'         take the average for all detectors in a workspace
%               = 'min_twotheta'    take parameters from the detector element with minimum twotheta
%               = 'max_twotheta'    take parameters from the detector element with maximum twotheta
%               = 'none'            no parameters calculated (only possible with output units are time-of-flight
%
% Output: (row vectors unless stated)
% -------
%   delta       Delay time (us)
%   twotheta    Scattering angle (deg)
%   azimuth     Azimuthal angle (deg)
%   x2          Sample-workspace distance (m)
%   posn        3 x n array of x-y-z location of workspace (z along ki, y vertically up)
%   

nsp = double(genie_get('nsp1'));
nper= double(genie_get('nper'));
nsptot = nper*(nsp+1) - 1;    % maximum spectrum number in a multi-period run


% Parse arguments
% ----------------------
% Determine if last parameter is the keyword
if numel(varargin)>=1
    if ischar(varargin{end})
        av_mode=varargin{end};
        args=varargin(1:end-1);
    else
        av_mode='average';
        args=varargin;
    end
else
    av_mode='average';
    args={};
end

% Parse other input arguments:
if numel(args)==1 && iscell(args{1})    % must be cell array, so assume map description
    speclist=cell2mat(args{1});
    if min(speclist)<0 || max(speclist)>nsptot    % Check the spectra are contained in the spectrum list
        error(['Spectrum numbers out of range 0-',num2str(nsptot)])
    end
    ns=zeros(1,numel(args{1}));
    for i=1:numel(args{1})
        ns(i)=numel(args{1}{i});
    end

else
    if numel(args)>=1
        speclist=args{1};
        if isempty(speclist)
            speclist=1:nsp;     % use all spectra in first period by default
        elseif min(speclist)<0 || max(speclist)>nsptot    % Check the spectra are contained in the spectrum list
            error(['Spectrum numbers out of range 0-',num2str(nsptot)])
        end
    else
        speclist=1:nsp;
    end

    if numel(args)>=2
        ns=args{2};
        if isempty(ns)
            ns=ones(1,numel(speclist)); % one to one mapping
        else
            nstot=sum(ns);
            if numel(speclist)~=nstot
                error('Mapping of spectra to workspaces inconsistent')
            end
        end
    else
        ns=ones(1,numel(speclist)); % one to one mapping
    end

    if numel(args)>=3
        error('Check number of input arguments')
    end

end


% Get list of workspaces to which spectrum zero does not contribute from one of the periods 
% ------------------------------------------------------------------------------------------
% If workspaces span multiple periods. Detector tables only have information for spectra in first period.
speclist_mod=mod(speclist(:)',nsp);                 % get row vector of spectrum numbers modulo first period

% Get list of workspaces for each spectrum:
nw=numel(ns);
iw=ones(1,numel(speclist_mod));
nscum=[0,cumsum(ns)];
for i=1:nw
    iw(nscum(i)+1:nscum(i+1))=i;
end

% Find list of workspaces to keep and corresponding spectrum numbers
iwremove=unique(iw(speclist_mod==0));
ok=true(size(speclist_mod));
for i=iwremove
    ok(nscum(i)+1:nscum(i+1))=false;
end

iw=iw(ok);      % list of workspace indicies into the list of spectra to keep (increasing workspace number)
speclist_mod=speclist_mod(ok);  % list of non-zero spectrum numbers that contribute to workspaces


% Get list of indicies into detector tables of all detectors that contribute to workspaces, in order of incr. wkspace index
% --------------------------------------------------------------------------------------------------------------------------
[uspeclist,m,n]=unique(speclist_mod); % row vector of unique spectrum numbers

% Get indicies into detector structure and of the spectrum numbers to which the detectors contribute
%   id :indicies into detector parameter list of detectors that contribute to the spectra
%   is :corresponding indicies, one per detector, into uspeclist; 'is' is in numerically increasing order

spec=gget('spec');
[id_tmp,is]=array_filter(spec,uspeclist);    % detector indicies required, and index into uspeclist of corresponding spectrum (assumes uspeclist is unique for this to work)
udet=gget('udet');
[dummy,id]=array_filter(udet(id_tmp),detpar.det_no); % indicies into detector parameter arrays
if numel(id)~=numel(id_tmp)
    error('Not all detectors appear in detector parameter tables')
end

[is,ix]=sort(is);   % sort the indicies into uspeclist
id=id(ix);          % corresponding re-ordering of indicies into detector parameters
ndet=diff(find(diff([-Inf,is(:)',Inf])>0)); % number of detectors in the spectra, in order of uspeclist


% Expand list of detectors for unique spectra into corresponding arrays for speclist_mod
% --------------------------------------------------------------------------------------
% Obtain list of indicies into detector parameters and correspoinding workspace indicies in increasing order
[id,ndet]=expand_block_array(id,ndet,n);    % detector indicies and no. dets for speclist_mod (row vector)
iw=replicate_array(iw,ndet);                % corresponding workspace indicies (column vector)



iav_mode=find(strncmpi(av_mode,{'average','min_twotheta','max_twotheta','none'},numel(av_mode)));
if numel(iav_mode)~=1
    error('Unrecognised averaging mode for computing workspace parameters')
end

if iav_mode==1  % average
    % Get x-y-z position of detectors
    xspec=detpar.x2(id).*sind(detpar.twotheta(id)).*cosd(detpar.azimuth(id));
    yspec=detpar.x2(id).*sind(detpar.twotheta(id)).*sind(detpar.azimuth(id));
    zspec=detpar.x2(id).*cosd(detpar.twotheta(id));
    % Get averages for the workspaces
    ndet    = accumarray(iw,ones([1,numel(iw)]),[nw,1])';
    ndet(ndet==0)=NaN;  % ensures that get NaN for empty workspaces or those containing spectrum 0
    delta   = accumarray(iw,detpar.delta(id),[nw,1])'./ndet;
    xspec   = accumarray(iw,xspec,[nw,1])'./ndet;
    yspec   = accumarray(iw,yspec,[nw,1])'./ndet;
    zspec   = accumarray(iw,zspec,[nw,1])'./ndet;
    x2      = sqrt(xspec.^2+yspec.^2+zspec.^2);
    twotheta= (180/pi)*atan2(sqrt(xspec.^2+yspec.^2),zspec);
    azimuth = (180/pi)*atan2(yspec,xspec);
    posn    = [xspec;yspec;zspec];
    
elseif iav_mode==2 || iav_mode==3   % minimum or maximum twotheta
    ixlo=find(diff([-Inf;iw])>0);   % index to start of block for each workspace (non-empty or not containing spectrum 0)
    ixhi=find(diff([iw;Inf])>0);    % index to end of block
    iwu=iw(ixlo);                   % corresponding workspace index number

    ind=zeros(numel(iwu),1);        % will contain indicies of chosen detectors
    if iav_mode==2
        for i=1:numel(iwu)
            idsel=id(ixlo(i):ixhi(i));  % detector indicies for workspace iwu(i)
            [dummy,j]=min(detpar.twotheta(idsel));
            ind(i)=idsel(j);
        end
    elseif iav_mode==3
        for i=1:numel(iwu)
            idsel=id(ixlo(i):ixhi(i));  % detector indicies for workspace iwu(i)
            [dummy,j]=max(detpar.twotheta(idsel));
            ind(i)=idsel(j);
        end
    end
    delta   =NaN(1,nw);
    twotheta=NaN(1,nw);
    azimuth =NaN(1,nw);
    x2      =NaN(1,nw);
    posn    =NaN(3,nw);
    delta(iwu)   =detpar.delta(ind);
    twotheta(iwu)=detpar.twotheta(ind);
    azimuth(iwu) =detpar.azimuth(ind);
    x2(iwu)      =detpar.x2(ind);
    posn(:,iwu)    =[x2(iwu).*sind(twotheta(iwu)).*cosd(azimuth(iwu));...
                   x2(iwu).*sind(twotheta(iwu)).*sind(azimuth(iwu));...
                   x2(iwu).*cosd(twotheta(iwu))];
               
elseif iav_mode==4                  % no averaging
    delta   =NaN(1,nw);
    twotheta=NaN(1,nw);
    azimuth =NaN(1,nw);
    x2      =NaN(1,nw);
    posn    =NaN(3,nw);
end


%========================================================================================================
function vout = replicate_array (v, npix)
% Replicate array elements according to list of repeat indicies
%
%   >> vout = replicate_array (v, n)
%
%   v       Array of values
%   n       List of number of times to replicate each value
%
%   vout    Output array: column vector
%               vout=[v(1)*ones(1:n(1)), v(2)*ones(1:n(2), ...)]'

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

if numel(npix)==numel(v)
    % Get the bin index for each pixel
    nend=cumsum(npix(:));
    nbeg=nend-npix(:)+1;    % nbeg(i)=nend(i)+1 if npix(i)==0, but that's OK below
    nbin=numel(npix);
    npixtot=nend(end);
    vout=zeros(npixtot,1);
    for i=1:nbin
        vout(nbeg(i):nend(i))=v(i);     % if npix(i)=0, this assignment does nothing
    end
else
    error('Number of elements in input array(s) incompatible')
end


%========================================================================================================
function [Arr,Nel]=expand_block_array(arr,nel,n)
% Expand the blocks of an array according to an index array
%
%   >> [Nel,Arr]=expand_array(arr,nel,n)
%
%   arr     row vector, length sum(nel)
%   nel     number of elements in each block
%   n       index array by which to expand the blocks
%
%
% e.g. 
%   arr=[11,12,21,22,23,24,31,32,33,34,35];
%   nel=[2,4,5];
%   n=[2,1,2,3,1,3];
%
%   Nel=[4,2,4,5,2,5];
%   Arr=[21,22,23,24,11,12,21,22,23,24,31,32,33,34,35,11,12,31,32,33,34,35]

nelcum=[0,cumsum(nel)];
Nel=nel(n);
Neltot=sum(Nel);

Arr=zeros(1,Neltot);
noff=0;
for i=1:numel(n)
    Arr(noff+1:noff+nel(n(i)))=arr(nelcum(n(i))+1:nelcum(n(i)+1));
    noff=noff+nel(n(i));
end
