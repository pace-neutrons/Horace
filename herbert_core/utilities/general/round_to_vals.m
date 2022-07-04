function xout=round_to_vals(x,varargin)
% Round to the nearest value in an array of 'nice' values, in a logarithmic sense
%
%   >> xout=round_to_vals(x)            % Default rounding values
%   >> xout=round_to_vals(x,x_ok)       % Custom rounding values
%
%   >> xout=round_to_vals(...,'in')     % Round towards zero
%   >> xout=round_to_vals(...,'out')    % Round to larger values of modulus
%
% Input:
% ------
%   x       Array of values
%   x_ok    Array of values to which x will be rounded in a logarithmic sense
%           Must all lie in the range 1<= x_ok <=10. The values 1 and 10 will
%          always be added to the list if they are not present.
%
%
% Output:
% -------
%   xout    The rounded values. Where x(i)=0, the value will be unchanged.
%          Negative values of x are also rounded to negative values of x_ok


x_ok_default = [1,2,2.5,5,10];  % better would be [1,1.2,1.5,2,2.5,3,4,5,6,8,10]

% Parse input
nopt = numel(varargin);
if nopt>0
    if nopt==1 && ischar(varargin{1})
        x_ok = x_ok_default;
        opt = round_option (varargin{1});
    elseif nopt==1 && isnumeric(varargin{1})
        x_ok = varargin{1};
        opt = round_option('');
    elseif nopt==2 && isnumeric(varargin{1}) && ischar(varargin{2})
        x_ok = varargin{1};
        opt = round_option(varargin{2});
    else
        error('Check number of options and/or type')
    end
else
    x_ok = x_ok_default;
    opt = round_option ('');    % the default
end

% Check input
if min(x_ok(:))>=1 && max(x_ok(:))<=10
    x_ok=[1,x_ok(:)',10];   % row vector
else
    error('Valid values must lie in range 1<=dx<=10')
end
if isempty(opt)
    error('Invalid rounding option')
end

% Initialise output
xout=zeros(size(x));

% Get 'nice' values, leaving zeros unchanged and accounting for sign
sgn = sign(x);
if strcmp(opt,'up')
    % +ve values round out, -ve round modulus in
    pos = (sgn>0);
    neg = (sgn<0);
    xout(pos) = round_internal(x(pos),x_ok,'out');
    xout(neg) = -round_internal(abs(x(neg)),x_ok,'in');
elseif strcmp(opt,'down')
    % +ve values round in, -ve round modulus out
    pos = (sgn>0);
    neg = (sgn<0);
    xout(pos) = round_internal(x(pos),x_ok,'in');
    xout(neg) = -round_internal(abs(x(neg)),x_ok,'out');
else
    ok = (sgn~=0);  % pick out non-zero values
    xout(ok) = round_internal(abs(x(ok)),x_ok,opt);
    xout = xout.*sgn;
end

%------------------------------------------------------------------------------
function status = round_option (char)
% status = 'in','out','round' (default if char is empty)
% if unrecognised, then status = ''
if isempty(char)
    status = 'round';
else
    status_ok = {'in','out','round','up','down'};
    ind = find(strncmpi(char,status_ok,numel(char)));
    if ~isempty(ind)
        status = status_ok{ind};
    else
        status = '';
    end
end

%------------------------------------------------------------------------------
function x_out=round_internal(x,x_ok,opt)
logx_ok = log10(x_ok);    % range 0<=logdx_ok<1 by construction
logx = mod(log10(x),1);   % range 0<=logdx<1

logx_ok = repmat(logx_ok(:)',numel(x),1);% make row and repeat rows
logx = repmat(logx(:),1,numel(x_ok));    % make column and repeat columns

if strcmp(opt,'round')
    [~,ind] = min(abs(logx-logx_ok),[],2);
elseif strcmp(opt,'in')
    dlogx = logx-logx_ok;
    dlogx(dlogx<0) = NaN;
    [~,ind] = min(dlogx,[],2);
elseif strcmp(opt,'out')
    dlogx = logx-logx_ok;
    dlogx(dlogx>0) = NaN;
    [~,ind] = max(dlogx,[],2);
else
    error('Logical error. See T.G.Perring')
end
x_out=reshape(x_ok(ind),size(x)).*10.^(floor(log10(x)));
