function xout=round_to_vals(x,x_ok)
% Round to the nearest value in an array of 'nice' values, in a logarithmic sense
%
%   >> xout=round_to_vals(x)         
%   >> xout=round_to_vals(x,x_ok)
%
% Input:
% ------
%   x       Array of values
%   x_ok    Array of values to which x will be rounded in a logarithmic sense
%           Must all lie in the range 1<= x_ok <=10. The values 1 and 10 will
%          always be included
%
% Output:
% -------
%   xout    The rounded values. Where x(i)=0, the value will be unchanged.
%          Negative values of x are also rounded to negative values of x_ok

% Prepare list of 'nice' values
if nargin==1
    x_ok=[1,2,2.5,5,10];
else
    if min(x_ok(:))<1 || max(x_ok(:))>10
        error('Valid values must lie in range 1<=dx<=10')
    end
    x_ok=[1,x_ok(:)',10];
end

% Initialise output
xout=zeros(size(x));

% Get 'nice' values, leaving zeros unchanged and accounting for sign
sgn=sign(x);
ok=(sgn~=0);    % pick out non-zero values
xout(ok)=round_internal(abs(x(ok)),x_ok);
xout=xout.*sgn;


function dx_out=round_internal(dx,dx_ok)
logdx_ok=log10(dx_ok);      % range 0<=logdx_ok<1 by construction
logdx=mod(log10(dx),1);     % range 0<=logdx<1

ind=zeros(size(dx));
for i=1:numel(dx)
    [dummy,ind(i)]=min(abs(logdx(i)-logdx_ok));
end
dx_out=reshape(dx_ok(ind),size(dx)).*10.^(floor(log10(dx)));
