function y=randpoisson(lam,varargin)
% Random while numnbers from Poisson distribution with specified mean value lam
%   >> y=randpoisson(lam)           % single number from distribution with mean lam
%   >> y=randpoisson(lam,n)         % n x n matrix
%   >> y=randpoisson(lam,m,n,p...)  % m x n x p x ... array
%   >> y=randpoisson(lam,[m,n,p...])% m x n x p x ... array
%
%
% T.G.Perring 21 Dec 2006
% Inspired by algorithm POIDEV in Numerical Recipes in Fortran77
% Cambridge University Press, (Press, Teukolsky, Vetterling and Flannery)

% Compared performance with two routines available from Matlab Central file exchange:
% randraw('po',...) and randpois. The former is slow when called only once with a
% given lam; the latter has problems when lam>~200, and if called with n>~10000.
% The latter problem is because routine does not pre-allocate the output array;
% the former is inherent to the way that factorials are calculated.
% This function appears to be a good compromise. Ideally, call with randraw if N>~50,
% but then tied to a third party routine.

if lam<12
    g=exp(-lam);
    if nargin==1
        y=-1; t=1;
        while t>g
            y=y+1;
            t=t*rand;
        end
    else
        size_arr=parse_array_size(varargin{:});
        if isempty(size_arr); error('Size vector must be a row vector with integer elements.'); end
        n=prod(size_arr);
        y=zeros(n,1);
        for i=1:n
            y(i)=-1; t=1;
            while t>g
                y(i)=y(i)+1;
                t=t*rand;
            end
        end
        y=reshape(y,size_arr);
    end
else
    sq=sqrt(2*lam);
    loglam=log(lam);
    g=lam*loglam-gammaln(lam+1);
    if nargin==1
        while true
            y=-1;
            while y<0
                ylor=tan(pi*rand);
                y=sq*ylor+lam;
            end
            y=floor(y);
            t=0.9*(1+ylor^2)*exp(y*loglam-gammaln(1+y)-g);
            if rand<=t, break, end
        end
    else
        size_arr=parse_array_size(varargin{:});
        if isempty(size_arr); error('Size vector must be a row vector with integer elements.'); end
        n=prod(size_arr);
        y=zeros(n,1);
        for i=1:n
            while true
                y(i)=-1;
                while y(i)<0
                    ylor=tan(pi*rand);
                    y(i)=sq*ylor+lam;
                end
                y(i)=floor(y(i));
                t=0.9*(1+ylor^2)*exp(y(i)*loglam-gammaln(1+y(i))-g);
                if rand<=t, break, end
            end
        end
        y=reshape(y,size_arr);
    end
end

end

%----------------------------------------------------------------------------------------
function size_arr=parse_array_size(varargin)
% Gets the array that gives the size of an array from the input argument(s)
% following the syntax of built-in Matlab functions e.g. rand
%
%   >> size_arr = array_size(n)             % size_arr=[n,n]
%   >> size_arr = array_size(n,m)           % size_arr=[n,m]
%   >> size_arr = array_size(n,m,p...)      % size_arr=[n,m,p]
%   >> size_arr = array_size([n,m,p...])    % size_arr=[n,m,p]
%

% T.G.Perring 21 Dec 2006

size_arr=[];
if all(cellfun('isclass',varargin,'double'))    % every element is a real
    if length(varargin)==1
        n=varargin{1};
        if length(n)==1
            size_arr=[n,n];
        elseif isvector(n) && size(n,1)==1
            size_arr=n;
        end
    elseif all(cellfun('prodofsize',varargin)==1)   % every element is a scalar
        size_arr=cell2mat(varargin);
    end
end

end
