function sout=expand_array(s,scale,dim)
% Increase the size of a buffer array, retaining existing elements. Useful when reading unknown quantities of data from file
%
%   >> sout=expand_array(s,scale,dim)
%
% Input:
% ------
%   s       Input array
%   scale   How to increase the length of the array along the default dimension
%          or that dimension given by third argument. Default is to double.
%           Scale is a scalar or vector length two. If the length along the dimension
%          is currently N then the new length becomes
%           N_new = scale + N
%           N_new = scale(1) + scale(2)*N
%          e.g.
%               scale=10000     Adds 10000 to the length
%               scale=[10000,1] The same
%               scale=[0,2]     Doubles the length
%   dim     Dimension to expand. Default is 1.
%
% Output:
% -------
%   sout    Expanded array, retaining the existing elements.


% Parse arguments and check values are ok
sz=size(s);
if nargin<2 || isempty(scale)
    scale=[0,2];    % default is to double length
end
if nargin<3 || isempty(dim)
    dim=1;
end

ns=numel(scale);
if isnumeric(scale) && ns>=1 && ns<=2
    const=scale(1);
    if const<0
        error('Can only add to the length of an array. Check scale argument')
    end
    if ns==2
        fac=scale(2);
        if fac<1
            error('Can only increase the length of the array. Check scale argument')
        end
    else
        fac=1;
    end
end

dim=round(dim);
if dim<1 || dim>numel(sz)
    error(['Index of the dimension to expand must lie in the range 1-',num2str(numel(sz))])
end

% Expand array
n_new=round(const+fac*sz(dim));
if n_new<=sz(dim)   % not making any bigger, so just return (account for rounding)
    sout=s;
else
    if dim==1       % special case
        sout=[s;zeros([n_new-sz(1),sz(2:end)])];
    elseif dim==2 && numel(sz)==2
        sout=[s,zeros([sz(1),n_new-sz(2)])];
    else
        error('Not yet implemented')
%         sz_out=sz;
%         sz_out(dim)=n_new;
%         sout=zeros(sz_out);
%         sout
    end
end
        