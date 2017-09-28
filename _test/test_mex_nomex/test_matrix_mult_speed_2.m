function [t0_matlab_opt,t1_mex]=test_matrix_mult_speed_2 (n)
if nargin == 0
    n = 100;
end

tol = 2e-12;

a=rand(3,3,n);
b=rand(3,3,n);


% Method 0
% --------
c0=zeros(size(a));

tic
for i=1:3
    for j=1:3
        for k=1:3
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
    disp(['***             Matlab loop time: ',num2str(t0_matlab_opt),' sec']);
    disp(['***       mtimesx mex       time: ',num2str(t1_mex),' sec']);
    disp(['***       mtimesx matlab    time: ',num2str(t1_nomex),' sec']);
    disp(['***       mtimesx matlab op time: ',num2str(t2_nomex),' sec']);    
end



