% =======================================================
% Data against which to compare:
% =======================================================
fe_loc='t:\experiments\fe\13march2007\';

% Read in 110 data:
% --------------
w110_1_p2=readgrid([fe_loc,'iron787cut_1x0_p2']);

plot(w110_1_p2)
lx -2 3; ly 0 450; lz 0 0.4

% (100) data:
% --------------
w100_qh2=readgrid([fe_loc,'iron787cut_100_qh2_p2']);

plot(w100_qh2)
lx -2 3; ly 0 450; lz 0 0.4


d2a_ref=cut_sqe('f:/fe/fe_787.sqe',[1.8,2.2],[-2,0.05,2],[-0.2,0.2],[2.5,5,347.5]);


% =======================================================
% Compare with (100) data
data_source = 'F:\fe_newformat\fe.sqw';

proj.u=[1,0,0];
proj.v=[0,1,0];
proj.type='rrr';
proj.uoffset=[0,0,0,0]';

din = cut_sqw (data_source, proj, [3.8,4.2], [-3.15,0.05,Inf], [-0.2,0.2]);

din = cut_sqw (data_source, proj, [0.9,1.1], [-2,0.05,2], [-0.1,0.1],[0,0,400]);

d2a = cut_sqw (data_source, proj, [1.8,2.2], [-2,0.05,2], [-0.2,0.2],[2.5,5,347.5]);

d1a = cut_sqw (data_source, proj, [1.8,2.2], [-2,0.05,2], [-0.2,0.2],[225,250]);

d0a = cut_sqw (data_source, proj, [1.8,2.2], [-0.2,0.2], [-0.2,0.2],[225,250]);

% =======================================================
% Compare with (110) data
data_source = 'E:\fe\fe787\fe.sqw';

proj.u=[1,1,0];
proj.v=[-1,1,0];
proj.type='rrr';
proj.uoffset=[0,0,0,0]';

d2_110a = cut_sqw (data_source, proj, [0.8,1.2], [-2,0.05,3], [-0.2,0.2], [0,0,450]);

d1_110a = cut_sqw (data_source, proj, [0.8,1.2], [-2,0.05,2], [-0.2,0.2], [225,250]);

% =======================================================
% For test zero dimensional cut
%-------------------------------------
data_source = 'E:\fe\fe787\fe.sqw';

proj.u=[1,1,0];
proj.v=[-1,1,0];
proj.type='rrr';
proj.uoffset=[0,0,0,0]';

d0 = cut_sqw (data_source, proj, [0.8,1.2], [-0.2,0.2], [-0.2,0.2], [225,250]);


% =======================================================
% For testing cascades of cuts
%-------------------------------
data_source = 'E:\fe\fe787\fe.sqw';
proj.u=[1,1,0];
proj.v=[-1,1,0];
proj.type='rrr';
proj.uoffset=[0,0,0,0]';

d2_110a = cut_sqw (data_source, proj, [0.8,1.2], [-2,0.05,2], [-0.2,0.2], [0,0,200], '-pix', 'c:\temp\d2_110a.sqw');

d2_110b_from_source = cut_sqw (data_source, proj, [0.9,1.1], [-1.5,0.05,1.5], [-0.1,0.1], [25,0,175], '-pix');

d2_110b_from_file = cut_sqw ('c:\temp\d2_110a.sqw', proj, [0.9,1.1], [-1.5,0.05,1.5], [-0.1,0.1], [25,0,175], '-pix');

d2_110b_from_cut = cut_sqw (d2_110a, proj, [0.9,1.1], [-1.5,0.05,1.5], [-0.1,0.1], [25,0,175], '-pix');


% For testing cascades of cuts:
%-------------------------------
% Create a reference 1D cut
data_source = 'E:\fe\fe787\fe.sqw';
proj.u=[1,1,0];
proj.v=[-1,1,0];
proj.type='rrr';
proj.uoffset=[0,0,0,0]';

d1_110a_source = cut_sqw (data_source, proj, [0.9,1.1], [-1.5,0.05,1.5], [-0.1,0.1], [225,250]);

% make a 3D dataset that will contain the 1D cut
data_source = 'E:\fe\fe787\fe.sqw';
proj.u=[1,0,0];
proj.v=[0,1,0];
proj.type='rrr';
proj.uoffset=[0.5,0.5,0.5,0]';

cut_sqw (data_source, proj, [-2.5,0.05,2.5], [-2.5,0.05,2.5], [-1,1], [200,0,300], 'c:\temp\d3.sqw');

% Take the original cut we want from the 3D dataset
proj.u=[1,1,0];
proj.v=[-1,1,0];
proj.type='rrr';
proj.uoffset=[0,0,0,0]';

d1_110a_file = cut_sqw ('c:\temp\d3.sqw', proj, [0.9,1.1], [-1.5,0.05,1.5], [-0.1,0.1], [225,250]);



