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

detpar = sqw_obj.detpar();
%
tmp=sqw_obj.pix.get_data({'detector_idx', 'energy_idx', 'signal', 'variance'})';
run_id = unique(sqw_obj.pix.run_idx);
if numel(run_id)>1
    warning('HORACE:rundata_from_sqw:invalid_argument',...
        'sqw object contains more then 1 contributing run. Extracting the first one')
    is_run_1 = (sqw_obj.pix.run_idx == run_id(1));
    tmp = tmp(:,is_run_1);
    run_id = run_id(1);
    exp_inf = sqw_obj.experiment_info.get_subobj(run_id,sqw_obj.runid_map);
else
    exp_inf = sqw_obj.experiment_info;
end
tmp=sortrows(tmp,[1,2]);  % order by detector group number, then energy
group=unique(tmp(:,1));   % unique detector group numbers in the data in numerical increasing order

en     = exp_inf.expdata(1).en;
ne=numel(en)-1;    % number of energy bins
ndet0=numel(detpar.group);% number of detectors


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


lattice = oriented_lattice('angular_units','rad');
s1 = exp_inf.samples{1};
lattice.alatt = s1.alatt;
lattice.angdeg = s1.angdeg;
% header keeps angular units in radians
lattice.u      = exp_inf.expdata(1).cu;
lattice.v      = exp_inf.expdata(1).cv;
lattice.psi    = exp_inf.expdata(1).psi;
lattice.omega = exp_inf.expdata(1).omega;
lattice.dpsi  = exp_inf.expdata(1).dpsi;
lattice.gl    = exp_inf.expdata(1).gl;
lattice.gs    = exp_inf.expdata(1).gs;
lattice.angular_units='deg';

rd = rundatah();
rd.run_id = run_id;

rd.lattice = lattice;
% Set lattice before loader, to have efix redefined on rundata rather then
% in the loader
rd.efix = exp_inf.expdata(1).efix;
% will define loader
rd.det_par = detpar;
rd.emode   = exp_inf.expdata(1).emode;
%rd.data_file_name = fullfile(exp_inf.expdata(1).filepath,exp_inf.expdata(1).filename);

rd.en  = en;
rd.S   = signal;
rd.ERR = err;

rd.sample = exp_inf.samples{1};
rd.instrument = exp_inf.instruments{1};




