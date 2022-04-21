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
    head_ind = contrib_runids(i);
    wout(i).main_header=main_header;
    if run_contributes(head_ind)
        ib=ibin(nbeg(ind(head_ind)):nend(ind(head_ind))); % the bins to which pixels from this run only contribute
        nb=find(diff([0;ib])~=0);   % positions of first pixel contributing to each unique bin
        npix=zeros(sz);
        npix(ib(nb))=diff([nb;numel(ib)+1]);
        data.npix=npix;
        data.pix=pix.get_pixels(ix(nbeg(ind(head_ind)):nend(ind(head_ind))));
        %
        [exp_info_4run,runid_4run] = exp_info.get_subobj(head_ind,runid_map);
        wout(i).experiment_info = exp_info_4run;
        wout(i).runid_map       = runid_4run;
        
        wout(i).detpar= detpar;
        wout(i).data=data;
        wout(i)=recompute_bin_data(wout(i));
    end
end
