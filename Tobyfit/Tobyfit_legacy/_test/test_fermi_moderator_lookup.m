
inst1=maps_instrument(50,150,'S');
inst2=maps_instrument(30,200,'S');
inst3=maps_instrument(160,400,'S');
inst4=maps_instrument(200,300,'S');
inst5=maps_instrument(500,600,'S');

c1=inst1.fermi_chopper;
c2=inst2.fermi_chopper;
c3=inst3.fermi_chopper;
c4=inst4.fermi_chopper;
c5=inst5.fermi_chopper;
ctot=[c1,c2,c3,c4,c5];

f1=sampling_table(c1);
f2=sampling_table(c2);
f3=sampling_table(c3);
f4=sampling_table(c4);
f5=sampling_table(c5);

[table,ind]=fermi_lookup_table([c3,c1,c3,c4,c1]);
isequal(table(:,ind),[f3',f1',f3',f4',f1']);

[table,ind]=fermi_lookup_table(c2);

%----------------------------------------------------------------
m1=IX_moderator(10,32,'ikcarp',[11,0,0]);
m2=IX_moderator(10,32,'ikcarp',[22,0,0]);
m3=IX_moderator(10,32,'ikcarp_param',[33,0,0]);
m4=IX_moderator(10,32,'ikcarp',[44,0,0]);

mm0=[m1,m2,m2,m2,m2,m3,m3,m4];
ei0=[100,230,210,230,220,320,310,5];
%[moderator_sort,ei_sort,m,n]=unique_mod_ei(mm0, ei0);

mm=[m2,m3,m3];
ei=[230,100,310];
%[ind,indv]=array_filter_mod_ei(mm,ei,mm0,ei0);


%----------------------------------------------------------------
% Definitive test
%----------------------------------------------------------------
w1=read_sqw('T:\matlab\apps_devel\Tobyfit\sqw_1d.sqw');
ch1=[600*ones(1,93);500*ones(1,93)]; ch1=ch1(:);
ch2=[400*ones(1,93);600*ones(1,93)]; ch2=ch2(:);

ww1=set_sample_and_inst(w1,struct,@maps_instrument,'-efix',ch1,'S');
ww2=set_sample_and_inst(w1,struct,@maps_instrument,'-efix',ch2,'S');

[ei1,x0,xa,x1,thetam,angvel,moderator1,aperture1,chopper1]=chopper_instrument_pars(ww1.header);
[ei2,x0,xa,x1,thetam,angvel,moderator2,aperture2,chopper2]=chopper_instrument_pars(ww2.header);
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

