function wout=split(w)
% Split an sqw object into an array of sqw objects, each made from a single spe data set
%
%   >> wout=split(w)
%
% Input:
% ------
%   w       Input sqw object
%
% Output:
% -------
%   wout    Array of sqw objects, each one made from a single spe data file


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

nfiles=w.main_header.nfiles;

% Catch case of single contributing spe dataset
if nfiles==1
    wout=w;
    return
end

% Default output
wout=repmat(sqw,[nfiles,1]);

% Get pointers to components of w:
main_header=w.main_header;
header=w.header;
detpar=w.detpar;
data=w.data;
npix=w.data.npix;
pix=w.data.pix;

% Sort (an index array to) pix into increasing run number, and increasing bin number within each run
irun=pix(5,:)';
ibin=replicate_array (1:numel(npix),npix);
[runbin,ix]=sortrows([irun,ibin]);  % get index of run
irun=runbin(:,1);
ibin=runbin(:,2);

% Get first and last elements for each run
nbeg=find(diff([0;irun])~=0);       % positions of first elements for each unique run
if ~isempty(nbeg)
    nend=[nbeg(2:end)-1;size(pix,2)];   % works even if nbeg is scalar (nb/ npixtot=size(pix,2))
else
    nend=[];
end
run_contributes=false(nfiles,1);
run_contributes(irun(nbeg))=true;   % true for runs that contribute to the data
ind=zeros(nfiles,1);
ind(run_contributes)=1:numel(nbeg); % index of contributing runs into nbeg and nend

% Put only the relevant pixels in each of the sqw objects
main_header.nfiles=1;   % each output sqw object will have just one run
sz=size(data.npix);     % size of signal error and npix arrays
if sum(run_contributes)~=nfiles     % there is at least one run that does not contribute to the pixels
    datanull=data;
    datanull.s=zeros(sz);
    datanull.e=zeros(sz);
    datanull.npix=zeros(sz);
    datanull.urange=[Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf];
    datanull.pix=zeros(9,0);
end
for i=1:nfiles
    wout(i).main_header=main_header;
    wout(i).header=header{i};
    wout(i).detpar=detpar;
    if run_contributes(i)
        ib=ibin(nbeg(ind(i)):nend(ind(i))); % the bins to which pixels from this run only contribute
        nb=find(diff([0;ib])~=0);   % positions of first pixel contributing to each unique bin
        npix=zeros(sz);
        npix(ib(nb))=diff([nb;numel(ib)+1]);
        data.npix=npix;
        data.pix=pix(:,ix(nbeg(ind(i)):nend(ind(i))));
        data.pix(5,:)=1;    % all pixels will be from run 1, by definition
        wout(i).data=data;
        wout(i)=recompute_bin_data(wout(i));
    else
        wout(i).data=datanull;
    end
end
