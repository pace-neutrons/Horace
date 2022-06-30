function v=appversion(varargin)
% Create an application version object
%
%   >> ver = appversion (n1)
%   >> ver = appversion (n1,n2)
%   >> ver = appversion (n1,n2,n3,...)
%   >> ver = appversion ([n1,..])
%
%   >> ver = appversion (str)       % give string
%
% Numeric component inputs must be integers in the range 0 - (10^15 - 1)
% e.g.  >> ver = appversion (3,2)
%       >> ver = appversion (3,2,12)
%
% A special case is a scalar real, with the decimal part having no 
% e.g.  >> ver = appversion (3)
%       >> ver = appversion (3.5)
%
% String input must have the form 'vn', 'vn.m' or 'vn.m.p' etc. where
% n,m,p,... are integers
% e.g. 'v5', 'v3.2', 'v4.0', 'v2.1.35'
% 
% Note: trailing zeros in the version are not significant. For example,
% 'v4.0.0' and 'v4' are equivalent. Likewise appversion(3,2),
% appversion(3,0,0) and appversion(3.0) are all equivalent.

if nargin==1 && ischar(varargin{1}) && numel(size(varargin{1}))==2 && size(varargin{1},1)==1
    % Can only be a version string
    [w.version,mess]=appversion_str(varargin{1});
    
elseif nargin==1 && isnumeric(varargin{1}) && isscalar(varargin{1}) && rem(varargin{1},1)~=0
    % Scalar numeric non-integer
    str=num2str(varargin{1},15);
    [w.version,mess]=appversion_str(['v',str]);
    if ~isempty(mess)
        mess='Check that the input is not negative and there are no leading zeros in the decimal';
    end
elseif nargin==1 && isnumeric(varargin{1}) && numel(varargin{1})>1
    % Can only be array of at least two numbers
    [w.version,mess]=appversion_num(varargin{1});
    
elseif nargin>=1 && allnumscalar(varargin)
    % Only remaining valid syntax is array of numeric scalars
    [w.version,mess]=appversion_num(cell2mat(varargin));

elseif nargin==0
    % Version 0 is the default
    [w.version,mess]=appversion_num(0);
    
else
    error('Check number and type of input argument(s)')
end

if isempty(mess)
    v=class(w,'appversion');
else
    error(mess)
end

%--------------------------------------------------------------------------
function [arr,mess]=appversion_num(arr_in)
% Create a numeric array of version components from a character string

if all(rem(arr_in,1)==0 & arr_in>=0 & arr_in<=999999999999999)
    arr=arr_in;
    mess='';
else
    mess='Check that each numeric entry lies in the range 0 to 999999999999999';
end

%--------------------------------------------------------------------------
function [arr,mess]=appversion_str(verstr)
% Create a numeric array of version components from a character string
mess='';
if ((size(verstr,2)>1 && lower(verstr(1:1))=='v') || ...
        (size(verstr,2)>2 && strcmpi(verstr(1:2),'-v')))
    ind=[strfind(lower(verstr(1:2)),'v'),strfind(verstr,'.'),numel(verstr)+1];
    arr=zeros(1,numel(ind)-1);
    for i=1:numel(ind)-1
        c=verstr(ind(i)+1:ind(i+1)-1);
        if isuint(c,15)
            arr(i)=str2double(c);
        else
            arr=[];
            mess='Check format of version string';
            return
        end
    end
else
    arr=[];
    mess='Check format of version string';
end

%--------------------------------------------------------------------------
function ok=isuint(str,ndig)
% Check a character string represents a valid unsigned integer with maximum ndig digits
if isempty(str) || numel(str)>ndig
    ok=false;
else
    for i=1:numel(str)
        ind=strfind('0123456789',str(i:i));
        if isempty(ind) || (i==1 && ind==1 && numel(str)>1)   % no leading zeros if more than one digit
            ok=false;
            return
        end
    end
    ok=true;
end

%--------------------------------------------------------------------------
function ok=allnumscalar(var)
% Check a cell array contains only numeric scalars
ok=true;
for i=1:numel(var)
    if ~isnumeric(var{i}) || ~isscalar(var{i})
        ok=false;
        return
    end
end
