function [title_main, title_pax, energy_axis] = cut_titles (din)
% Get titles from nD data structure (n=0,1,2,3,4)
%
% Syntax:
%   >> [title_main, title_pax, energy_axis] = cut_titles (din)
% 
% Input:
% ------
%   din             Dataset for which titles are to be created from the data in its
%                  fields.
%                   Type >> help dnd_checkfields for a full description of the fields
%
% Output:
% -------
%   title_main      Main title (cell array of character strings)
%   title_pax       Cell array containing axes annotations for each of the plot axes
%   energy_axis     The index of the column in the 4x4 matrix din.u that corresponds
%                  to the energy axis

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

% Prepare input arguments
file = din.file;
title = din.title;
u = din.u;
ulen = din.ulen;
p0 = din.p0;
pax = din.pax;
uplot = zeros(3,length(pax));
for i=1:length(pax)
    pvals_name = ['p', num2str(i)];         % name of field containing bin boundaries for the plot axis to be integrated over
    pvals = din.(pvals_name);               % values of bin boundaries (use dynamic field names facility of Matlab)
    uplot(1,i) = pvals(1);
    uplot(2,i) = pvals(2)-pvals(1);
    uplot(3,i) = pvals(end);
end
iax = din.iax;
uint = din.uint;
label = din.label;

% Axes and integration titles
% Character representations of input data
small = 1.0e-10;    % tolerance for rounding numbers to zero or unity in titling
for j=1:4
    if abs(p0(j)) > small
        p0_ch{j} = num2str(p0(j),'%+11.4g');        
    else
        p0_ch{j} = num2str(0,'%+11.4g');        
    end
    for i=1:4
        if abs(u(i,j)) > small
            u_ch{i,j} = num2str(u(i,j),'%+11.4g');  % format ensures sign (+ or -) is attached to character representation
        else
            u_ch{i,j} = num2str(0,'%+11.4g');  % format ensures sign (+ or -) is attached to character representation
        end
    end
end

m_npax = 0;
m_niax = 0;
for j=1:4
    % Determine if column vector in u corresponds to a Q-axis or energy
    if u(4,j)==0
        % Q axis
        for i=1:3
            if ~strcmp(p0_ch{i}(2:end),'0') & ~strcmp(u_ch{i,j}(2:end),'0')     % p0(i) and u(i,j) both contain non-zero values
                if ~strcmp(u_ch{i,j}(2:end),'1')
                    ch{i,j} = [p0_ch{i},u_ch{i,j},label{j}];
                else
                    ch{i,j} = [p0_ch{i},u_ch{i,j}(1),label{j}];
                end
            elseif strcmp(p0_ch{i}(2:end),'0') & ~strcmp(u_ch{i,j}(2:end),'0')  % p0(i)=0 but u(i,j)~=0
                if ~strcmp(u_ch{i,j}(2:end),'1')
                    ch{i,j} = [u_ch{i,j},label{j}];
                else
                    ch{i,j} = [u_ch{i,j}(1),label{j}];
                end
            else
                ch{i,j} = p0_ch{i};
            end
            if ch{i,j}(1)=='+'        % strip off leading '+'
                ch{i,j} = ch{i,j}(2:end);
            end
        end
        vector{j} = ['[',ch{1,j},', ',ch{2,j},', ',ch{3,j},']'];
        if ~isempty(find(j==pax))   % j appears in the list of plot axes
            ipax = find(j==pax);
            if abs(ulen(j)-1) > small
                title_pax{ipax} = [vector{j},' in ',num2str(ulen(j)),' Å^{-1}'];
            else
                title_pax{ipax} = [vector{j},' (Å^{-1})'];
            end
            m_npax = m_npax + 1;
            title_main_pax{m_npax} = [label{j},'=',num2str(uplot(1,ipax)),':',num2str(uplot(2,ipax)),':',num2str(uplot(3,ipax)),' in ',vector{j}];
        elseif ~isempty(find(j==iax))   % j appears in the list of integration axes
            iiax = find(j==iax);
            m_niax = m_niax + 1;
            title_main_iax{m_niax} = [num2str(uint(1,iiax)),'\leq',label{j},'\leq',num2str(uint(2,iiax)),' in ',vector{j}];
        else
            error ('ERROR: Axis is neither plot axis nor integration axis')
        end
    else
        % energy axis
        energy_axis = j;
        if ~strcmp(p0_ch{4}(2:end),'0') & ~strcmp(u_ch{4,j}(2:end),'0')     % p0(4) and u(4,j) both contain non-zero values
            if ~strcmp(u_ch{4,j}(2:end),'1')
                ch{4,j} = [p0_ch{4},u_ch{4,j},label{j}];
            else
                ch{4,j} = [p0_ch{4},u_ch{4,j}(1),label{j}];
            end
        elseif strcmp(p0_ch{4}(2:end),'0') & ~strcmp(u_ch{4,j}(2:end),'0')  % p0(4)=0 but u(4,j)~=0
            if ~strcmp(u_ch{4,j}(2:end),'1')
                ch{4,j} = [u_ch{4,j},label{j}];
            else
                ch{4,j} = [u_ch{4,j}(1),label{j}];
            end
        end
        if ch{4,j}(1)=='+'        % strip off leading '+'
            ch{4,j} = ch{4,j}(2:end);
        end
        vector{j} = ['[',ch{4,j},']'];
        if ~isempty(find(j==pax))   % j appears in the list of plot axes
            ipax = find(j==pax);
            if abs(ulen(j)-1) > small
                title_pax{ipax} = [vector{j},' in ',num2str(ulen(j)),' meV'];
            else
                title_pax{ipax} = [vector{j},' (meV)'];
            end
            m_npax = m_npax + 1;
            title_main_pax{m_npax} = [label{j},'=',num2str(uplot(1,ipax)),':',num2str(uplot(2,ipax)),':',num2str(uplot(3,ipax)),' in ',vector{j}];
        elseif ~isempty(find(j==iax))   % j appears in the list of integration axes
            iiax = find(j==iax);
            m_niax = m_niax + 1;
            title_main_iax{m_niax} = [num2str(uint(1,iiax)),'\leq',label{j},'\leq',num2str(uint(2,iiax)),' in ',vector{j}];
        else
            error ('ERROR: Axis is neither plot axis nor integration axis')
        end
    end
end


% Main title
title_main{1}=avoidtex(file);
title_main{2}=title;
title_main{3}=title_main_iax{1};
if length(title_main_iax)>1
    for i=2:length(title_main_iax)
        title_main{3}=[title_main{3},' , ',title_main_iax{i}];
    end
end
title_main{4}=title_main_pax{1};
if length(title_main_pax)>1
    for i=2:length(title_main_pax)
        title_main{4}=[title_main{4},' , ',title_main_pax{i}];
    end
end
