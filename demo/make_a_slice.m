%% horrace projection settings
data_source=[pwd '/fe_demo.sqw'];
%data_source='f:\work\Toby\Horace_sqw\demo\fe_demo.sqw';
proj_100.u=[1,0,0];
proj_100.v=[0,1,0];
proj_100.type='rrr';
proj_100.uoffset=[0,0,0,0];
%% make the cut
profile clear
profile on
w100_3=cut_sqw(data_source,proj_100,[-0.2,0.01,0.2],0.05,[-0.2,0.01,0.2],[0,500],'-nopix');
profile off
profview;
