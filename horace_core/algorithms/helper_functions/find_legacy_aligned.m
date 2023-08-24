function lal_list = find_legacy_aligned(dir_name)
%FILD_LEGACY_ALIGNED   the utility accepts a folder and scan all sqw files
%in this folder. Returns list of sqw files which are legacy aligned
% Input:
% dir_name -- the folder containing sqw files. Looks in all subfolders of
%             the given folder
% Returns:
% lal_list -- cellarray of names of sqw files which are legacy aligned.
%             Empty if folder does not contain legacy aligned sqw files
fprintf('folder %s\n',dir_name);
lal_list = {};
if ~isfolder(dir_name)
    return
end
info = dir(dir_name);

is_legacy_al = arrayfun(@is_lal,info);
if any(is_legacy_al)
    lal_descr = info(is_legacy_al);
    lal_list = arrayfun(@(x)fullfile(x.folder,x.name),lal_descr, ...
        'UniformOutput',false);
    lal_list = lal_list(:);
end
is_dir       = arrayfun(@(x)(x.isdir&&x.name(1)~='.'),info);
if ~any(is_dir)
    return;
end
sub_dir = info(is_dir);
for i=1:numel(sub_dir)
    lal_pl = find_legacy_aligned(fullfile(sub_dir(i).folder,sub_dir(i).name));
    if ~isempty(lal_pl)
        lal_list = [lal_list(:);lal_pl(:)];
    end
end


function is = is_lal(fs)
% check if the file described by the structure, returned by Matlab dir
% funcion is legacy aligned
if  fs.isdir
    is = false;
    return
end
[~,~,fe] = fileparts(fs.name);
if ~strcmpi(fe,'.sqw')
    is = false;
    return
end
file = fullfile(fs.folder,fs.name);
is = is_legacy_aligned(file);