function [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = data_plot_titles_(obj)
% Get titling and caption information for the axes sqw data structure
%
% Syntax:
%   >> [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = data_plot_titles (obj,proj)
%
% Input:
% ------
%   obj         Initialized instance of spherical axes object
%   proj        spherical projection instance, describing spherical
%               transformation parameters.
%
% Output:
% -------
%   title_main      Main title (cell array of character strings)
%   title_pax       Cell array containing axes annotations for each of the plot axes
%   title_iax       Cell array containing annotations for each of the integration axes
%   display_pax     Cell array containing axes annotations for each of the plot axes suitable
%                  for printing to the screen
%   display_iax     Cell array containing axes annotations for each of the integration axes suitable
%                  for printing to the screen
%   energy_axis     The index of the column in the 4x4 matrix din.u that corresponds
%                  to the energy axis


energy_axis = 4;
small = 1.0e-10;    % tolerance for rounding numbers to zero or unity in titling


% Prepare input arguments
file  = obj.full_filename;
title = obj.title;
%
img_scales  = obj.img_scales;
label       = obj.label;


pax   = obj.pax;
br    = obj.get_cut_range();
dax   = obj.dax;
n_dim = numel(pax);
%
plot_bin_centers = reshape([br{dax}],3,n_dim);


% Axes and integration titles
% Character representations of input data
%==========================================================================
offset   = obj.offset;
uofftot  = offset;

iax  = obj.iax;
iint = obj.iint;
for i=1:length(iax)
    % get offset from integration axis, accounting for non-finite limit(s)
    uofftot(iax(i))  = uofftot(iax(i))+0.5*(iint(1,i)+iint(2,i));  % overall displacement of plot volume in
end
%

% add energy type to the types the projection defines. TODO:  Should energy type be part of
% type?
type = obj.axes_units;

% pre-allocate cell arrays for titling:
title_pax = cell(length(pax),1);
display_pax = cell(length(pax),1);
title_iax = cell(length(iax),1);
display_iax = cell(length(iax),1);
title_main_pax = cell(length(pax),1);
title_main_iax = cell(length(iax),1);


in_totvector=cell(1,4);

% Create titling
for j=1:4
    ax_type = type(j);
    angular_unit = (j == 3);
    scale_present =  (abs(img_scales(j)-1) > small);
    if scale_present && ~angular_unit
        in_totvector{j} = sprintf('in %.3g %s',img_scales(j),obj.capt_units(ax_type));            
    else
        in_totvector{j} =  ['in ',obj.capt_units(ax_type)];        
    end
    if ismember(j,pax) % pax
        ipax = find(j==pax(dax));
        if scale_present && ~angular_unit
            title_pax{ipax} = sprintf('%s %s',label{j},in_totvector{j});            
        else
            if ax_type == 'd'
                title_pax{ipax} = sprintf('%s%s',label{j},obj.capt_units(ax_type));
            else
                title_pax{ipax} = sprintf('%s (%s)',label{j},obj.capt_units(ax_type));
            end
        end        
        title_main_pax{ipax} = sprintf('%s = %.3g:%.2g:%.3g %s', ...
            label{j},plot_bin_centers(1:3,ipax),in_totvector{j});
        display_pax{ipax} = title_main_pax{ipax};
    else               % iax
        iiax = find(j==iax);
        title_iax{iiax}      = sprintf('%.3g \\leq %s \\leq %.3g %s', ...
            iint(1,iiax),label{j},iint(2,iiax),in_totvector{j});
        title_main_iax{iiax} = title_iax{iiax};
        display_iax{iiax}    = sprintf('%.3g =< %s =< %.3g %s', ...
            iint(1,iiax),label{j},iint(2,iiax),in_totvector{j});
    end
end

% Main title
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
title_main{iline}=sprintf('Cylindrical projection at centre: %s(hklE)',mat2str(offset));
iline = iline + 1;

if ~isempty(iax)
    title_main{iline}=title_main_iax{1};
    if length(title_main_iax)>1
        for i=2:length(title_main_iax)
            title_main{iline}=[title_main{iline},' , ',title_main_iax{i}];
        end
    end
    iline = iline + 1;
end
if ~isempty(pax)
    title_main{iline}=title_main_pax{1};
    if length(title_main_pax)>1
        for i=2:length(title_main_pax)
            title_main{iline}=[title_main{iline},' , ',title_main_pax{i}];
        end
    end
end
