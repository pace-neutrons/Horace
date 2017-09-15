function [c0,c1,c2,c3,c4]=test_matrix_mult_speed (n)
% Turns out that method 1 is 2x faster than method 2
% Method 0 is
if nargin == 0
    n=10;
end

a=rand(n,3,3);
b=rand(n,3,3);


% Method 0
% --------
c0=zeros(size(a));

tic
for i=1:3
    for j=1:3
        for k=1:3
            c0(:,i,j) = c0(:,i,j) + a(:,i,k).*b(:,k,j);
        end
    end
end
t0=toc;


% Method 1
% --------
c1=zeros(size(a));

tic
c1(:,1,1)=a(:,1,1).*b(:,1,1) + a(:,1,2).*b(:,2,1) + a(:,1,3).*b(:,3,1);
c1(:,1,2)=a(:,1,1).*b(:,1,2) + a(:,1,2).*b(:,2,2) + a(:,1,3).*b(:,3,2);
c1(:,1,3)=a(:,1,1).*b(:,1,3) + a(:,1,2).*b(:,2,3) + a(:,1,3).*b(:,3,3);

c1(:,2,1)=a(:,2,1).*b(:,1,1) + a(:,2,2).*b(:,2,1) + a(:,2,3).*b(:,3,1);
c1(:,2,2)=a(:,2,1).*b(:,1,2) + a(:,2,2).*b(:,2,2) + a(:,2,3).*b(:,3,2);
c1(:,2,3)=a(:,2,1).*b(:,1,3) + a(:,2,2).*b(:,2,3) + a(:,2,3).*b(:,3,3);

c1(:,3,1)=a(:,3,1).*b(:,1,1) + a(:,3,2).*b(:,2,1) + a(:,3,3).*b(:,3,1);
c1(:,3,2)=a(:,3,1).*b(:,1,2) + a(:,3,2).*b(:,2,2) + a(:,3,3).*b(:,3,2);
c1(:,3,3)=a(:,3,1).*b(:,1,3) + a(:,3,2).*b(:,2,3) + a(:,3,3).*b(:,3,3);
t1=toc;


% Method 2
% --------
a=permute(a,[2,3,1]);
b=permute(b,[2,3,1]);

c2=zeros(size(a));

tic
c2(1,1,:)=a(1,1,:).*b(1,1,:) + a(1,2,:).*b(2,1,:) + a(1,3,:).*b(3,1,:);
c2(1,2,:)=a(1,1,:).*b(1,2,:) + a(1,2,:).*b(2,2,:) + a(1,3,:).*b(3,2,:);
c2(1,3,:)=a(1,1,:).*b(1,3,:) + a(1,2,:).*b(2,3,:) + a(1,3,:).*b(3,3,:);

c2(2,1,:)=a(2,1,:).*b(1,1,:) + a(2,2,:).*b(2,1,:) + a(2,3,:).*b(3,1,:);
c2(2,2,:)=a(2,1,:).*b(1,2,:) + a(2,2,:).*b(2,2,:) + a(2,3,:).*b(3,2,:);
c2(2,3,:)=a(2,1,:).*b(1,3,:) + a(2,2,:).*b(2,3,:) + a(2,3,:).*b(3,3,:);

c2(3,1,:)=a(3,1,:).*b(1,1,:) + a(3,2,:).*b(2,1,:) + a(3,3,:).*b(3,1,:);
c2(3,2,:)=a(3,1,:).*b(1,2,:) + a(3,2,:).*b(2,2,:) + a(3,3,:).*b(3,2,:);
c2(3,3,:)=a(3,1,:).*b(1,3,:) + a(3,2,:).*b(2,3,:) + a(3,3,:).*b(3,3,:);
t2=toc;

c2=permute(c2,[3,1,2]);


% Method 3
% --------
tic
c3mex=mtimesx_horace(a,b,true);
t3_mtimes_mex=toc;
tic
c3nom = mtimesx_horace(a,b,false);
t3_mtimes_nomex = toc;
assertElementsAlmostEqual(c3mex,c3nom);

c3=permute(c3mex,[3,1,2]);


% Method 3
% --------
tic
c4mex=mtimesx_horace(a,b,true);
t4_mtimes_mex=toc;
tic
c4nm = mtimesx_horace(a,b,false);
t4_mtimes_nomex=toc;
assertElementsAlmostEqual(c4mex,c4nm);

c4=permute(c4mex,[3,1,2]);
hc = hor_config;
if hc.log_level >-1
    disp(['***             Matlab loop time: ',num2str(t0),' sec']);
    disp(['*** Matlab harcoded mult LI time: ',num2str(t1),' sec']);
    disp(['*** Matlab harcoded mult UI time: ',num2str(t2),' sec']);
    disp(['***       mtimesx mex       time: ',num2str(t3_mtimes_mex),' sec']);
    disp(['***       mtimesx matlab    time: ',num2str(t3_mtimes_nomex),' sec']);
    disp(['***       mtimesx mex  R2   time: ',num2str(t4_mtimes_mex),' sec']);
    disp(['***       mtimesx matlab R2 time: ',num2str(t4_mtimes_nomex),' sec']);
end
