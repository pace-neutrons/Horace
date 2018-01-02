%----------------------------------------------------------------
% Test the lookup for a bunch of moderators
%----------------------------------------------------------------
% This tests non-unique moderators and different types, and sorting
m1=IX_moderator(10,32,'ikcarp',[11,0,0]);       % 
m2=IX_moderator(10,32,'ikcarp',[22,0,0]);       % 
m3=IX_moderator(10,32,'ikcarp_param',[0.04,25,200]); %
m4=IX_moderator(10,32,'ikcarp',[22,5,0.3]);     % 
m5=IX_moderator(10,32,'ikcarp',[29,0,0]);       %

mm0=[m2, m2, m2, m1, m2, m3, m3, m5, m4];
ei0=[100,230,210,230,220,120,110,10, 5];

[table,t_av,ind,fwhh]=buffered_sampling_table(mm0,ei0,'nocheck','purge');


% Create reference datasets
% Order of moderators in the table should be:
% (m1, m2, m4, m5, (m3,110), (m3,120))
% ind = [2,2,2,1,2,6,5,4,3]
ei_ref=[0,0,0,0,110,120];
[table_ref,t_av_ref,fwhh_ref]=sampling_table(m1,ei_ref(1));
table_ref=repmat(table_ref,1,6);
t_av_ref=repmat(t_av_ref,1,6);
ind_ref=[2,2,2,1,2,6,5,4,3]';
fwhh_ref=repmat(fwhh_ref,1,6);
[table_ref(:,2),t_av_ref(2),fwhh_ref(2)]=sampling_table(m2,ei_ref(2));
[table_ref(:,3),t_av_ref(3),fwhh_ref(3)]=sampling_table(m4,ei_ref(3));
[table_ref(:,4),t_av_ref(4),fwhh_ref(4)]=sampling_table(m5,ei_ref(4));
[table_ref(:,5),t_av_ref(5),fwhh_ref(5)]=sampling_table(m3,ei_ref(5));
[table_ref(:,6),t_av_ref(6),fwhh_ref(6)]=sampling_table(m3,ei_ref(6));

if ~(isequal(table_ref,table) && isequal(t_av_ref,t_av) &&...
        isequal(fwhh_ref,fwhh) && isequal(ind_ref,ind))
    error('Problem with buffering moderators')
end

% Time creation
tic
[table,t_av,ind,fwhh]=buffered_sampling_table(mm0,ei0);
toc

% Time reading from table
tic
[table,t_av,ind,fwhh]=buffered_sampling_table(mm0,ei0,'nocheck');
toc

% Create a huge lookup table
nmod=100;
moder=repmat(IX_moderator,nmod,1);
for i=1:nmod
    moder(i)=IX_moderator(10,32,'ikcarp',[4+rand,5*(4+rand),0.5*rand]);
end
eiarr=rand(size(moder));

tic
[table,t_av,ind,fwhh]=buffered_sampling_table(moder,eiarr,'purge');
toc

% Now extract 5 from the lookup table - the use of lookup works for moderators
% (about 40 times faster in this instance - and it is still the sorting
% that takes most time
isub=[12,24,36,41,66];
moder_sub=moder(isub);
eiarr_sub=eiarr(isub);

tic
[table_sub,t_av_sub,ind_sub,fwhh_sub]=buffered_sampling_table(moder_sub,eiarr_sub);
toc




%----------------------------------------------------------------
% Test Fermi lookup
%----------------------------------------------------------------
c1=inst1.fermi_chopper;
c2=inst2.fermi_chopper;
c3=inst3.fermi_chopper;
c4=inst4.fermi_chopper;
c5=inst5.fermi_chopper;
ctot=[c1,c2,c3,c4,c5];

%----------------------------------------------------------------
f1=sampling_table(c1);
f2=sampling_table(c2);
f3=sampling_table(c3);
f4=sampling_table(c4);
f5=sampling_table(c5);

[table,ind]=fermi_lookup_table([c3,c1,c3,c4,c1]);
isequal(table(:,ind),[f3',f1',f3',f4',f1']);

[table,ind]=fermi_lookup_table(c2);


%----------------------------------------------------------------
% Definitive test
%----------------------------------------------------------------
w1=read_sqw('sqw_1d.sqw');
ch1=[600*ones(1,93);500*ones(1,93)]; ch1=ch1(:);
ch2=[400*ones(1,93);600*ones(1,93)]; ch2=ch2(:);

ww1=set_sample_and_inst(w1,struct,@maps_instrument_for_tests,'-efix',ch1,'S');
ww2=set_sample_and_inst(w1,struct,@maps_instrument_for_tests,'-efix',ch2,'S');

[ei1,x0,xa,x1,thetam,angvel,moderator1,aperture1,chopper1]=instpars_DGfermi(ww1.header);
[ei2,x0,xa,x1,thetam,angvel,moderator2,aperture2,chopper2]=instpars_DGfermi(ww2.header);
for i=1:numel(moderator1)
    moderator1(i).pulse_model='ikcarp_param';
    moderator1(i).pp=[0.05,25,200];
end
for i=1:numel(moderator2)
    moderator2(i).pulse_model='ikcarp_param';
    moderator2(i).pp=[0.05,25,200];
end

ei1(2:2:end)=400;
ei2(1:2:end)=100;
mlook=moderator_sampling_table({moderator1,moderator2},{ei1',ei2'});
clook=fermi_sampling_table({chopper1,chopper2});

