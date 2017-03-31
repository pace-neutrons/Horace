function test_rand_trunkexp
% Test rand_trunkexp and rand_trunkexp2 give same results

% Case of all x0 in one regime only
n=1000;
single_x0(Inf,n)
single_x0(0.001,n)
single_x0(1,n)

% Case of points across several regimes
n=1e2;
x1=0.001; x2=0.005; x3=1; x4=3; x5=Inf;

tic; X1=rand_truncexp(x1,[1,5*n^2]); toc
tic; X2=rand_truncexp(x2,[1,5*n^2]); toc
tic; X3=rand_truncexp(x3,[1,5*n^2]); toc
tic; X4=rand_truncexp(x4,[1,5*n^2]); toc
tic; X5=rand_truncexp(x5,[1,5*n^2]); toc

tic; 
X1=rand_truncexp(x1,[1,5*n^2]);
X2=rand_truncexp(x2,[1,5*n^2]);
X3=rand_truncexp(x3,[1,5*n^2]);
X4=rand_truncexp(x4,[1,5*n^2]);
X5=rand_truncexp(x5,[1,5*n^2]);
toc

w1=histogram_array(X1);
w2=histogram_array(X2);
w3=histogram_array(X3);
w4=histogram_array(X4);
w5=histogram_array(X5);


x0=[x1*ones(n,5*n),x2*ones(n,5*n),x3*ones(n,5*n),x4*ones(n,5*n),x5*ones(n,5*n)];
ind=randperm(numel(x0));
x0=x0(ind);
xc=x0(:); xr=x0(:)'; x=reshape(x0,[n,25*n]);

tic; XC=rand_truncexp2(xc); toc
tic; XR=rand_truncexp2(xr); toc
tic; X=rand_truncexp2(x); toc


[ww1c,ww2c,ww3c,ww4c,ww5c]=hist_them(XC(:),xc(:));
[ww1r,ww2r,ww3r,ww4r,ww5r]=hist_them(XR(:),xr(:));
[ww1,ww2,ww3,ww4,ww5]=hist_them(X(:),x(:));


acolor r
pl(w1)
acolor r b k g
dh([w1,ww1c,ww1r,ww1])
acolor r
pl(w1)
keep_figure

acolor r b k g
dh([w2,ww2c,ww2r,ww2])
acolor r
pl(w2)
keep_figure

acolor r b k g
dh([w3,ww3c,ww3r,ww3])
acolor r
pl(w3)
keep_figure

acolor r b k g
dh([w4,ww4c,ww4r,ww4])
acolor r
pl(w4)
keep_figure

acolor r b k g
dh([w5,ww5c,ww5r,ww5])
acolor r
pl(w5)
keep_figure





%----------------------------------------------------------------------------
function [ww1,ww2,ww3,ww4,ww5]=hist_them(X,x)
% Get the X values for the different truncation lengths
i1=(x==0.001);
i2=(x==0.005);
i3=(x==1);
i4=(x==3);
i5=(x==Inf);

ww1=histogram_array(X(i1));
ww2=histogram_array(X(i2));
ww3=histogram_array(X(i3));
ww4=histogram_array(X(i4));
ww5=histogram_array(X(i5));


%----------------------------------------------------------------------------
function single_x0(x0,n)
sz1=[1,2*n^2];
sz2=[2*n^2,1];
sz3=[n,2*n];

X = rand_truncexp (x0,sz1);

X1 = rand_truncexp2 (x0*ones(sz1));
X2 = rand_truncexp2 (x0*ones(sz2));
X3 = rand_truncexp2 (x0*ones(sz3));

w=histogram_array(X);
w1=histogram_array(X1);
w2=histogram_array(X2);
w3=histogram_array(X3);

acolor r
dh(w)
acolor k
ph([w1,w2,w3])

title(['x0 = ',num2str(x0)])
keep_figure

