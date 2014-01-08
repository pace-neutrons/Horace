function [ndet,en]=get_spe_info(this)
% get run info from spe file
filename=this.file_name;
if isempty(filename)
    error('LOADER_ASCII:problems_with_file',' get_par_info needs ascii spe file to be defined');
end
% get info about ascii spe file;
[ne,ndet,en]= get_spe_matlab(filename,'-info_only');
if numel(en) ~= ne+1
    error('LOADER_ASCII:problems_with_file',' ill formatted ascii spe file %s; numel(en)~=ne+1',filename);
end
