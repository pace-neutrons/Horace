function w=werf_Gautschi(z)
% Calculate scaled complementary error function with complex argument
%
%   >> w=werf(z)
%
%      w(z) = exp(-z^2) erfc(-iz)
% with:
%      erfc(z) = 2.0/sqrt(pi) * integral(exp(-t^2); t=z->infinity)
%
% Uses algorithm due to Gautschi (reference below).
% Translation of T.G.Perring's Fortran version from c. 1993 (obtained
% from elsewhere or written from the references below I cannot recall).
% Translation by T.G.Perring Jan 2013.
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
np=numel(z);
wr=zeros(np,1);
wi=zeros(np,1);

x=abs(real(z)); x=x(:);     % make column vector
y=abs(imag(z)); y=y(:);     % make column vector
ind=(x>=5.33)|(y>=4.29);
if any(ind(:))
    nind=sum(ind);
    r1=zeros(nind,1);
    r2=zeros(nind,1);
    for j=8:-1:0
        t1=(y(ind)+(j+1)*r1);
        t2=(x(ind)-(j+1)*r2);
        t1_ge_t2=(abs(t1)>=abs(t2));
        if any(t1_ge_t2(:))
            r1(t1_ge_t2) = (0.5./t1(t1_ge_t2))./(1+(t2(t1_ge_t2)./t1(t1_ge_t2)).^2);
            r2(t1_ge_t2) = r1(t1_ge_t2).*(t2(t1_ge_t2)./t1(t1_ge_t2));
        end
        t2_gt_t1=~(t1_ge_t2(:));
        if any(t2_gt_t1)
            r2(t2_gt_t1) = (0.5./t2(t2_gt_t1))./(1+(t1(t2_gt_t1)./t2(t2_gt_t1)).^2);
            r1(t2_gt_t1) = r2(t2_gt_t1).*(t1(t2_gt_t1)./t2(t2_gt_t1));
        end
    end
    wr(ind)=const*r1;
    wi(ind)=const*r2;
end

ind=~ind;
if any(ind(:))
    ss=(1-y(ind)/4.29).*sqrt(1-(x(ind)/5.33).^2);
    h =1.6*ss;
    nc=6+round(23*ss);
    nu=9+round(21*ss);
    nu_max=max(nu);
    fac=(2*h).^nc;
    fmult=1./(2*h);
    nind=sum(ind);
    r1=zeros(nind,1);
    r2=zeros(nind,1);
    s1=zeros(nind,1);
    s2=zeros(nind,1);
    t1=zeros(nind,1);
    t2=zeros(nind,1);
    den=zeros(nind,1);
    xsmall=x(ind);
    ysmall=y(ind);
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
    wr(ind)=const*s1;
    wi(ind)=const*s2;
end

% Special case of real axis: set real component
% *** Is this a good idea? when computing e.g. derivatives, the discontinuity will be apparent
ind=(y==0);
if any(ind(:))
    wr(ind)=exp(-x(ind).^2);
end

% Conjugate for negative x:
ind=(real(z)<0);
if any(ind(:))
    wi(ind)=-wi(ind);
end

% Package as complex number output
w=complex(wr,wi);
sz=size(z);
if numel(sz)~=2 || sz(2)~=1
    w=reshape(w,sz);    % reshape to original input shape
end

% Calculate for z in lower plane
ind=(imag(z)<0);
if any(ind(:))
    w(ind)=2*exp(-z(ind).^2)-conj(w(ind));
end
