function [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = data_plot_titles_(obj,proj)
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

if ~isa(proj,'spher_proj')
    error('HORACE:spher_axes:inalid_argument', ...
        'Spherical projection titiles request spherical projection asof axes block and projection.\n Needed: spher_axes and spher_proj. Available: %s and %s', ...
        class(obj),class(proj));
end

energy_axis = 4;
small = 1.0e-10;    % tolerance for rounding numbers to zero or unity in titling


% Prepare input arguments
file  = obj.full_filename;
title = obj.title;
%
ulen  = obj.ulen;
label = obj.label;


pax   = obj.pax;
br    = obj.get_cut_range();
dax   = obj.dax;
n_dim = numel(pax);
%
plot_bin_centers = reshape([br{dax}],3,n_dim);


% Axes and integration titles
% Character representations of input data
%==========================================================================
offset   = proj.offset;
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
type = [proj.type,'e'];

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
    in_totvector{j} =  [' in ',obj.capt_units(ax_type)];
    if ismember(j,pax) % pax
        ipax = find(j==pax(dax));
        if abs(ulen(j)-1) > small
            title_pax{ipax} = [label{j},' in ',num2str(ulen(j)),' ',obj.capt_units(ax_type)];
        else
            if ax_type == 'd'
                title_pax{ipax} = [label{j},obj.capt_units(ax_type)];                
            else
                title_pax{ipax} = [label{j},' (',obj.capt_units(ax_type),')'];
            end
        end
        title_main_pax{ipax} = [label{j},'=',num2str(plot_bin_centers(1,ipax)),':',num2str(plot_bin_centers(2,ipax)),':',num2str(plot_bin_centers(3,ipax)),in_totvector{j}];
        display_pax{ipax} = [label{j},' = ',num2str(plot_bin_centers(1,ipax)),':',num2str(plot_bin_centers(2,ipax)),':',num2str(plot_bin_centers(3,ipax)),in_totvector{j}];
    else               % iax
        iiax = find(j==iax);
        title_iax{iiax} = [num2str(iint(1,iiax)),' \leq ',label{j},' \leq ',num2str(iint(2,iiax)),in_totvector{j}];
        title_main_iax{iiax} = [num2str(iint(1,iiax)),' \leq ',label{j},' \leq ',num2str(iint(2,iiax)),in_totvector{j}];
        display_iax{iiax} = [num2str(iint(1,iiax)),' =< ',label{j},' =< ',num2str(iint(2,iiax)),in_totvector{j}];
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
title_main{iline}=sprintf('Spherical projection at centre: %s(hklE)',mat2str(offset));
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
