function obj=change_crystal(obj,alatt,angdeg,rlu_corr)
%  Change fields in the experiment with correction related to change crystal
%  lattice parameters and orientation
%
%   >> obj=change_crystal(obj,alatt,angdeg,rlu_corr)
% Change fields of Experiment as required

sam = obj.samples;
exper = obj.expdata;
for i=1:obj.n_runs
    sam{i}.alatt=alatt;
    sam{i}.angdeg=angdeg;
    exper(i).cu=(rlu_corr*exper(i).cu')';
    exper(i).cv=(rlu_corr*exper(i).cv')';
    exper(i).uoffset(1:3)=rlu_corr*exper(i).uoffset(1:3);
    exper(i).u_to_rlu(1:3,1:3)=rlu_corr*exper(i).u_to_rlu(1:3,1:3);
end
obj.samples = sam;
obj.expdata = exper;
