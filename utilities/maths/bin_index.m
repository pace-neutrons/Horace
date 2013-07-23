function indx=bin_index(x,b,inclusive)
% Find bin index for a set of points
%
%   >> indx=bin_index(x,b)
%
% Input:
% ------
%   x           Array of points (must be monotonic increasing, but need not be strictly monotonic)
%   b           Bin boundaries (must be monotonic increasing, numel(b)>=2)
%   inclusive   Logical flag to indicate how to treat points on final bin boundary:
%                  =true:  points where x(i)==b(end) included in final bin
%                  =false: points where x(i)==b(end) are not included
%
% Output:
% -------
%   indx        Index of the bin to which the points belong. x(i) has indx(i) s.t.
%                   b(indx(i)) <= x(i) < b(indx(i)+1)
%               - If x(i) < b(1):   indx(i)=0
%               - If x(i) > b(end): indx(i)=numel(b)
%               - Points where x(i)==b(end) are included in final bin (i.e. indx(i)=numel(b)-1)
%                 or not according to the value of the logical flag inclusive above.
%               If the bin boundaries are not strictly monotonic, i has the largest value
%              possible.
%               The size and shape of indx is the same as the input array x

% T.G.Perring   2 June 2011     First version
%
% *** Crying out to be turned into Fortran or c++ : unavoidable loop

nx=numel(x);
nb=numel(b);

if nb<2
    error('BIN_INDEX:invalid_argument','Must have at least two bin boundaries')
end

% Initialise index counters, catching special cases
if x(1)>=b(1)
    if x(1)>b(end)
        indx=nb*ones(size(x));
        return
    end
    ib=upper_index(b,x(1));
    ix=1;
else
    if b(1)>x(end)
        indx=zeros(size(x));
        return
    end
    ib=1;
    ix=lower_index(x,b(1));
end

indx=zeros(size(x));
while ib < nb
    while ix<=nx && x(ix)<b(ib+1)
        indx(ix)=ib;
        ix=ix+1;
    end
    if ix>nx, return, end
    ib=ib+1;
end

% Got here if ib==nb but still ix<=nx. Could be one or more x=b(end)
if inclusive
    while ix<=nx
        if x(ix)==b(nb)
            indx(ix)=nb-1;
        else
            indx(ix:end)=nb;    % all the rest must have x(ix)>b(nb)
            return
        end
        ix=ix+1;
    end
else
    if ix<=nx
        indx(ix:end)=nb;        % all the rest must have x(ix)>b(nb)
        return
    end
end
