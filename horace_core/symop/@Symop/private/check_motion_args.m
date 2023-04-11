function [ok,mess,M,m] = check_motion_args (varargin)
% Check if a set of input arguments describes a pointgroup operator
%
%   >> [ok,mess,M,m] = check_motion_args (M)
%
% Input
% -----
%   M           (3,3) matrix defining the real-space transformation which
%               the symmetry motion represents
%
%   m           [optional] 3-element vector specifying the centre at which
%               the motion transformation is applied, expressed in r.l.u.
%
% Output:
% -------
%   ok          True is all OK, false if not
%   mess        Error message if not OK, empty string if not
%   M           (3,3) matrix defining the real-space transformation which
%               the point group operation represents

% setup defaults:
ok = true;
mess = '';
M = zeros(3,3);
m = zeros(1,3);

% No-input 
if size(varargin) < 1
    ok = false;
    mess = 'Input expected';
end

% 1+ input -- the first must be M
if numel(varargin)>0 && isnumeric(varargin{1}) && numel(varargin{1})==9
    M = varargin{1};
    if ~ismatrix(M) || ~all(size(M)==[3,3])
        M = reshape(M(:),3,3);
    end
elseif size(varargin)>0
    ok = false;
    mess = 'First input must be a numeric (3,3) matrix';
end

% 2+ inputs -- the second must be m
if numel(varargin)>1 && isnumeric(varargin{2}) && numel(varargin{2})==3
    m = reshape(varargin{2}(:),1,3);
elseif size(varargin)>1
    ok = false;
    mess = 'Second input must be numeric and have 3-elements';
end

% Not all linear algebra operations are defined for integer arrays, so make
% sure that we return double-valued arrays:
if strncmp(class(M),'int',3)
    M = double(M);
end
if strncmp(class(m),'int',3)
    m = double(m);
end

