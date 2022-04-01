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

nfiles=w.main_header.nfiles;

% Catch case of single contributing spe dataset
if nfiles==1
    wout=w;
    return
end

% Get pointers to components of w:
main_header=w.main_header;
exp_info =w.experiment_info;
runid_map = w.runid_map;
detpar=w.detpar;
data=w.data;
npix=w.data.npix;
pix=w.data.pix;

% Sort (an index array to) pix into increasing run number, and increasing bin number within each run
irun=pix.run_idx';
ibin=replicate_array (1:numel(npix),npix);
[runbin,ix]=sortrows([irun,ibin]);  % get index of run
irun=runbin(:,1);
ibin=runbin(:,2);

% Get first and last elements for each run
nbeg=find(diff([0;irun])~=0);       % positions of first elements for each unique run
if ~isempty(nbeg)
    nend=[nbeg(2:end)-1;pix.num_pixels];   % works even if nbeg is scalar (nb/ npixtot=size(pix,2))
else
    nend=[];
end
run_contributes=false(nfiles,1);
run_contributes(irun(nbeg))=true;   % true for runs that contribute to the data
ind=zeros(nfiles,1);
ind(run_contributes)=1:numel(nbeg); % index of contributing runs into nbeg and nend

contrib_runids = unique(irun);
n_contrib_run = numel(contrib_runids);
% Default output
wout=repmat(sqw, [n_contrib_run, 1]);

% Put only the relevant pixels in each of the sqw objects
main_header.nfiles=1;   % each output sqw object will have just one run
sz=size(data.npix);     % size of signal error and npix arrays
for i=1:n_contrib_run
    n_header = runid_map(contrib_runids(i));
    wout(i).main_header=main_header;
    wout(i).experiment_info.expdata =exp_info.expdata(n_header);
    wout(i).experiment_info.instruments{1} = exp_info.instruments{n_header};
    wout(i).experiment_info.samples{1} = exp_info.samples{n_header};    
    wout(i).detpar= detpar;
    if run_contributes(n_header)
        ib=ibin(nbeg(ind(n_header)):nend(ind(n_header))); % the bins to which pixels from this run only contribute
        nb=find(diff([0;ib])~=0);   % positions of first pixel contributing to each unique bin
        npix=zeros(sz);
        npix(ib(nb))=diff([nb;numel(ib)+1]);
        data.npix=npix;
        data.pix=pix.get_pixels(ix(nbeg(ind(n_header)):nend(ind(n_header))));
        data.pix.run_idx=contrib_runids(i);
        wout(i).data=data;
        wout(i)=recompute_bin_data(wout(i));
        wout(i).runid_map = containers.Map(contrib_runids(i),1);
    end
end
