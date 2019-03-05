% Test and time sampling
n = 1e7;

x = [-5,2,2,5];
f = [1,1,4,4];



myPDF = pdf_table(x,f);
bigtic
xsamp = myPDF.rand([n,1]);
bigtoc
disp(' ')

[N,edges] = histcounts(xsamp);
w3 = IX_dataset_1d(edges,N);
dh(w3)
dx=x(end)-x(1); xlim = [x(1)-dx/10,x(end)+dx/10];
lx (xlim); ly([0,1.1*max(N)])
keep_figure
