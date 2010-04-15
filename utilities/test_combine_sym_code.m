%Some tests to ensure the code is doing what we think it should be (for
%debug purposes)

data_source='/sandata/sqs43493/MnSi/March2010/MnSi_300K_80meV.sqw';
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.uoffset=[0,0,0,0]; proj.type='rrr';
pos=[-1,0,2];
step=0.05;
outfile='/sandata/sqs43493/MnSi/March2010/test_80meV_sym.sqw';
erange=[0,0,72];

%wout=combine_equiv_basic(data_source,proj,pos,step,erange,outfile);
%wout=combine_equiv_keyword(data_source,proj,pos,step,erange,outfile,'-cyclic');
wout=combine_equiv_keyword(data_source,proj,pos,step,erange,outfile,'-cycwithneg');
% zonelist={[0,2,1];[2,0,-1];[0,-2,-1]};
% wout=combine_equiv_list(data_source,proj,pos,step,erange,outfile,zonelist);

%Compare the output with what we had before:
symdata1='/sandata/sqs43493/MnSi/March2010/test_80meV_sym.sqw';
symdata2='/data/home/sqs43493/MnSi/March2010/Symmetrised_data/Ei80_T300_fulldata_m102_new2.sqw';


%Take a 1d cut:
testcut1=cut_sqw(symdata1,proj,[-1.1,-0.9],[-0.1,0.1],[1.9,2.1],[0,0,72]);
testcut2=cut_unique(symdata2,proj,[-1.1,-0.9],[-0.1,0.1],[1.9,2.1],[0,0,72]);

acolor red
plot(testcut1);
acolor blue
pm(testcut2);
pe(testcut2);
ly 0 1

%We (finally) get the same answer as we had before, which is good!

%==========================================================================
%Run some further quick tests to ensure that we are auto-generating the
%correct lists:
wout=combine_equivalent_zones(data_source,proj,pos,step,erange,outfile,'-ab');
