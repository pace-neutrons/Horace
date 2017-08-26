function [ok,mess,u,v,uoffset] = check_reflection_args (varargin)
% Check if a set af input arguments can describe a reflection
%
%   >> [ok,mess,u,v,uoffset] = check_reflection (u_in,v_in)
%   >> [ok,mess,u,v,uoffset] = check_reflection (u_in,v_in,uoffset_in)
%
% Input
% -----
%   u_in        Three vector of [h,k,l] (row or column)
%   v_in        Three vector of [h,k,l] (row or column)
%   uoffset_in  Three vector of [h,k,l] (row or column)
%
%   u_in, v_in define the mirror plane


ok = true;
mess = '';

if isnumeric(varargin{1}) && numel(varargin{1})==3 && ~all(varargin{1}==0)
    u = varargin{1}(:)';    % make row vector
else
    [ok,mess,u,v,uoffset] = error_state...
        ('Vector u must be a three vector with at last one non-zero element');
    return
end

if isnumeric(varargin{2}) && numel(varargin{2})==3 && ~all(varargin{2}==0)
    v = varargin{2}(:)';    % make row vector
else
    [ok,mess,u,v,uoffset] = error_state...
        ('Vector v must be a three vector with at last one non-zero element');
    return
end

if abs(cross(u,v))/(norm(u)*norm(v)) < 1e-6
    [ok,mess,u,v,uoffset] = error_state...
        ('Vectors u and v defining a mirror plane are collinear or almost collinear');
    return
end

if numel(varargin)==2
    uoffset = [0,0,0];
else
    if isnumeric(varargin{3}) && numel(varargin{3})==3
        uoffset = varargin{3}(:)';    % make row vector
    else
        [ok,mess,u,v,uoffset] = error_state...
            ('Vector uoffset must be a three vector with at last one non-zero element');
        return
    end
end

%---------------------------------------------------------------------------------
function [ok,mess,u,v,uoffset] = error_state (mess_in)
ok = false;
mess = mess_in;
u = [0,0,0];
v = [0,0,0];
uoffset = [0,0,0];
