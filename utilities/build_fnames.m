function [f_names,psi]=build_fnames(indir,run_nums,psi0,psi_step,psi_end,fnames1,psi1)
% convenience function:
% Create the list of file names and corresponing orientation angles,
% from records expressed in human readable form
%
% input parameters:
% indir   % the folder where the datafiles are located; check if the final
%           name realy exists are performed
% run_nums % array of the numbers, which correspond to runs of intererst
%            and used to generate full datafile names for. 
%  THE USER HAVE TO EDIT FILE NAME STRUCTURE BELOW, to generate
%            real file names, e.g. if the names are MAP1023.spe, string 
%            'MAP' and '.spe' near the sighn ***> have to be modified manually
% psi0,     |
% psi_step  |-> initial rotation angle, step of the angle change and final
%           | rotation angle for the list of the files to process. 
% psi_end   | Number of psi values resulting from the sequence generated
%             from psi0,psi_step, psi_end, have to be equal to the number o
%            of run_nums supplied.
%
% optional parameters:
% fnames1,   the list of the filenames and
% psi1       correspondend psi angles calulated on previous step. new names
%            and angles will be added to the previous sequance. 
%
% USAGE EXAMPLE:
% G1
%[spe_file,psi]=build_fnames(indir,15835:15880,0,2,90);
% G2
%[spe_file,psi]=build_fnames(indir,15881:15925,1,2,89,spe_file,psi);
%
%
%
% $Revision: 1743 $ ($Date: 2010-07-20 16:45:52 +0100 (Tue, 20 Jul 2010) $)
%
%

nElements=numel(run_nums);
if(round(nElements/2)*2==nElements)
  nfgroup=round(psi_end-psi0)/psi_step;
else
  nfgroup=round(psi_end-psi0)/psi_step+1;
end
if nElements~=nfgroup
    error('build_fnames:wrong_par','number of psi angles and the number of runs which correspond to these runs has to be equal')
end

f_names=cell(1,nfgroup);
psi    = zeros(1,nfgroup);
for i=1:nfgroup
%***> MODIFY THE STRING BELOW TO MATCH FILE NAME REQUESTED
    f_names{i}=fullfile(indir,['MAP',num2str(run_nums(i)),'_4to1.spe_h5']);
    if ~exist(f_names{i},'file')
        error('build_fnames:wrong_par','file %s does not exist',f_names{i});
    end
    psi(i)=psi0+psi_step*(i-1);
end
%
if nargin>5
   f_names=[fnames1,f_names];
   psi    =[psi1,psi];
end
