function title_main = main_title_(obj,title_main_pax,title_main_iax)
%MAIN_TITLE method generates cellarray containing text to plot above
% standard 1-3D image of sqw/dnd object containing line_axes.
%
% Inputs:
% obj            -- initialized instance of the line_axes object.
%
% title_main_pax -- cellarray of titles to plot along projection axes.
%                   Number of elements must be equal to total number of
%                   projection axes in the object.
% title_main_iax -- cellarray of titles to plot along integration axes.
%                   Number of elements must be equal to total number of
%                   integration axes in the object.
%
% Returns:
% title_main     -- cellarray, containing text to plot above
%                   1-3D image of the of the object containing line_axes.
%                   number of cells in this array corresponds to number of
%                   test rows to be plotted on the image
%
file  = fullfile(obj.filepath,obj.filename);
title = obj.title;

iline = 1;
if ~isempty(file)
    title_main{iline}=avoidtex(file);
else
    title_main{iline}='';
end
iline = iline + 1;

if ~isempty(title)
    title_main{iline}=title;
    iline = iline + 1;
end
%
% If defined, add information about projection, which transforms pixel data
% into image  with these axes.
if ~isempty(obj.proj_description_function_)
    title_main{iline}=obj.proj_description_function_(obj);
    iline = iline + 1;
end

if ~isempty(obj.iax)
    if numel(title_main_iax) ~= numel(obj.iax)
        error('HORACE:AxesBlockBase:invalid_argument', ...
            'number of integration axes (%d) is not equal to the number of integration axes titles (%d)', ...
            numel(obj.iax),numel(title_main_iax));
    end
    title_main{iline}=title_main_iax{1};
    if length(title_main_iax)>1
        for i=2:length(title_main_iax)
            title_main{iline}=sprintf('%s , %s',title_main{iline},title_main_iax{i});
        end
    end
    iline = iline + 1;
end
if ~isempty(obj.pax)
    if numel(title_main_pax) ~= numel(obj.pax)
        error('HORACE:line_axes:invalid_argument', ...
            'number of projection axes (%d) is not equal to the number of projection axes titles (%d)', ...
            numel(obj.iax),numel(title_main_iax));
    end

    title_main{iline}=title_main_pax{1};
    if length(title_main_pax)>1
        for i=2:length(title_main_pax)
            title_main{iline}=sprintf('%s , %s',title_main{iline},title_main_pax{i});
        end
    end
end
