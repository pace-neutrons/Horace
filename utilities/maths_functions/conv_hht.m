function y=conv_hht (x, alf, bet, wid)
% Convolution of two hat functions and a triangle (all normalised)
%
%   >> y=conv_hht (x, fwhh_hat1, fwhh_hat2, fwhh_tri)
%
%   x           Array of x-axis values
%   fwhh_hat1   Full width of first hat function
%   fwhh_hat2   Full width of second hat function
%   fwhh_tri    Width at half-height of a triangle function
%
% Works even if fwhh_hat1=fwhh_hat2=fwhh_tri=0, when gives y=Inf at x=0, and y=0 everywhere else.

% T.G.Perring 20/8/93 - translated to matlab TGP Jan 2013

% Catch special cases of one or more widths being zero
% ----------------------------------------------------
if wid==0       % convolution of two hat functions
    y=conv_hh(x,alf,bet);
    return
elseif bet==0   % convolution of one hat and a triangle
    y=conv_ht(x,alf,wid);
    return
elseif alf==0   % convolution of one hat and a triangle
    y=conv_ht(x,bet,wid);
    return
end

% General case of all widths non-zero
% -----------------------------------
% Sort widths
if abs(alf) < abs(bet)
    a = abs(bet);
    b = abs(alf);
else
    a = abs(alf);
    b = abs(bet);
end
w = abs(wid);

% Set up constants for use in routine
e1=-0.5*(a+b);
e2=-0.5*(a-b);
e3= 0.5*(a-b);
e4= 0.5*(a+b);
edge_norm= a*b*(w^2);
centre_norm= a*(w^2);

% Calculate the convolution
% -------------------------
y=zeros(size(x));
y=conv_hht_internal(y,x,e1,e2,e3,e4,w,edge_norm,centre_norm);
y=conv_hht_internal(y,-x,e1,e2,e3,e4,w,edge_norm,centre_norm);


%--------------------------------------------------------------------------
function y=conv_hht_internal(y,xu,e1,e2,e3,e4,w,edge_norm,centre_norm)

xl=xu-w;

lo1=(xl<e1);
lo2=(xl>=e1)&(xl<e2);
lo3=(xl>=e2)&(xl<e3);
lo4=(xl>=e3)&(xl<e4);

up1=(xu>e1)&(xu<=e2);
up2=(xu>e2)&(xu<=e3);
up3=(xu>e3)&(xu<=e4);
up4=(xu>e4);

ok=lo1&up1;
y(ok) = y(ok) + c_hhtfun_edge (e1, xu(ok), -xl(ok), e1, edge_norm);
ok=lo1&up2;
y(ok) = y(ok) + c_hhtfun_edge (e1, e2, -xl(ok), e1, edge_norm)...
    + c_hhtfun_cent (e2, xu(ok), -xl(ok), centre_norm);
ok=lo1&up3;
y(ok) = y(ok) + c_hhtfun_edge (e1, e2, -xl(ok), e1, edge_norm)...
    + c_hhtfun_cent (e2, e3, -xl(ok), centre_norm)...
    - c_hhtfun_edge (e3, xu(ok), -xl(ok), e4, edge_norm);
ok=lo1&up4;
y(ok) = y(ok) + c_hhtfun_edge (e1, e2, -xl(ok), e1, edge_norm)...
    + c_hhtfun_cent (e2, e3, -xl(ok), centre_norm)...
    - c_hhtfun_edge (e3, e4, -xl(ok), e4, edge_norm);

ok=lo2&up1;
y(ok) = y(ok) + c_hhtfun_edge (xl(ok), xu(ok), -xl(ok), e1, edge_norm);
ok=lo2&up2;
y(ok) = y(ok) + c_hhtfun_edge (xl(ok), e2, -xl(ok), e1, edge_norm)...
    + c_hhtfun_cent (e2, xu(ok), -xl(ok), centre_norm);
ok=lo2&up3;
y(ok) = y(ok) + c_hhtfun_edge (xl(ok), e2, -xl(ok), e1, edge_norm)...
    + c_hhtfun_cent (e2, e3, -xl(ok), centre_norm)...
    - c_hhtfun_edge (e3, xu(ok), -xl(ok), e4, edge_norm);
ok=lo2&up4;
y(ok) = y(ok) + c_hhtfun_edge (xl(ok), e2, -xl(ok), e1, edge_norm)...
    + c_hhtfun_cent (e2, e3, -xl(ok), centre_norm)...
    - c_hhtfun_edge (e3, e4, -xl(ok), e4, edge_norm);

ok=lo3&up2;
y(ok) = y(ok) + c_hhtfun_cent (xl(ok), xu(ok), -xl(ok), centre_norm);
ok=lo3&up3;
y(ok) = y(ok) + c_hhtfun_cent (xl(ok), e3, -xl(ok), centre_norm)...
    - c_hhtfun_edge (e3, xu(ok), -xl(ok), e4, edge_norm);
ok=lo3&up4;
y(ok) = y(ok) + c_hhtfun_cent (xl(ok), e3, -xl(ok), centre_norm)...
    - c_hhtfun_edge (e3, e4, -xl(ok), e4, edge_norm);

ok=lo4&up3;
y(ok) = y(ok) - c_hhtfun_edge (xl(ok), xu(ok), -xl(ok), e4, edge_norm);
ok=lo4&up4;
y(ok) = y(ok) - c_hhtfun_edge (xl(ok), e4, -xl(ok), e4, edge_norm);

%--------------------------------------------------------------------------
function y=c_hhtfun_edge (p, q, bb, const, edge_norm)
abar = p - const;
bbar = p + bb;
y = ( (q-p) .* ( ((q-p).^2)/3 + (q-p).*(abar+bbar)/2 + abar.*bbar ) ) / edge_norm;

%--------------------------------------------------------------------------
function y=c_hhtfun_cent (p, q, bb, centre_norm)
y = ( (q-p) .* ( (q+p)/2 + bb ) ) / centre_norm;
