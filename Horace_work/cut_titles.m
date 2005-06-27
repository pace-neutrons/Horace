function [title_main, title_pax, energy_axis] = cut_titles (din)
% Get titles from nD data structure (n=0,1,2,3,4)
% 
% Input:
% ------
% din         Data from which a reduced dimensional manifold is to be taken. Its fields are:
%   din.file  File from which (h,k,l,e) data was read
%   din.title Title contained in the file from which (h,k,l,e) data was read
%   din.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   din.ulen  Length of vectors in Ang^-1, energy
%   din.label Labels of theprojection axes (1x4 cell array of charater strings)
%   din.p0    Offset of origin of projection [ph; pk; pl; pen]
%   din.pax   Index of plot axes in the matrix din.u
%               e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   din.p1    (Row) vector of bin boundaries along first plot axis
%   din.p2    (Row) vector of bin boundaries along second plot axis
%     :       (for as many plot axes as given by length of din.pax)
%   din.iax   Index of integration axes in the matrix din.u
%               e.g. if data is 2D, din.iax=[3,1] means summation has been performed along u3 and u1 axes
%   din.uint  Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]
%   din.s     Cumulative signal.  [size(din.s)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.e     Cumulative variance [size(din.e)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.n     Number of contributing pixels [size(din.n)=(length(din.p1)-1, length(din.p2)-1, ...)]
%
% Output:
% -------
% title_main  Main title (cell array of character strings)
% title_pax   Cell array containing axes annotations for eaxh of the plot axes
% energy_axis The index of the column in the 4x4 matrix din.u that corresponds to the energy axis

% Author:
%   T.G.Perring     20/06/2005
% Modified:
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
for j=1:4
    p0_ch{j} = num2str(p0(j),'%+11.4g');        
    for i=1:4
        u_ch{i,j} = num2str(u(i,j),'%+11.4g');  % format ensures sign (+ or -) is attached to character representation
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
            if ~strcmp(num2str(ulen(j)),'1')
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
            if ~strcmp(num2str(ulen(j)),'1')
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


% for i=1:size(title_main,2)
%     disp(title_main{i})
% end
% disp(' ')
% for i=1:length(title_pax)
%     disp(title_pax{i})
% end

    
