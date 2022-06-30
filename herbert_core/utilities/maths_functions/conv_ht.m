function y=conv_ht (x, fwhh_hat, fwhh_tri)
% Convolution of normalised hat function and normalised triangle function
%
%   >> y=conv_ht (x, fwhh_hat, fwhh_tri)
%
%   x       Array of x-axis values
%   fwhh_hat    Full width of hat function
%   fwhh_tri    Width at half-height of a triangle function
%
% Works even if fwhh_hat=fwhh_tri=0, when gives y=Inf at x=0, and y=0 everywhere else.

% T.G.Perring 20/8/93 - translated to matlab TGP Jan 2013

w_hat = abs(fwhh_hat);
w_tri = abs(fwhh_tri);
y = zeros(size(x));

if w_hat~=0 && w_tri~=0 		% general case
    xl = x - w_tri;
    p = max(xl,-w_hat/2);
    q = min(x, w_hat/2);
    ok=(p<q);
    y(ok) = (q(ok)-p(ok)).*( 0.5*(q(ok)+p(ok)) - xl(ok) )/(w_hat*w_tri^2);

    xl = -x - w_tri;
    p = max(xl,-w_hat/2);
    q = min(-x, w_hat/2);
    ok=(p<q);
    y(ok) = y(ok) + (q(ok)-p(ok)).*( 0.5*(q(ok)+p(ok)) - xl(ok) )/(w_hat*w_tri^2);
    
elseif w_hat~=0 && w_tri==0     % hat function
    ok=(abs(x)<=w_hat/2);
    if any(ok(:))
        y(ok)=1/w_hat;
    end
    
elseif w_hat==0 && w_tri~=0     % triangle function
    ok=(abs(x)<=w_tri);
    if any(ok(:))
        y(ok) = (w_tri - abs(x(ok)))/(w_tri*w_tri);
    end
    
else							% delta function
    y(x==0)=Inf;
end
