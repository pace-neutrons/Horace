function [ok, mess, proj, pbin] = transform_proj (obj, alatt, angdeg, proj_in, pbin_in)
% Transform projection axes description by the symmetry operation
%
%   >> [ok, mess, proj, pbin] = transform_proj (obj, alatt, angdeg, proj_in, pbin_in)
%
% Input:
% ------
%   obj     Symmetry operator or array of symmetry operators
%           If an array, then they are applied in order obj(1), obj(2),...
%
%   alatt   Lattice parameters [a,b,c] (Angstrom)
%
%   angdeg  Lattice angles [alf, bet, gam] (deg)
%
%   proj_in Projection object defining projection axes, with fields
%               u, v, w (optionally) 
%           (other fields are unaffected)
%
%   pbin_in Cell array with the exact bin descriptor along each Q axis. That is,
%           if the ith axis is an integration axis pbin_in{i} is a vector
%           length 2; if a plot axis it is a vector length 3 where the
%           final element is the true bin centre of the last bin i.e. the
%           range is an integer multiple of the step. (row, length 3)
%
% Output:
% -------
%   proj    Transformed projection
%
%   pbin    Cell array with transformed bin descriptors. (row, length 3)
%
%
% Note: the reason for requiring the condition on projection axes in the
% description of pbin_in is that in the case of a reflection and all three
% momentum axes being plot axes, the third axis has to be inverted to ensure
% a right-hand coordinate set. Strictly, the condition only applies to the
% third axis when all three momentum axes are plot axes.


ok = true;
mess = '';

if numel(obj)<1
    error('Empty symmetry operation object array')
end

b = bmatrix (alatt, angdeg);

% Transform proj
proj = proj_in;
sgn = zeros(1,numel(obj));
for i=1:numel(obj)
    [proj,sgn(i)] = transform_proj_single (obj(i), b, proj);
end
sgntot = prod(sgn);     % +1 or -1 depending on even or odd number of reflections

% Ensure proj forms a right-hand set transform bin descriptors accordingly
pbin = pbin_in;
if sgntot<0     % odd number of reflections
    % Does not work for non-orthogonal axes. The problem is that reflections
    % do not have a simple relationship
    if proj.nonorthogonal
        ok = false;
        mess = 'Symmetry transformed non-orthogonal projections not supported';
        return
    end
    % Find an axis to invert. Invert an integration axis (then there are no
    % problems with order of bins in the sqw object); if none, then invert axis 3
    if numel(pbin{3})==2 || (numel(pbin{1})~=2 && numel(pbin{2}(2))~=2)
        if numel(pbin{3})==2
            pbin{3} = -[pbin{3}(2),pbin{3}(1)];
        else
            % The following is correct if the true bin descriptor is given
            % i.e. the interval is an integer multiple of the step size
            nbin = (pbin{3}(3)-pbin{3}(1))/pbin{3}(2);
            if abs(nbin-round(nbin)) < 1e-5
                pbin{3} = [-pbin{3}(3),pbin{3}(2),-pbin{3}(1)];
            else
                ok = false;
                mess = 'Range along third projection axis is not an integer multiple of bin size';
                return
            end
        end
        proj.w = -proj.w;
    elseif numel(pbin{2})==2
        pbin{2} = -[pbin{2}(2),pbin{2}(1)];
        proj.v = -proj.v;
    elseif numel(pbin{1})==2
        pbin{1} = -[pbin{1}(2),pbin{1}(1)];
        proj.u = -proj.u;
    end
end

% -----------------------------------------------------------------------------
function [proj,sgn] = transform_proj_single (obj, Minv, proj_in)
% Note this function uses matrix Minv which transforms from rlu to
% orthonormal components
proj = proj_in;
R = calculate_transform (obj, Minv);
sgn = round(det(R));    % will be +1 for rotation, -1 for reflection
proj.uoffset(1:3) = (Minv \ R * Minv * (proj.uoffset(1:3)-obj.uoffset_') + obj.uoffset_')';

u_new = (Minv \ R * Minv * proj.u(:))';
v_new = (Minv \ R * Minv * proj.v(:))';
proj.u = u_new;
proj.v = v_new;

% proj.u = (Minv \ R * Minv * proj.u(:))';
% proj.v = (Minv \ R * Minv * proj.v(:))';

if ~isempty(proj.w)
    proj.w = (Minv \ R * Minv * proj.w(:))';
end
