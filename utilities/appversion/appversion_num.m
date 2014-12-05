function arr=appversion_num(v,opt)
% Get the numeric array representation of a version
%
%   >> arr = appversion_num (ver)
%
% Input:
% ------
%   ver         appversion (real number of form nnn.mmmpppqqq) where
%              nnn is an integer in the range 0 to 999, as is mmm, ppp, qqq
%              with leading zeros as required.
%
% Output:
% -------
%   arr         Array of the version indicies e.g. [3,2,13] for version 3.2.13

if v<1000 && v>=0
    % Get array
    tmp=v*1e9;
    arr=zeros(1,4);
    arr(1)=floor(tmp/1e9);
    tmp=tmp-1e9*arr(1);
    arr(2)=floor(tmp/1e6);
    tmp=tmp-1e6*arr(2);
    arr(3)=floor(tmp/1e3);
    tmp=tmp-1e3*arr(3);
    arr(4)=floor(tmp);
    if rem(tmp,1)~=0
        error('Check input has valid form to be a version number')
    end
    
    % Determine if long or short format wanted:
    if nargin==2
        if ~isempty(opt)
            if strncmpi(opt,'short',numel(opt))
                short=true;
            elseif strncmpi(opt,'long',numel(opt))
                short=false;
            else
                error('Invalid option')
            end
        else
            error('Invalid option')
        end
    else
        short=true;
    end
    % Strip trailing zeros if 'short'
    if short
        if arr(4)==0
            nmax=3;
            if arr(3)==0
                nmax=2;
                if arr(2)==0
                    nmax=1;
                end
            end
            arr=arr(1:nmax);
        end
   end
    
else
    error('Check input has valid form to be a version number')
end
