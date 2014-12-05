function v=appversion(n1,n2,n3,n4)
% Create an application version number
%
%   >> ver = appversion (n1)
%   >> ver = appversion (n1,n2)
%   >> ver = appversion (n1,n2,n3)
%   >> ver = appversion (n1,n2,n3,n4)
%   >> ver = appversion ([n1,..])
%
%   >> ver = appversion (str)       % give string
%
% Input:
% ------
% Numeric component inputs must be integers in the range 0 - 999
% e.g.  >> ver = appversion (3,2)
%       >> ver = appversion (3,2,12)
%
% A special case is a scalar real, when the integer part and the decimal
% part are treated as n1 and n2
% e.g.  >> ver = appversion (3)         % same as ver=appversion(3,0)
%       >> ver = appversion (3.5)       % same as ver=appversion(3,5)
%
% String input must have the form 'vn', 'vn.m', 'vn.m.p' or 'vn.m.p.q' where
% n,m,p,q are integers
% e.g. 'v5', 'v3.2', 'v4.0', 'v2.1.35'
%
% Note: trailing zeros in the version are not significant. For example,
% 'v4.0.0' and 'v4' are equivalent. Likewise appversion(3,0),
% appversion(3,0,0) and appversion(3.0) are all equivalent.
%
%
% Output:
% -------
%   ver         appversion (real number of form nnn.mmmpppqqq) where
%              nnn is an integer in the range 0 to 999, as is mmm, ppp, qqq
%              with leading zeros as required.


if nargin==1
    if isnumeric(n1)
        if isscalar(n1)
            if rem(n1,1)==0
                [v,mess]=appversion_num(n1);    % integer
            else
                [v,mess]=appversion_num([floor(n1),1000*rem(n1,1)]); % real
            end
        elseif numel(n1)>1 && numel(n1)<=4
            [v,mess]=appversion_num(n1);        % array
        else
            v=[];
            mess='Check number of arguments';
        end
            
    elseif ischar(n1)&& numel(size(n1))==2 && size(n1,1)==1
        [v,mess]=appversion_str(n1);
        
    else
        v=[];
        mess='Check argument has a valid type';
    end
    
elseif nargin==2
    if numscalar(n1) && numscalar(n2)
        [v,mess]=appversion_num([n1,n2]);
    else
        v=[];
        mess='Check input arguments are numeric scalars';
    end
    
elseif nargin==3
    if numscalar(n1) && numscalar(n2) && numscalar(n3)
        [v,mess]=appversion_num([n1,n2,n3]);
    else
        v=[];
        mess='Check input arguments are numeric scalars';
    end
    
elseif nargin==4
    if numscalar(n1) && numscalar(n2) && numscalar(n3) && numscalar(n4)
        [v,mess]=appversion_num([n1,n2,n3,n4]);
    else
        v=[];
        mess='Check input arguments are numeric scalars';
    end
    
else
    v=0;
    mess='';
end

if ~isempty(mess)
    error(mess)
end

%--------------------------------------------------------------------------
function [v,mess]=appversion_num(arr)
% Create a version number from a numeric array

if all(rem(arr,1)==0 & arr>=0 & arr<=999)
    v=arr(end);
    for i=numel(arr)-1:-1:1
        v=arr(i)+v/1000;
    end
    mess='';
else
    v=[];
    mess='Check that each numeric entry is an integer in the range 0 to 999';
end

%--------------------------------------------------------------------------
function [v,mess]=appversion_str(verstr)
% Create a numeric array of version components from a character string

if ((size(verstr,2)>1 && lower(verstr(1:1))=='v') || ...
        (size(verstr,2)>2 && strcmpi(verstr(1:2),'-v')))
    ind=[strfind(lower(verstr(1:2)),'v'),strfind(verstr,'.'),numel(verstr)+1];
    if numel(ind)>5
        v=[];
        mess='Check format of version string';
        return
    end
    arr=zeros(1,numel(ind)-1);
    for i=1:numel(ind)-1
        c=verstr(ind(i)+1:ind(i+1)-1);
        if isuint(c,3)
            arr(i)=str2double(c);
        else
            v=[];
            mess='Check format of version string';
            return
        end
    end
    [v,mess]=appversion_num(arr);
else
    v=[];
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
function ok=numscalar(var)
% Check an argument is a numeric scalar
if isnumeric(var) && isscalar(var)
    ok=true;
else
    ok=false;
end
