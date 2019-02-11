%% Test sorting
% -------------

% Create some profiles
% --------------------
ang1=-2:0.5:3.5;
ang2=-2:0.5:3.5;
ang3=-2:0.5:2;

prof1 = [0    0.9157    0.7922    0.9595    0.6557    0.0357    0.8491    0.9340    0.6787    0.7577    0.2000   0];
prof2 = [0    0.1712    0.7060    0.0318    0.2769    0.0462    0.0971    0.8235    0.6948    0.3171    0.2000   0];
prof3 = [0    0.9502    0.0344    0.4387    0.3816    0.7655    0.7952    0.1869    0];
prof4 = [0    0.9157    0.7922    0.9595    0.6557    0.0357    0.8491    0.9340    0.6787    0.7577    0.2100   0];
prof5 = [0    0.9257    0.7922    0.9595    0.6557    0.0357    0.8491    0.9340    0.6787    0.7577    0.2000   0];

pr1=IX_divergence_profile(ang1,prof1);
pr2=IX_divergence_profile(ang2,prof2);
pr3=IX_divergence_profile(ang3,prof3);
pr4=IX_divergence_profile(ang1,prof4);
pr5=IX_divergence_profile(ang1,prof5);



% Check sort
prarr1=[pr1,pr2,pr3,pr4,pr5];
[psort1,ix]=sort(prarr1);

if ~isequal(ix',[3,2,1,4,5]) || ~isequal(prarr1(ix),psort1)
    error('Divergence profile sort not working')
end


% Check unique
prarr2=[pr1,pr2,pr3,pr1,pr2,pr1,pr4,pr5];
[psort2,ix,ib]=unique(prarr2);

if ~isequal(ix',[3     5     6     7     8]) ||...
        ~isequal(ib',[3     2     1     3     2     3     4     5]) ||...
        ~isequal(prarr2(ix),psort2) ||...
        ~isequal(prarr2,psort2(ib))
    error('Divergence profile unique not working')
end



%% Test buffered sampling table

% Test that the function is doing its job
[table,ind]=buffered_sampling_table(prarr2,'nocheck');



% Test the speed
% ------------------
% (1) 500 distinct objects. Very slow if checking buffered file
ang1 = -5:0.2:5;
nobj=500;
div = repmat(IX_divergence_profile,nobj,1);
for i=1:nobj
    div(i) = IX_divergence_profile(ang1,[0,rand(1,numel(ang1)-2),0]);
end

% Create from scratch
tic
[table,ind]=buffered_sampling_table(div,'nocheck');
toc

% Create from scratch and write to disk
tic
[table,ind]=buffered_sampling_table(div);
toc

% Now retrieve from disk
tic
[table,ind]=buffered_sampling_table(div);
toc




%% Test generation of lookup tables
% ---------------------------------

ang1=-2:0.1:3.5;
nobj=500;

div = repmat(IX_divergence_profile,nobj,1);

for i=1:nobj
    div(i) = IX_divergence_profile(ang1,[0,rand(1,numel(ang1)-2),0]);
end

npnt=600;
tic
for i=1:nobj
    if i>1
        [A(:,i),val(:,i)]=sampling_table(div(i),[npnt,0]);
    else
        [A0,val0]=sampling_table(div(i),[npnt,0]);
        A=zeros(size(A0,1),nobj);
        val=zeros(size(val0,1),nobj);
        A(:,1)=A0;
        val(:,1)=val0;
    end
end
toc

wdist=IX_dataset_1d(nobj,1);
wcum=IX_dataset_1d(nobj,1);
for i=1:nobj
    wdist(i)=IX_dataset_1d(div(i).angle,div(i).profile);
    tmp=integrate(wdist(i));
    wdist(i)=wdist(i)/tmp.val;
    wcum(i)=IX_dataset_1d(val(:,i),A(:,i));
end
wd=deriv(wcum);


acolor b; dd(wdist(i)); acolor r; pl(wd(i))


% Use new sampling_table function
% --------------------------------
tic
A0=rand(1000,50000);
toc

ii=37;

tic
X=interp1(A(:,ii),val(:,ii),A0,'pchip','extrap');
toc



% Plot results
% ------------
bn=-2.5:0.005:4;
w=IX_dataset_1d(bn,histc(X(:),bn));
tmp=integrate(w);
w=w/tmp.val;

acolor b; dd(wdist(ii)); acolor r; pl(w)


%% -----------------------------------------------------------------------------
% Test of generation of lookup table
% ------------------------------------
% Look at one of the profiles
x1=[-2.0000   -1.4835   -0.9945   -0.2631    0.1665    0.7624    1.0676    1.7093    2.2352    2.5086    3.1338    3.5107];
prof1 = [0    0.9157    0.7922    0.9595    0.6557    0.0357    0.8491    0.9340    0.6787    0.7577    0.2000   0];

w1=IX_dataset_1d(x1,prof1);
tmp=integrate(w1);
w1=w1/tmp.val;


% Old sampling table methods
% --------------------------
% Test the divergence profile lookup table
tab=sampling_table_OLD(x1,prof1,250);

npnt=numel(tab);
wcum=IX_dataset_1d(tab,(0:npnt-1)/(npnt-1));

wd=deriv(wcum);

% Using the linear interpolation scheme
tic
X=rand_lookup(tab,1000,50000);
toc


% Use interp1 method
npnt=numel(tab);
Atab=(0:(npnt-1))/(npnt-1);
tic
A0=rand(1000,50000);
%X=interp1(Atab,tab,A0,'linear','extrap'); % equivalent to rand_lookup
X=interp1(Atab,tab,A0,'pchip','extrap');
toc


% Use new sampling_table function
% --------------------------------
[val,A]=sampling_table2(x1,prof1);
tic
A0=rand(1000,50000);
X=interp1(A,val,A0,'pchip','extrap');
toc


[val,A]=sampling_table2(x1,prof1,301);
tic
A0=rand(1000,50000);
X=interp1(A,val,A0,'linear','extrap');
toc



[xtab,cumpdf]=sampling_table2(x1,prof1);
tic
X=rand_cumpdf2(xtab,cumpdf,[1000,50000]);
toc



obj=IX_divergence_profile(x1,prof1);
[xtab,cumpdf]=sampling_table2(obj);
tic
X=rand_cumpdf2(xtab,cumpdf,[1000,50000]);
toc


xtab=sampling_table(x1,prof1,2000);
tic
X=rand_cumpdf(xtab,[1000,50000]);
toc


obj=IX_divergence_profile(x1,prof1);
xtab=sampling_table(obj);
tic
X=rand_cumpdf(xtab,[1000,50000]);
toc


% Plot results
% ------------
bn=-2.5:0.005:4;
w=IX_dataset_1d(bn,histc(X(:),bn));
tmp=integrate(w);
w=w/tmp.val;

acolor b; dd(w1); acolor r; pl(w)





