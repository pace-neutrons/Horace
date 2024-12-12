function wout=combine(w1,w2,varargin)
%
% Combine two d1d (or sqw of d1d-type) datasets.
%
% wout=combine(w1,w2) - combines w1 and w2. The bins and
% specified by w1 will be those used for wout. The limits of wout are such
% that all of the data from both datasets are included.
%
% wout=combine_horace_1d(w1,w2,tol) - combine w1 and w2 with a tolerance
% factor given by the scalar tol. Tol basically specifies the bin width of
% wout.
%
% RAE 21/1/10


[ndims1, ~]=dimensions(w1);
[ndims2, ~]=dimensions(w2);

if ndims1~=1 || ndims2~=1
    error('HORACE:d1d:invalid_argument', ...
        'Both objects have the same dimensionality. Actually, ndims(obj1) = %d, ndims(obj2)=%d ', ...
        ndims1,ndims2);
end

%First set of cases is where no tolerance is specified
if nargin==2
    has_tolerance = false;
elseif nargin==3
    tol=varargin{1};
    if ~isnumeric(tol)
        error('HORACE:d1d:invalid_argument', ...
            'the combining tolerance should be specified by a scalar');
    elseif numel(tol)~=1
        error('HORACE:d1d:invalid_argument', ...
            'The combining tolerance should be specified by a scalar');
    end
    has_tolerance = true;
else
    error('HORACE:d1d:invalid_argument', ...
        'Incorrect number of input arguments. 2 or 3 allowed, Provided: %d', ...
        nargin);
end

%
%
if ~isequal(w1.proj, w2.proj)
    error('HORACE:d1d:invalid_argument', ...
        '1d objects must have same x-axis type and direction');
end
%

x1 = w1.p{1}; x2 = w2.p{1};
s1 = w1.s; s2 = w2.s;
e1 = w1.e; e2 = w2.e;
n1 = w1.npix; n2 = w2.npix;

if has_tolerance
    [xout, sout, eout, nout]=combine_1d(x1,s1,e1,n1,x2,s2,e2,n2,tol);
else
    [xout, sout, eout, nout]=combine_1d(x1,s1,e1,n1,x2,s2,e2,n2,[]);
end

% Now need to construct the output d1d
nbins = numel(xout)-1;
step  = xout(2)-xout(1);
nbins_all_dims = w1.axes.nbins_all_dims;
tot_range       = w1.img_range;
nbins_all_dims(w1.pax) = nbins;
range = min_max(xout');
range(1)=range(1)+0.5*step;
range(2)=range(2)-0.5*step;
tot_range(:,w1.pax) = range;

wout=d1d(w1);
wout.do_check_combo_arg = false;
wout.axes.nbins_all_dims =nbins_all_dims;
wout.axes.img_range      = tot_range;
wout.s=sout;
wout.e=eout;
wout.npix=nout;
wout.title=[wout.title,' COMBINED '];
wout.do_check_combo_arg = true;
wout = wout.check_combo_arg();
