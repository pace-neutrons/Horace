function relpath=relative_path(rootpath,fullpath)
% Get relative path of fullpath with respect to rootpath. Works on PC or Unix
%
%   >> relpath=relative_path(rootpath,fullpath)
%
% Robust algorithm.

% Use fullfile to convert pathsep consistently 
rootpath_corr=fullfile(rootpath);
if ~strcmp(rootpath_corr(end:end),filesep), rootpath_corr=[rootpath_corr,filesep]; end

fullpath_corr=fullfile(fullpath);
if ~strcmp(fullpath_corr(end:end),filesep), fullpath_corr=[fullpath_corr,filesep]; end

if (ispc && ~strncmpi(fullpath_corr,rootpath_corr,numel(rootpath_corr))) ||...
        (~ispc && ~strncmp(fullpath_corr,rootpath_corr,numel(rootpath_corr)))
    error('rootpath inconsistent with fullpath')
else
    if numel(rootpath_corr)<numel(fullpath_corr)
        relpath=fullpath_corr(numel(rootpath_corr)+1:end-1);
    else
        relpath='';
    end
end
