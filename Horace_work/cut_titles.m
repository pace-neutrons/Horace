function titles = cut_titles (file, title_in, u, ulen, p0, pax, iax, uint, label)
% Get titles from nD data structure (n=0,1,2,3,4)
% 
%   din.file  File from which (h,k,l,e) data was read
%   din.title Title contained in the file from which (h,k,l,e) data was read
%   din.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   din.ulen  Length of vectors in Ang^-1, energy
%   din.p0    Offset of origin of projection [ph; pk; pl; pen]
%   din.pax   Index of plot axes in the matrix din.u
%               e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   din.p1    (Row) vector of bin boundaries along first plot axis
%   din.p2    (Row) vector of bin boundaries along second plot axis
%     :       (for as many plot axes as given by length of din.pax)
%   din.iax   Index of integration axes in the matrix din.u
%               e.g. if data is 2D, din.iax=[3,1] means summation has been performed along u3 and u1 axes
%   din.uint  Integration range along each of the integration axes
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]

% Author:
%   T.G.Perring     20/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring


% Main title
title_main=title_in;

% Axes titles
% Character representations of input data
for j=1:4
    p0_ch{j} = num2str(p0(j),'%+11.4g');        
    for i=1:4
        u_ch{i,j} = num2str(u(i,j),'%+11.4g');  % format ensures sign (+ or -) is attached to character representation
    end
end

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
        if ~strcmp(num2str(ulen(j)),'1')
            len_ch = [num2str(ulen(j)),' '];
        else
            len_ch = '';
        end
        title_pax{j} = ['[',ch{1,j},',',ch{2,j},',',ch{3,j},'] in ',len_ch,'Å^{-1}'];
    else
        % energy axis
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
        if ~strcmp(num2str(ulen(j)),'1')
            len_ch = [num2str(ulen(j)),' '];
        else
            len_ch = '';
        end
        title_pax{j} = [ch{4,j},' in ',len_ch,'meV'];
    end
end

title_main
disp(title_pax{1})
disp(title_pax{2})
disp(title_pax{3})
disp(title_pax{4})
titles = 1;
    
