function area = area_ikcarp (x_in, tauf, taus, R)
% Calculate the integral of Ikeda-Carpenter moderator lineshape.
%
%   >> f = area_ikcarp (x, tauf, taus, R)
%
% Input:
% ------
%   x       Array of times at which to evaluate the integral from 0 to x
%   tauf    Fast decay time (us)
%   taus    Slow decay time (us)
%   R       Weight of storage term
%
% Output:
% -------
%   area    Array of values of the function
%
% Assumes tauf >= 0, taus >= 0, taus >= tauf and 0<=R<=1.
% Limiting cases of tauf=0, taus=0, R=0 or 1 handled correctly.
%
% Problems can arise when 
% (1) tauf and/or taus are extremely small but non-zero.
% (2) R=1 in the short time limit, beause the integral is O(x^4) but the
% routine calculates as the difference of two functions that are O(x^3)).

% T.G.Perring 2011-07-20
%   Based on my Fortran 77 code written in c. 1990

c3=1.6666666666666666667d-01; c4=-1.2500000000000000000d-01; c5=5.0000000000000000000d-02;
c6=-1.3888888888888888889d-02; c7=2.9761904761904761905d-03; c8=-5.2083333333333333333d-04;
c9=7.7160493827160493827d-05; c10=-9.9206349206349206349d-06; c11=1.1273448773448773449d-06;
c12=-1.1482216343327454439d-07; c13=1.0598968932302265636d-08;

area=zeros(size(x_in));
pos=(x_in>=0);
x=x_in(pos);

if tauf ~= 0
    ax = x/tauf;
    fun_ax=zeros(size(x));
    small_ax=(abs(ax)<0.1);
    if any(small_ax(:))
        axs=ax(small_ax);
        fun_ax(small_ax) = c3+axs.*(c4+axs.*(c5+axs.*(c6+axs.*(c7+axs.*(c8+axs.*(c9+axs.*(c10+axs.*(c11+axs.*(c12+axs.*c13)))))))));
    end
    if any(~small_ax(:))
        axb=ax(~small_ax);
        fun_ax(~small_ax) = (1 - exp(-(axb)).*(1+(axb)+0.5*(axb).^2)) ./ (axb.^3);
    end
    if taus ~= 0 && R ~= 0	% must do full monty
        gx=x*(1/tauf - 1/taus);
        fun_gx=zeros(size(gx));
        small_gx=(abs(gx)<0.1);
        if any(small_gx(:))
            gxs=gx(small_gx);
            fun_gx(small_gx) = c3+gxs.*(c4+gxs.*(c5+gxs.*(c6+gxs.*(c7+gxs.*(c8+gxs.*(c9+gxs.*(c10+gxs.*(c11+gxs.*(c12+gxs.*c13)))))))));
        end
        if any(~small_gx(:))
            gxb=gx(~small_gx);
            fun_gx(~small_gx) = (1 - exp(-(gxb)).*(1+(gxb)+0.5*(gxb).^2)) ./ (gxb.^3);
        end
        area(pos) = (ax.^3).*(fun_ax - R*fun_gx.*exp(-(x/taus)));
    else									% integral of chi^2
        area(pos) = (ax.^3).*fun_ax;
    end
else
    if taus ~= 0 && R ~= 0
        area(pos) = (1-R) + R*(1-exp(-(x/taus)));
    else
        area(pos) = 1;
    end
end
