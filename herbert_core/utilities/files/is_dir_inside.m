function [is,common_root] = is_dir_inside(inside_dir,outer_dir)
% check if input path in_dir lies inside other directory
%Inputs:
% inside_dir -- the folder, which should be verified
% outer_dir  -- the folder, to check if inside_dir path lies inside this
%               dir path
% Returns:
% is           -- true if inside_dir points within outer_dir
% common_root  -- the path which is common for both directories.
%                 It is empty

in_array = split_to_cellarray(inside_dir);
out_array = split_to_cellarray(outer_dir);

eq = ismember(in_array,out_array);


if numel(in_array)<numel(out_array)
    is = false;
else
    fci = find(eq,1,'last');
    if fci<numel(out_array)
        is = false;
    else
        is = true;
    end
end
if eq(1) == 1
    last = find(eq==0,1);
    last = last -1;
    if isempty(last)
        common_cell = in_array;
    elseif last<1
        common_cell={};
    else
        common_cell = in_array(1:last);
    end
else
    common_cell = {};
end
if isempty(common_cell)
    common_root = '';
else
    common_root = fullfile(common_cell{:});
end


function [cal,path] = split_to_cellarray(path,cal)

[path,fn] = fileparts(path);
if isempty(fn)
    if exist('cal','var')
        cal = [path;cal(:)];
        path = '';
        return;
    end
end
if ~exist('cal','var')
    if isempty(fn)
        [cal,path] = split_to_cellarray(path);
    else
        cal = {fn};
    end
else
    cal = [fn;cal(:)];
end
if ~isempty(path)
    [cal,path] = split_to_cellarray(path,cal);
end