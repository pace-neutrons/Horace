function [t0_matlab_opt,t1_mex]=test_matrix_mult_speed_3 (n)
if nargin == 0
    n = 100;
end

tol = 2e-12;

a=rand(4,6,n);
b=rand(6,11,n);


% Method 0
% --------
c0=zeros(4,11,n);

tic
for i=1:4
    for j=1:11
        for k=1:6
            c0(i,j,:) = c0(i,j,:) + a(i,k,:).*b(k,j,:);
        end
    end
end
t0_matlab_opt=toc;


% Method 1
% --------
tic
c3mex=mtimesx_horace(a,b,true);
t1_mex=toc;
tic
c3nom=mtimesx_horace(a,b,false);
t1_nomex = toc;
assertElementsAlmostEqual(c3mex,c3nom);
tic
c3nom=mtimesx_horace(a,'N',b,false);
t2_nomex = toc;
assertElementsAlmostEqual(c3mex,c3nom);


if any(abs(c0(:)-c3mex(:))>tol)
    error('Not the same!')
end
hc = hor_config;
if hc.log_level >-1
 fprintf( '*** ====  4x6x%d * 6x11x%d = 4x11x%d\n',n,n,n);    
    disp(['***             Matlab loop time: ',num2str(t0_matlab_opt),' sec']);
    disp(['***       mtimesx mex       time: ',num2str(t1_mex),' sec']);
    disp(['***       mtimesx matlab    time: ',num2str(t1_nomex),' sec']);
    disp(['***       mtimesx matlab op time: ',num2str(t2_nomex),' sec']);
end



a=rand(4,11,n);
b=rand(11,1,n);


% Method 0
% --------
c0=zeros(4,1,n);

tic
for i=1:4
    for j=1:1
        for k=1:11
            c0(i,j,:) = c0(i,j,:) + a(i,k,:).*b(k,j,:);
        end
    end
end
t0_matlab_opt=toc;


% Method 1
% --------
tic
c3mex=mtimesx_horace(a,b,true);
t1_mex=toc;
tic
c3nom=mtimesx_horace(a,b,false);
t1_nomex = toc;
assertElementsAlmostEqual(c3mex,c3nom);
tic
c3nom=mtimesx_horace(a,'N',b,false);
t2_nomex = toc;
assertElementsAlmostEqual(c3mex,c3nom);


if any(abs(c0(:)-c3mex(:))>tol)
    error('Not the same!')
end

if hc.log_level >-1
 fprintf( '*** ====  4x11x%d * 11x1x%d = 4x1x%d\n',n,n,n);
    disp(['***             Matlab loop time: ',num2str(t0_matlab_opt),' sec']);
    disp(['***       mtimesx mex       time: ',num2str(t1_mex),' sec']);
    disp(['***       mtimesx matlab    time: ',num2str(t1_nomex),' sec']);
    disp(['***       mtimesx matlab op time: ',num2str(t2_nomex),' sec']);
end


