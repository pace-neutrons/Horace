function  spe_filelist = source_nxspe_files_generator(n_files,data_dir,working_dir,template_name)
% Generate test of source files to use in further tests
%
%Input: number of files to generate
%Output: list of filenames to use in test
%
% This is simplified version which involes copying the source file.
% more advanced version would generate appropriate
%


%psi angles (in degrees). Should be the same number of these as there are runs
%also the first element of irun must correspond to the first element of psi, and so on.

%Horace requires cell arrays telling it the names and locations of the spe files:
spe_filelist=cell(1,n_files);
%
source_file = fullfile(data_dir,template_name);

[~,tpfn] = fileparts(template_name);

%
for i=1:n_files
    fname =sprintf('%s_%03d.nxspe',tpfn,i);
    spe_filelist{i} = fullfile(working_dir,fname);
    if ~(exist(spe_filelist{i},'file')==2)
        copyfile(source_file,spe_filelist{i},'f');
    end
end
