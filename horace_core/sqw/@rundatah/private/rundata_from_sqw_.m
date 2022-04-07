function rd=rundata_from_sqw_(sqw_obj)
% function builds rundata object from sqw object
%
%>>rd = rundata_from_sqw_(sqw)
%
%Input:   sqw_obj -- a non-empty sqw object (for single input file)
%Output:  rd  -- rundata object with the data from sqw object
%
%
%


%
data = sqw_obj.data;
exp_inf = sqw_obj.experiment_info;
detpar = sqw_obj.my_detpar();
%
if (iscell(exp_inf) && numel(exp_inf) > 1) || (isa(exp_inf,'Experiment') && numel(exp_inf.expdata)>1)
    error('HORACE:rundata_from_sqw:invalid_argument',...
        ['a rundatah class can be constructed from an sqw, build from single data file only.'...
        ' Use sqw.split to divide sqw into array of single dataset sqw objects']);
end
en     = exp_inf.expdata(1).en;
ne=numel(en)-1;    % number of energy bins
ndet0=numel(detpar.group);% number of detectors

tmp=data.pix.get_data({'detector_idx', 'energy_idx', 'signal', 'variance'})';
tmp=sortrows(tmp,[1,2]);  % order by detector group number, then energy
group=unique(tmp(:,1));   % unique detector group numbers in the data in numerical increasing order

% Now check that the data is complete i.e. no missing pixels
if size(tmp,1)~=ne*numel(group)
    error('HORACE:rundata_from_sqw:runtime_error',...    
    'Data for one or more energy bins is missing in the sqw data')
end

% Get the indexing of detector group in the detector information
[~,ind]=ismember(group,detpar.group);

signal=NaN(ne,ndet0);
err=zeros(ne,ndet0);
signal(:,ind)=reshape(tmp(:,3),ne,numel(group));
err(:,ind)=sqrt(reshape(tmp(:,4),ne,numel(group)));


lattice = oriented_lattice();
lattice.alatt = exp_inf.samples{1}.alatt;
lattice.angdeg = exp_inf.samples{1}.angdeg;
lattice.u      = exp_inf.expdata(1).cu;
lattice.v      = exp_inf.expdata(1).cv;
lattice.psi    = exp_inf.expdata(1).psi*(180/pi);
lattice.omega = exp_inf.expdata(1).omega*(180/pi);
lattice.dpsi  = exp_inf.expdata(1).dpsi*(180/pi);
lattice.gl    = exp_inf.expdata(1).gl*(180/pi);
lattice.gs    = exp_inf.expdata(1).gs*(180/pi);

rd = rundatah();
rd.run_id = unique(data.pix.run_idx);
rd.lattice = lattice;
% Set lattice before loader, to have efix redefined on rundata rather then
% in the loader
rd.efix = exp_inf.expdata(1).efix;
% will define loader
rd.det_par = detpar;

rd.emode   = exp_inf.expdata(1).emode;

rd.en  = en;
rd.S   = signal;
rd.ERR = err;

rd.sample = exp_inf.samples{1};
rd.instrument = exp_inf.instruments{1};




