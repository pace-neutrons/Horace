function wout=combine_horace_1d(w1,w2,varargin)
%
% Combine two d1d (or sqw of d1d-type) datasets.
%
% wout=combine_horace_1d(w1,w2) - combines w1 and w2. The bins and
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
    error('Horace error: ensure both objects have the same dimensionality')
end

if isa(w1,'sqw') && isa(w2,'sqw')
    if has_pixels(w1) && has_pixels(w2)
        error('Horace error: d1d method cannot be used for 2 sqw objects with pixel info. Logic flaw');
    end
end

%First set of cases is where no tolerance is specified
if nargin==2
    has_tolerance = false;
elseif nargin==3
    tol=varargin{1};
    if ~isnumeric(tol)
        error('Horace error: the combining tolerance should be specified by a scalar');
    elseif numel(tol)~=1
        error('Horace error: the combining tolerance should be specified by a scalar');
    end
    has_tolerance = true;
else
    error('Horace error: check number and format of input arguments');
end

%
[ok, same_axes, mess]=check_rebinning_axes_1d(w1, w2);
if ~ok
    error(mess);
end

%
if same_axes
    %
    if isequal(w1.data_.u_to_rlu(:,w1.data_.pax(1)), w2.data_.u_to_rlu(:,w2.data_.pax(1)))
        x1 = w1.data_.p{1}; x2 = w2.data_.p{1};
        s1 = w1.data_.s; s2 = w2.data_.s;
        e1 = w1.data_.e; e2 = w2.data_.e;
        n1 = w1.data_.npix; n2 = w2.data_.npix;

        if has_tolerance
            [xout, sout, eout, nout]=combine_1d(x1,s1,e1,n1,x2,s2,e2,n2,tol);
        else
            [xout, sout, eout, nout]=combine_1d(x1,s1,e1,n1,x2,s2,e2,n2,[]);
        end

        % Now need to construct the output d1d
        wout=d1d(w1);
        wout.data_.p{1}=xout(:,1);
        wout.data_.s=sout;
        wout.data_.e=eout;
        wout.data_.npix=nout;
        wout.data_.title=[wout.data_.title,' COMBINED '];;
    else
        error('Horace error: 1d objects must have the same x-axis');
    end
else
    error('Horace error: 1d objects must have same x-axis projection');
end
