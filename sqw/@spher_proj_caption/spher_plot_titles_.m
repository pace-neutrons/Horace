function [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = spher_plot_titles_(self,data)
% Get titling and caption information for an sqw data structure
%
% Syntax:
%   >> [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = data_plot_titles (data)
%
% Input:
% ------
%   data            Structure for which titles are to be created from the data in its fields.
%                   Type >> help check_sqw_data for a full description of the fields
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

% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

Angstrom=char(197);     % Angstrom symbol
%
types ={self.proj_type(1),self.proj_type(2),self.proj_type(3),'En'};
keys = {types{1},types{2},types{4}};
units = {[Angstrom,'^{-1}'],'\^{o}','mEv'};
spher_units = containers.Map(keys,units);

% Prepare input arguments
file = fullfile(data.filepath,data.filename);
title = data.title;

%uoff = data.uoffset;
centre= data.uoffset;
u_to_rlu = data.u_to_rlu;
ulen = data.ulen;
ulabel = data.ulabel;
iax = data.iax;
iint = data.iint;
pax = data.pax;
uplot = zeros(3,length(pax));
for i=1:length(pax)
    pvals = data.p{i};
    uplot(1,i) = pvals(1);
    uplot(2,i) = (pvals(end)-pvals(1))/(length(pvals)-1);
    uplot(3,i) = pvals(end);
end
dax = data.dax;

uofftot=centre;
for i=1:length(iax)
    % get offset from integration axis, accounting for non-finite limit(s)
    if isfinite(iint(1,i)) && isfinite(iint(2,i))
        iint_ave=0.5*(iint(1,i)+iint(2,i));
    else
        iint_ave=0;
    end
    uofftot=uofftot+iint_ave*u_to_rlu(:,iax(i));  % overall displacement of plot volume in (rlu;en)
end

% Axes and integration titles
% Character representations of input data
small = 1.0e-10;    % tolerance for rounding numbers to zero or unity in titling

uoff_ch=cell(1,4);
uofftot_ch=cell(1,4);
u_to_rlu_ch=cell(4,4);
for j=1:4
    if abs(centre(j)) > small
        uoff_ch{j} = num2str(centre(j),'%+11.4g');
    else
        uoff_ch{j} = num2str(0,'%+11.4g');
    end
    if abs(uofftot(j)) > small
        uofftot_ch{j} = num2str(uofftot(j),'%+11.4g');
    else
        uofftot_ch{j} = num2str(0,'%+11.4g');
    end
    for i=1:4
        if abs(u_to_rlu(i,j)) > small
            u_to_rlu_ch{i,j} = num2str(u_to_rlu(i,j),'%+11.4g');  % format ensures sign (+ or -) is attached to character representation
        else
            u_to_rlu_ch{i,j} = num2str(0,'%+11.4g');  % format ensures sign (+ or -) is attached to character representation
        end
    end
end

% pre-allocate cell arrays for titling:
title_pax = cell(length(pax),1);
display_pax = cell(length(pax),1);
title_iax = cell(length(iax),1);
display_iax = cell(length(iax),1);
title_main_pax = cell(length(pax),1);
title_main_iax = cell(length(iax),1);
%

% Create titling
for j=1:4
    if any(j==pax)   % j appears in the list of plot axes
        ipax = find(j==pax(dax));
        unit = spher_units(types{ipax});
        if abs(ulen(j)-1) > small
            title_pax{ipax} = [ulabel{j},' in ',num2str(ulen(j)),' ',unit{j}];
        else
            title_pax{ipax} = [ulabel{j},' (',Angstrom,'^{-1})'];
        end
        title_main_pax{ipax} = [ulabel{j},'=',num2str(uplot(1,ipax)),':',num2str(uplot(2,ipax)),':',num2str(uplot(3,ipax)),unit];
        display_pax{ipax} = [ulabel{j},' = ',num2str(uplot(1,ipax)),':',num2str(uplot(2,ipax)),':',num2str(uplot(3,ipax)),unit];
    elseif any(j==iax)   % j appears in the list of integration axes
        iiax = find(j==iax);
        unit = spher_units(types{iiax});
        title_iax{iiax} = [num2str(iint(1,iiax)),' \leq ',ulabel{j},' \leq ',num2str(iint(2,iiax)),unit];
        title_main_iax{iiax} = title_iax{iiax};
        display_iax{iiax} = [num2str(iint(1,iiax)),' =< ',ulabel{j},' =< ',num2str(iint(2,iiax)),unit];
    else
        error ('ERROR: Axis is neither plot axis nor integration axis')
    end
    
    % Determine if column vector in u corresponds to a Q-axis or energy
    if u_to_rlu(4,j)~=0
        energy_axis = j;
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
