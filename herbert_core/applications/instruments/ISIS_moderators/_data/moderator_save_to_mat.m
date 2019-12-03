function moderator_save_to_mat (file_in, file_out)
% Read a McStas moderator file and write as a .mat file
%
%   >> moderator_save_to_mat (file_in)
%
%   >> moderator_save_to_mat (file_in, file_out)
%
% Input:
% ------
%   file_in     Input McStas file e.g.
%                   TS1verBase2016_LH8020_newVM-var_South01_Maps.mcstas
%
%   file_out    Output file. By default will be written to the Matlab
%               temporary folder as returned by function tmp_dir, with
%               same name as file_in, and extension .mat.
%               Contains three fields:
%                   t           Time bin boundaries (microseconds)
%                   en          Energy bin boundaries (meV)
%                   intensity   Intensity per microsecond per meV
%
%               The time and energy bin boundaries are logarithmically spaced

[t,en,intensity] = moderator_read (file_in);

if nargin==1
    [~,nam,~] = fileparts(file_in);
    file_out = fullfile(tmp_dir,[nam,'.mat']);
end

save(file_out,'t','en','intensity');
