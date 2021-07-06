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
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)
%

%
data = sqw_obj.data;
header = sqw_obj.my_header();
detpar = sqw_obj.my_detpar();
%
if iscell(header) && numel(header) > 1
    error('RUNDATAH:invalid_argument',...
        ['a rundatah class can be constructed from an sqw, build from single data file only.'...
        ' Use sqw.split to divide sqw into array of single dataset sqw objects']);
end
en     = header.en;
ne=numel(en)-1;    % number of energy bins
ndet0=numel(detpar.group);% number of detectors

tmp=data.pix.get_data({'detector_idx', 'energy_idx', 'signal', 'variance'})';
tmp=sortrows(tmp,[1,2]);  % order by detector group number, then energy
group=unique(tmp(:,1));   % unique detector group numbers in the data in numerical increasing order

% Now check that the data is complete i.e. no missing pixels
if size(tmp,1)~=ne*numel(group)
    error('Data for one or more energy bins is missing in the sqw data')
end

% Get the indexing of detector group in the detector information
[~,ind]=ismember(group,detpar.group);

signal=NaN(ne,ndet0);
err=zeros(ne,ndet0);
signal(:,ind)=reshape(tmp(:,3),ne,numel(group));
err(:,ind)=sqrt(reshape(tmp(:,4),ne,numel(group)));


lattice = oriented_lattice();
lattice.alatt = header.alatt;
lattice.angdeg = header.angdeg;
lattice.u      = header.cu;
lattice.v      = header.cv;
lattice.psi    = header.psi*(180/pi);
lattice.omega = header.omega*(180/pi);
lattice.dpsi  = header.dpsi*(180/pi);
lattice.gl    = header.gl*(180/pi);
lattice.gs    = header.gs*(180/pi);

rd = rundatah();

rd.lattice = lattice;
% Set lattice before loader, to have efix redefined on rundata rather then
% in the loader
rd.efix = header.efix;
% will define loader
rd.det_par = detpar;

rd.emode   = header.emode;

rd.en  = en;
rd.S   = signal;
rd.ERR = err;




