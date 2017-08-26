function [ok,mess,n,theta_deg,uoffset] = check_rotation_args (varargin)
% Check if a set af input arguments can describe a reflection
%
%   >> [ok,mess,n,theta_deg,uoffset] = check_rotation (n_in,theta_deg_in)
%   >> [ok,mess,n,theta_deg,uoffset] = check_rotation (n_in,theta_deg_in,uoffset_in)
%
% Input
% -----
%   n_in        Three vector of [h,k,l] (row or column) defining rotation axis
%   theta_deg   Angle of rotation (deg)
%   uoffset_in  Three vector of [h,k,l] (row or column)


ok = true;
mess = '';

if isnumeric(varargin{1}) && numel(varargin{1})==3 && ~all(varargin{1}==0)
    n = varargin{1}(:)';    % make row vector
else
    [ok,mess,n,theta_deg,uoffset] = error_state...
        ('Rotation vector n must be a three vector with at last one non-zero element');
    return
end

if isnumeric(varargin{2}) && numel(varargin{2})==1
    theta_deg = varargin{2};
else
    [ok,mess,n,theta_deg,uoffset] = error_state ('Rotation angle must be numeric scalar');
    return
end

if numel(varargin)==2
    uoffset = [0,0,0];
else
    if isnumeric(varargin{3}) && numel(varargin{3})==3
        uoffset = varargin{3}(:)';    % make row vector
    else
        [ok,mess,n,theta_deg,uoffset] = error_state...
            ('Vector uoffset must be a three vector with at last one non-zero element');
        return
    end
end

%---------------------------------------------------------------------------------
function [ok,mess,n,theta_deg,uoffset] = error_state (mess_in)
ok = false;
mess = mess_in;
n = [0,0,0];
theta_deg = 0;
uoffset = [0,0,0];
