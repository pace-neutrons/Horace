%% Simple tests
ss=IX_dataset_2d(1:6,100,rand(1,5)',0.3*rand(1,5)','hello','x-axis','theta','counts',1,1);
pp=tofpar(1,5.3,12,6,13,90,200);
uu='thZ';

ss2=repmat(ss,1,3);
ss2(2)=ss2(2)+1.5; ss2(2).y=102;
ss2(3)=ss2(3)+1.5; ss2(3).y=104;

pp2=repmat(pp,1,3);
pp2(2).twotheta=23;
pp2(3).twotheta=33;

uu2{1}='thZ';
uu2{2}='w';
uu2{3}='t';

% These should all work
disp('000')
tt000=tofspectrum(ss ,pp ,uu);
disp('200')
tt200=tofspectrum(ss2,pp ,uu);
disp('220')
tt220=tofspectrum(ss2,pp2,uu);
disp('202')
tt202=tofspectrum(ss2,pp ,uu2);
disp('222')
tt222=tofspectrum(ss2,pp2,uu2);

% These should all fail
disp('020')
tt020=tofspectrum(ss ,pp2,uu);
disp('002')
tt002=tofspectrum(ss ,pp ,uu2);
disp('022')
tt022=tofspectrum(ss ,pp2,uu2);


%% Test with big dataset
xx=10:0.01:30;
nsp=1000;
ss=repmat(IX_dataset_2d,1,nsp);
tic
for i=1:numel(ss), ss(i)=IX_dataset_2d(xx,2*i,rand(numel(xx)-1,1),rand(numel(xx)-1,1),'hello','x-axis','theta','counts',1,1); end
toc

pp=tofpar(1,5.3,12,6,13,90,200);
uu='thZ';

tic
tt=tofspectrum(ss,pp,uu);
toc
