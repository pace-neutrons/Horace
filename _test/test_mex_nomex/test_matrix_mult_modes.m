function test_matrix_mult_modes(n)
% test various mtimexs_horace modes for non-double values
if nargin == 0
    n=10;
end
a = rand(3,3);
b = rand(3,3,n);

c3mex=mtimesx_horace(a,b,true);
c3nom=mtimesx_horace(a,b,false);
assertElementsAlmostEqual(c3mex,c3nom)

a = rand(3,3,n);
b = rand(3,3);
c3mex=mtimesx_horace(a,b,true);
c3nom=mtimesx_horace(a,b,false);
assertElementsAlmostEqual(c3mex,c3nom)



a=rand(3,3,n);
b=rand(3,3,n);



tic
c3mex=mtimesx_horace(a,b,true);
t0=toc;
tic
c3nom=mtimesx_horace(a,b,false);
t1=toc;
assertElementsAlmostEqual(c3mex,c3nom);

a = single(a);
tic
c3mex=mtimesx_horace(a,b,true);
t0s1=toc;
tic
c3nom=mtimesx_horace(a,b,false);
t1s1=toc;
assertElementsAlmostEqual(c3mex,c3nom,'absolute',1.e-6);

a=rand(3,3,n);
b= single(b);
tic
c3mex=mtimesx_horace(a,b,true);
t0s2=toc;
tic
c3nom=mtimesx_horace(a,b,false);
t1s2=toc;
assertElementsAlmostEqual(c3mex,c3nom,'absolute',1.e-6);


a = single(a);
tic
c3mex=mtimesx_horace(a,b,true);
t0sa=toc;
tic
c3nom=mtimesx_horace(a,b,false);
t1sa=toc;
assertElementsAlmostEqual(c3mex,c3nom);




hc = hor_config;
if hc.log_level >-1
    fprintf( '*** ==== Doube x Double 3x3x%d * 3x3x%d = 3x3x%d Double\n',n,n,n);
    disp(['***    mtimesx mex  Double  time: ',num2str(t0),' sec']);
    disp(['***  mtimesx matlab Double  time: ',num2str(t1),' sec']);
    fprintf( '*** ==== Doube x Single 3x3x%d * 3x3x%d = 3x3x%d Double\n',n,n,n);
    disp(['***   mtimesx mex  Single 1 time: ',num2str(t0s1),' sec']);
    disp(['*** mtimesx matlab Single 1 time: ',num2str(t1s1),' sec']);
    fprintf( '*** ==== Single x Double 3x3x%d * 3x3x%d = 3x3x%d Double\n',n,n,n);
    disp(['***   mtimesx mex  Single 2 time: ',num2str(t0s2),' sec']);
    disp(['*** mtimesx matlab Single 2 time: ',num2str(t1s2),' sec']);
    fprintf( '*** ==== Single x Single 3x3x%d * 3x3x%d = 3x3x%d Single\n',n,n,n);
    disp(['*** mtimesx mex  Single All time: ',num2str(t0sa),' sec']);
    disp(['**mtimesx matlab Single All time: ',num2str(t1sa),' sec']);
    
end
