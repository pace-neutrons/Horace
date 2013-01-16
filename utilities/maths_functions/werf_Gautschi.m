function [wr,wi]=werf(zr,zi)
% Calculate scaled complementary error function woth complex argument
%
%   >> [wr,wi]=werf(zr,zi)
%
%   z1,z2   Real and imaginary parts of complex argument z=zr+i*zi, zi>=0
%           Must be column vectors.
%
%   wr,wi   Real and imaginary parts of complex output w=wr+i*wi
%          where:
%               w(z) = exp(-z^2) erfc(-iz)
%          with:
%               erfc(z) = 2.0/sqrt(pi) * integral(exp(-t^2); t=z->infinity)
%
%             z = z1 + i*z2
%
%           Results are column vectors.
%
%  Note: Only for zi>=0. For lower complex plane use symmetry relations
%
% -----------------------------------------------------------------------
%  Calculates the complex error function as described by Gautschi
% SIAM J.Numer.Anal. 7 p187 (1970) ; see also Flores_Llamas et al
% Nuc.Inst.Meth. A287 p557 (1990). This is the same method that Bill
% David's routine WERF uses, but here is implemented differently.
%  Only for Im(z) .ge. 0.0d0
%
%  Relative error of 1.0d-10 or smaller. This does not apply to the
% real or imaginary parts individually, however. In particular, near
% the real axis (where Re(w(z)) is small c.f. Im(w(z))) tha error in the
% real part is relatively large, and this is what is required in the
% convolution of a Lorentzian with a Gaussian. Calculates for Im(z)=0
% directly, as sometimes need this
%
%  More accurate routine: CERN library routine WWERF (10d-12 - 10d-14)
% but takes at least twice as long to evaluate near the origin, and
% whereas my routine gets faster for larger mod(z) (upto 5 times for
% z tested) WWERF gets no faster. This again loses accuracy near the
% real axis.
%
%  Machine precision routine from NAG routine S15DDF. (c*16) Takes
% about 2.5 times as long as the CERN routine.
%
%   input: z1, z2     real & imag. parts of z
%  output: w1, w2     real & imag. parts of w(z)

% integer j, nc, nu
%       double precision z1, z2, w1, w2, const, rtbexp, x, y, r1, r2,
%      +                 t1, t2, den, ss, h, fac, fmult, s1, s2
const=1.128379167095513;
np=numel(zr);
wr=zeros(np,1);
wi=zeros(np,1);

x=abs(zr);
y=abs(zi);
big=(x>=5.33)|(y>=4.29);
if any(big)
    nok=sum(big);
    r1=zeros(nok,1);
    r2=zeros(nok,1);
    for j=8:-1:0
        t1=(y(big)+(j+1)*r1);
        t2=(x(big)-(j+1)*r2);
        t1_ge_t2=(abs(t1)>=abs(t2));
        if any(t1_ge_t2)
            r1(t1_ge_t2) = (0.5./t1(t1_ge_t2))./(1+(t2(t1_ge_t2)./t1(t1_ge_t2)).^2);
            r2(t1_ge_t2) = r1(t1_ge_t2).*(t2(t1_ge_t2)./t1(t1_ge_t2));
        end
        t2_gt_t1=~(t1_ge_t2);
        if any(t2_gt_t1)
            r2(t2_gt_t1) = (0.5./t2(t2_gt_t1))./(1+(t1(t2_gt_t1)./t2(t2_gt_t1)).^2);
            r1(t2_gt_t1) = r2(t2_gt_t1).*(t1(t2_gt_t1)./t2(t2_gt_t1));
        end
    end
    wr(big)=const*r1;
    wi(big)=const*r2;
end

small=~big;
if any(small)
    ss=(1-y(small)/4.29).*sqrt(1-(x(small)/5.33).^2);
    h =1.6*ss;
    nc=6+round(23*ss);
    nu=9+round(21*ss);
    nu_max=max(nu);
    fac=(2*h).^nc;
    fmult=1./(2*h);
    nok=sum(small);
    r1=zeros(nok,1);
    r2=zeros(nok,1);
    s1=zeros(nok,1);
    s2=zeros(nok,1);
    t1=zeros(nok,1);
    t2=zeros(nok,1);
    den=zeros(nok,1);
    xsmall=x(small);
    ysmall=y(small);
    jj=nu;
    for j=nu_max:-1:0
        active=(jj>=0);
        t1(active)=(ysmall(active)+h(active)+(jj(active)+1).*r1(active));
        t2(active)=(xsmall(active)-(jj(active)+1).*r2(active));
        den(active)=0.5./(t1(active).^2+t2(active).^2);
        r1(active)=den(active).*t1(active);
        r2(active)=den(active).*t2(active);
        iter=(active)&(jj<=nc);
        den(iter)=fac(iter)+s1(iter);
        s1(iter)=r1(iter).*den(iter)-r2(iter).*s2(iter);
        s2(iter)=r2(iter).*den(iter)+r1(iter).*s2(iter);
        fac(iter)=fac(iter).*fmult(iter);
        jj=jj-1;
    end
    wr(small)=const*s1;
    wi(small)=const*s2;
end

yzero=(y==0);
if any(yzero)
    wr(yzero)=exp(-x(yzero).^2);
end

xneg=(x<0);
if any(xneg)
    wi(xneg)=-wi(xneg);
end
