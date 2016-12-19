% test v2.0.1 against trunk, May 2010.

% Create sqw files from demo script first.
%indir='c:\temp\horace_demo\';
indir=fileparts(which('demo_script'));
data_source=[indir '/fe_demo.sqw'];        % output sqw file


% Some basic cuts
% ----------------------------
% Set up a structure which defines the axes for cutting
proj_100.u = [1,0,0];
proj_100.v = [0,1,0];
proj_100.type = 'rrr';
proj_100.uoffset = [0,0,0,0];

% 1D cut:
w100_1 = cut_sqw(data_source,proj_100,[-0.2,0.2],0.05,[-0.2,0.2],[60,70]);
plot(w100_1)

% 2D cut
w100_2 = cut_sqw(data_source,proj_100,[-0.2,0.2],0.05,[-0.2,0.2],[0,0,500]);
plot(w100_2)


% Take cuts along peculiar directions
% -------------------------------------
proj_odd.u = [1,0.1,0];
proj_odd.v = [0,1,0.1];
proj_odd.type = 'rrr';
proj_odd.uoffset = [0.3,0.1,0.4,0];

wodd_1 = cut_sqw(data_source,proj_odd,[0.2,0.4],0.05,[-0.5,-0.3],[60,70]);
plot(wodd_1)

wodd_2 = cut_sqw(data_source,proj_odd,[-0.4,0.2],[0,0.05,3],[-0.5,0.05,3],[30,40]);
plot(wodd_2)


% Test that repeated cuts give same results (exercises binning book-keeping)
% ----------------------------
proj_011.u = [0,1,-1];
proj_011.v = [0,1,1];
proj_011.type = 'rrr';
proj_011.uoffset = [0.1,0.2,0.3,0];
w2=cut_sqw(data_source,proj_011,[-.5,0.05,1.5],[-0.5,0.05,2],[-0.4,0.2],[30,40]);
plot(w2)
%%
% But this cut does not give the same number of points as Horace V2.0.1:
proj_b.u = [0,1,-0.5];
proj_b.v = [0,0.5,1];
proj_b.type = 'rrr';
proj_b.uoffset = [0.1,0,0,0];
w1=cut(w2,proj_b,[1.55,1.65],0.05,[-0.2,0],[30,40]);
plot(w1)



