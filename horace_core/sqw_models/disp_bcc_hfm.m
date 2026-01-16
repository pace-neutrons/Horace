function [wdisp, sf] = disp_bcc_hfm(qh, qk, ql, par)
% Spin wave dispersion relation for the body centred cubic Heisenberg ferromagnet
%
%   >> [wdisp, sf] = disp_bcc_hfm (qh qk, ql, par)
%
% The dispersion is for the following Hamiltonian:
%           H = -(1/2)Sum(J(i,j) S(i).S(j))
%
% so that positive J favours ferromagnetism and each pair of spins appears only
% once. In addition, a single ion anisotropy is included that opens a gap at the
% magnetic zone centre.
%
% The algorithm works for intersite interactions out to arbitrarily great
% distance, as determined by the length of the vector containing the interaction
% parameters, input argument par, below.
%
% [Reference: 
% For a derivation of the linear spin wave theory dispersion relation and 
% spectral weight see e.g. 
%   "Principles of Neutron Scattering from Condensed Matter"
%   Author: A.T. Boothroyd (Oxford University press, 2020)
% The general expression for the spin wave energies for a Heisenberg ferromagnet
% is given in Eq. 8.56 (page 273). Note the opposite sign convention for the
% exchange constants J]
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l at which to compute the spin wave energies and
%               spectral weights
%
%   par         Parameters [Seff, gap, JS1, JS2, JS3, JS4,...]:
%                 Seff          Intensity scale factor as an effective local
%                              moment spin with value Seff on each atomic site
%                 gap           Gap at zone centre
%                 JS1, JS2,...  First, second etc. neighbour exchange constants.
%                               The exchange constants JS1, JS2,... are each the
%                              product of J and Seff for the first neighbour, 
%                              second, third neighbour etc.
%
%               The length of the parameters vector determines the range of the
%              interactions. The vector can have have an unlimited number of
%              interaction parameters. 
%
%               EXAMPLE
%               If input argument par has length five, that is, par is:
%                 [Seff, gap, JS1, JS2, JS3]
%               then it is assumed that all interactions beyond the 3rd
%              neighbour are zero.
%
%               The first 15 neighbours are 
%                   JS1         JS to [0.5, 0.5, 0.5]   (nearest neighbour)
%                   JS2         JS to [1, 0, 0]         (2nd neighbour)
%                   JS3         JS to [1, 1, 0]         (3rd neighbour)
%                   JS4         JS to [1.5, 0.5, 0.5]   (4th neighbour)
%                   JS5         JS to [1, 1, 1]         (5th neighbour)
%                   JS6         JS to [2, 0, 0]         (6th neighbour)
%                   JS7         JS to [1.5, 1.5, 0.5]   (7th neighbour)
%                   JS8         JS to [2, 1, 0]         (8th neighbour)
%                   JS9         JS to [2, 1, 1]         (9th neighbour)
%                   JS10        JS to [2.5, 0.5, 0.5]   (equal 10th neighbour)
%                   JS11        JS to [1.5, 1.5, 1.5]   (equal 10th neighbour)
%                   JS12        JS to [2, 2, 0]         (12th neighbour)
%                   JS13        JS to [2.5, 1.5, 0.5]   (13th neighbour)
%                   JS14        JS to [3, 0, 0]         (equal 14th neighbour)
%                   JS15        JS to [2, 2, 1]         (equal 14th neighbour)
%
%               Note that if there are inequivalent sites at the same distance
%               then the order is always decreasing x, followed by decreasing y.
%
% Output:
% -------
%   wdisp       Cell array containing a single array with the spin wave energies
%              at the array of points defined by qh, qk, ql
%
%   sf          Cell array containing a single array with the corresponding
%              spectral weights, Seff/2 (i.e. par(1)/2)


persistent rho

Seff = par(1);
gap = par(2);
JS = par(3:end);
npar = numel(JS);

if npar > size(rho,1)
    % Populate rho with the positions of unique nearest neighbour locations in
    % order of increasing separation. Initialise with the first 15 distinct
    % nearest neighbours
    d_upper_bound = d_upper_bound_bcc (max(npar,15));
    rho = bcc_atom_sites (d_upper_bound);
end

% Accumulate spin wave energies
w = gap*ones(size(qh));
for i = 1:npar
    if JS(i)~=0
        w = w + JS(i) * fdisp(qh, qk, ql, rho(i,:));
    end
end

% Set output arguments
wdisp{1} = w;
sf{1} = (Seff/2)*ones(size(w));


%-------------------------------------------------------------------------------
function d_upper_bound = d_upper_bound_bcc (N)
% Return an upper bound for the distance of the Nth neighbour interaction for
% a body-centred cubic lattice, expressed in units of the cube side.
%
% The upper bound returned is:
%       d_upper_bound = (18*N/pi)^(1/3)         ....(1)
%
% Explanation:
% - Volume of a sphere radius d (in uits of cube side) is: V = (4/3)*pi*(d^3)
% - Volume of a cube: 1
% - Each cube contains 2 sites so the estimated number of sites in the sphere
%   is: 
%       N(estimated) = 2*V = (8/3)*pi*(d^3)     ....(2)
%
%     Note: this can be an underestimate or overestimate, due to whether or
%     not sites are included in cubes that are intersected by by the sphere
%     surface. As d gets larger, the relative error gets smaller.
%
% - For the general atomic site (x,y,z) (x~=y~=z~=x) there are 48 symmetry
%   equivalent sites. The number of *distinct* nearest neighbours can be
%   estimated as (1/48) of the estimated number of sites above i.e.
%
%       N(distinct,estimated) = (1/18)*pi*d^3   ....(3)
%
%     In fact, there are many atomic sites with fewer than 48 symmetry related 
%     positions: [x,x,0], [x,x,x], [x,y,0], [x,x,z], with respectively 6, 12, 8,
%     24, 24 equivalent positions. Consequently, estimating the number of
%     distinct sites by dividing by 48 results in an *underestimate* of the true
%     number of distinct sites, N.
%     It turns out that this underestimate always more than compensates
%     for the error of the number sites enclosed within the sphere, equation (2)
%     (see numerical results below). Therefore equation (3) becomes:
%   
%       N > (1/18)*pi*d^3   ==>  d < (18*N/pi)^(1/3)
%
%     and therefore equation (1) gives an upper bound for d.
%
% Numerical results:
% ------------------
% - min (d_upper_bound - d) = 0.9234  
%   (for the first neighbour:  d_upper_bound = 1.7894, d = sqrt(3)/2 = 0.8660)
%
% - max (d_upper_bound - d) = 1.4828
%   (for the 52nd neighbour: d_upper_bound = 6.6790, d = 5.1962)
%
% The above has been numerically tested out to the 1426481st neighbour, which
% has d = 200. Numerically it is seen that (d_upper_bound - d) 
% asymptotically approaches 1.434, with the fluctuations around this value
% getting ever smaller. This is expected as the number of cubes intersecting the
% sphere surface gets smaller as a proportion of the total number of cubes 
% inside the volume of the sphere.

d_upper_bound = (18*N/pi)^(1/3);


%-------------------------------------------------------------------------------
function [rho, dist] = bcc_atom_sites (rmax)
% Get distances to neighbouring atoms for the bcc lattice in a sphere of radius rmax.
% Recall bcc lattice has side length a, with sites at (0,0,0) and (0.5,0.5,0.5)
%
% Input
% -----
%   rmax    Maximum distance from origin in units of the cube side length
%
% Output:
% -------
%   rho     Array of unique sites size [npar,3], where npar is the number of
%           unique sites within or on the surface of the sphere radius rmax).
%           For example, if rmax = 2, rho is returned as:
%                   [0.5, 0.5, 0.5; ...   % nearest neighbour
%                    1,   0,   0;   ...   % 2nd neighbour
%                    1,   1,   0;   ...   % 3rd neighbour
%                    1.5, 0.5, 0.5; ...   % 4th neighbour
%                    1,   1,   1;   ...   % 5th neighbour
%                    2,   0,   0]         % 6th neighbour
%
%           The sites are sorted in order of increasing distance from the
%           origin, and for the ith site has rho(i,1) >= rho(i,2) >=rho(i,3).
%           If two or more inequivalent sites have the same distance from the
%           origin, then the those sites are ordered by decreasing rho(:,1), and
%           if the rho(:,1) are the same, by decreasing rho(:,2).
%
%   dist    Column vector of distances from the origin, length npar, where npar
%           is the number of unique sites within or on the surface of the sphere
%           radius rmax).

small = 1e-10;

R = ceil(rmax);     % round to closest larger integer

% Fill an array with the cube corners within or on the surface of an irreducible
% repeat volume of the cubic lattice. The repeat volume chosen here is the 3D
% wedge defined by rmax >= x >= y >= z.
% The number of points for each value of x is:
%   x = 0   npnt = 1
%   x = 1   npnt = 3    (2 + 1)
%   x = 2   npnt = 6    (3 + 2 + 1)
%   x = 3   npnt = 10   (4 + 3 + 2 + 1)
%       :
%   x = R   npnt = (R+1)*(R+2)/2    ((R+1) + R + (R-1) + ... 2 + 1)

N_vertices = ((R+1)*(R+2)*(R+3))/6;     % total number of vertices out to R
x = zeros(N_vertices,1);
y = zeros(N_vertices,1);
z = zeros(N_vertices,1);

% Loop over x,y,z, filling site positions as multiples of 1/2 (this will allow
% the body centres to be appended later on as being at integer coordinates, thus
% avoiding any rounding errors).
i = 0;
for ix = 0:2:2*R
    for iy = 0:2:ix
        for iz = 0:2:iy
            i = i + 1;
            x(i) = ix;
            y(i) = iy;
            z(i) = iz;
        end
    end
end

% Now append the positions of cube centres (i.e. the body centred sites).
% The positions are the same as the cube corners, except shifted by
% [1/2, 1/2, 1/2]. That is, in our unit of measure being units of 0.5, shifted
% by [1,1,1].
% The number of points for each value of x is 
%   x = 1/2     npnt = 1
%   x = 3/2     npnt = 3    (2 + 1)
%   x = 5/2     npnt = 6    (3 + 2 + 1)
%   x = 7/2     npnt = 10   (4 + 3 + 2 + 1)
%       :
%   x = R-1/2   npnt = R*(R+1)/2  (R + (R-1) + (r-2) + ... + 2 +1)

N_centres = (R*(R+1)*(R+2))/6;      % total number of cube centres out to R
x = [x; x(1:N_centres) + 1];
y = [y; y(1:N_centres) + 1];
z = [z; z(1:N_centres) + 1];

% Distances from origin
dsqr = x.^2 + y.^2 + z.^2;

% Get sites within or on the surface of a sphere radius rmax (exluding origin)
% - Exclude the site at the origin i.e. dsqr==0
% - Add a tiny tolerance in case rmax is not an integer
ok = (dsqr>0) & dsqr<=4*(rmax^2 + small);   % the 4 arises as x,y,z in multiples of 0.5
dsqr = dsqr(ok);
x = x(ok);
y = y(ok);
z = z(ok);

% Sort into order of increasing distance from the origin, ensuring that x>y>z
% in the case when there are inequivalent sites at the same distance from the
% origin.
dsqr_rho = sortrows([dsqr, x, y, z],{'ascend','descend','descend','descend'});

rho = dsqr_rho(:,2:4)/2;        % divide by 2 to get in units of cube side
dist = sqrt(dsqr_rho(:,1))/2;   % ditto


%-------------------------------------------------------------------------------
function w = fdisp (qh, qk, ql, r)
% Return the contribution from symmetry equivalent sites to cubic Heisenberg ferromagnet.
% In more detail: returns
%
%       w = M - Sum({r"}, exp(2*pi*i*(hx"+ky"+lz")) )
%
%   where M   is the number of atomic sites symmetry equivalent to r = [x,y,z]
%        {r"} is the set of position vectors of those symmetry equivalent sites
%       h,k,l give a point in the cubic reciprocal point q = ha* + kb* + lc*
%
%   e.g. if r = [1,0,0], then 
%         M = 6
%        {r"} = {[1,0,0], [0,1,0], [0,-1,0], [0,0,1], [0,0,-1]}
%
% There are six different cases of site symmetry
%   [x 0 0]     M = 6
%   [x x 0]     M = 12
%   [x x x]     M = 8
%   [x y 0]     M = 24
%   [x x z]     M = 24
%   [x y z]     M = 48
%
% where x>0, y>0, y>0 and x~=y, y~=z, z~=x
%
%
% Input:
% ------
%   qh, qk, ql  Arrays giving h,k,l for a set of wavevectors in reciprocal space
%               of the conventional cubic lattice for simple cubic (sc), bcc or
%               fcc crystals. The arrays all must have the same size.
%   r           Vector of an atomic position [x,y,z]
%
% Output:
% -------
%   w           M - Sum({r"}, exp(2*pi*i*(hx"+ky"+lz")) ) defined above


isNonZero = (r~=0);
numNonZero = sum(isNonZero);
ind = find(isNonZero);
if numNonZero == 1
    w = f_x00 (qh, qk, ql, r(ind(1)));
elseif numNonZero == 2
    if r(ind(1)) == r(ind(2))
        w = f_xx0 (qh, qk, ql, r(ind(1)));
    else
        w = f_xy0 (qh, qk, ql, r(ind(1)), r(ind(2)));
    end
elseif numNonZero == 3
    if r(ind(1)) == r(ind(2)) && r(ind(2)) == r(ind(3)) % all are the same
        w = f_xxx (qh, qk, ql, r(ind(1)));
    elseif r(ind(1)) ~= r(ind(2)) && r(ind(2)) ~= r(ind(3)) ...
            && r(ind(3)) ~= r(ind(1))                   % all are different
        w = f_xyz (qh, qk, ql, r(ind(1)), r(ind(2)), r(ind(3)));
    else    % two are the same, one is different
        if r(ind(1)) == r(ind(2))       % x==y~=z
            w = f_xxy (qh, qk, ql, r(ind(2)), r(ind(3)));
        elseif r(ind(2)) == r(ind(3))   % x~=y==z
            w = f_xxy (qh, qk, ql, r(ind(3)), r(ind(1)));
        elseif r(ind(3)) == r(ind(1))   % y~=z==x
            w = f_xxy (qh, qk, ql, r(ind(1)), r(ind(2)));
        end
    end
end

%-------------------------------------------------------------------------------
function w = f_x00 (qh, qk, ql, x)
% Contribution from interactions along [x,0,0] in real space
% Accounts for the 6-fold degeneracy of symmetry equivalent sites
w = 4 * (sin((pi*x)*qh).^2 + sin((pi*x)*qk).^2 + sin((pi*x)*ql).^2);

%-------------------------------------------------------------------------------
function w = f_xx0 (qh, qk, ql, x)
% Contribution from interactions along [x,x,0] in real space
% Accounts for the 12-fold degeneracy of symmetry equivalent sites
cos_xh = cos((2*pi*x)*qh);
cos_xk = cos((2*pi*x)*qk);
cos_xl = cos((2*pi*x)*ql);
w = 4 * (3 - cos_xh.*cos_xk - cos_xk.*cos_xl - cos_xl.*cos_xh);

%-------------------------------------------------------------------------------
function w = f_xxx (qh, qk, ql, x)
% Contribution from interactions along [x,x,x] in real space
% Accounts for the 8-fold degeneracy of symmetry equivalent sites
w = 8 * (1 - cos((2*pi*x)*qh).*cos((2*pi*x)*qk).*cos((2*pi*x)*ql));

%-------------------------------------------------------------------------------
function w = f_xy0 (qh, qk, ql, x, y)
% Contribution from interactions along [x,y,0] (x~=y) in real space
% Accounts for the 24-fold degeneracy of symmetry equivalent sites
cos_xh = cos((2*pi*x)*qh);
cos_xk = cos((2*pi*x)*qk);
cos_xl = cos((2*pi*x)*ql);
cos_yh = cos((2*pi*y)*qh);
cos_yk = cos((2*pi*y)*qk);
cos_yl = cos((2*pi*y)*ql);
w = 4 * (6 ...
    - cos_xh.*cos_yk - cos_yh.*cos_xk...
    - cos_xk.*cos_yl - cos_yk.*cos_xl...
    - cos_xl.*cos_yh - cos_yl.*cos_xh);

%-------------------------------------------------------------------------------
function w = f_xxy (qh, qk, ql, x, y)
% Contribution from interactions along [x,x,y] (x~=y) in real space
% Accounts for the 24-fold degeneracy of symmetry equivalent sites
cos_xh = cos((2*pi*x)*qh);
cos_xk = cos((2*pi*x)*qk);
cos_xl = cos((2*pi*x)*ql);
w = 8 * (3 ...
    - cos_xh.*cos_xk.*cos((2*pi*y)*ql)...
    - cos_xk.*cos_xl.*cos((2*pi*y)*qh)...
    - cos_xl.*cos_xh.*cos((2*pi*y)*qk));

%-------------------------------------------------------------------------------
function w = f_xyz (qh, qk, ql, x, y, z)
% Contribution from interactions along [x,y,z] (x,y,z all different) in real space
% Accounts for the 48-fold degeneracy of symmetry equivalent sites
cos_xh = cos((2*pi*x)*qh);
cos_xk = cos((2*pi*x)*qk);
cos_xl = cos((2*pi*x)*ql);
cos_yh = cos((2*pi*y)*qh);
cos_yk = cos((2*pi*y)*qk);
cos_yl = cos((2*pi*y)*ql);
cos_zh = cos((2*pi*z)*qh);
cos_zk = cos((2*pi*z)*qk);
cos_zl = cos((2*pi*z)*ql);
w = 8 * (6 ...
    - cos_xh.*cos_yk.*cos_zl...
    - cos_yh.*cos_zk.*cos_xl...
    - cos_zh.*cos_xk.*cos_yl...
    - cos_xh.*cos_zk.*cos_yl...
    - cos_yh.*cos_xk.*cos_zl...
    - cos_zh.*cos_yk.*cos_xl);
