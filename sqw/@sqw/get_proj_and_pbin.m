function [proj, pbin] = get_proj_and_pbin (w)
% Reverse engineer the projection and binning of an sqw object
%
%   >> [proj, pbin] = get_proj_and_pbin (w)
%
% Input:
% ------
%   w       sqw object
%
% Output:
% -------
%   proj    Projection as a projaxes object
%   pbin    Cell array, a row length 4, of the binning description of the
%          sqw object


% T.G.Perring   30 September 2018

if numel(w)==1
    [proj, pbin] = get_proj_and_pbin_single (w.data);
elseif numel(w)>1
    proj = repmat(projaxes,size(w));
    pbin = repmat({{[],[],[],[]}},size(w));
    for i=1:numel(w)
        [proj(i), pbin{i}] = get_proj_and_pbin_single (w(i).data);
    end
else
    proj = repmat(projaxes,size(w));
    pbin = repmat({{[],[],[],[]}},size(w));
end

%------------------------------------------------------------------------------
function [proj, pbin] = get_proj_and_pbin_single (data)
% Reverse engineer the projection and binning from data field

% Get projection
% --------------------------
% Projection axes
proj.u = data.u_to_rlu(1:3,1)';
proj.v = data.u_to_rlu(1:3,2)';
proj.w = data.u_to_rlu(1:3,3)';

% Determine if projection is orthogonal or not
b = bmatrix(data.alatt, data.angdeg);
ux = b*proj.u';
vx = b*proj.v';
nx = cross(ux,vx); nx = nx/norm(nx);
wx = b*proj.w'; wx = wx/norm(wx);
if abs(cross(nx,wx))>1e-10
    proj.nonorthogonal = true;
else
    proj.nonorthogonal = false;
end

proj.type = 'ppp';

proj.uoffset = data.uoffset';

proj = projaxes(proj);

% Get binning
% -------------------------
pbin=cell(1,4);
for i=1:numel(data.pax)
    pbin{data.pax(i)} = pbin_from_p(data.p{i});
end
for i=1:numel(data.iax)
    pbin{data.iax(i)} = data.iint(:,i)';
end

%------------------------------------------------------------------------------
function pbin = pbin_from_p (p)
% Get 1x3 binning description from equally spaced bin boundaries
pbin = [(p(1)+p(2))/2, (p(end)-p(1))/(numel(p)-1), (p(end-1)+p(end))/2];
