function ver_str=version_str(w,opt)
% Create a version number string from an appversion object
%
%   >> ver_str = version_str (ver)
%   >> ver_str = version_str (ver,'long')   % long format
%
% Input:
% ------
%   ver         appversion object
%
% Output:
% -------
%   ver_str     Character string equivalent
%   opt         Optional argument: if 'short' then trailing zeros in the version
%              are omitted; if 'long' then trailing zeros are significant.
%              Default is 'short'
%               e.g.  long format       short format
%                       'v5.0.0'            'v5'
%                       'v5.12.0'           'v5.12'
%                       'v5.0.132.0'        'v5.0.132'
%               The exception is if all version indicies are zero, when there
%              will always be one zero in the short form:
%               e.g.    'v0.0.0.0'          'v0'

% Determnine if long or short format wanted:
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

% Create string
ver=w.version;
if short
    ind=find(ver>0,1,'last');
else
    ind=numel(ver);
end
if ~isempty(ind)
    ver_str='v';
    for i=1:ind
        if i<ind
            ver_str=[ver_str,num2str(ver(i)),'.'];
        else
            ver_str=[ver_str,num2str(ver(i))];
        end
    end
else
    ver_str='v0';
end