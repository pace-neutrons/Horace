%% Set up projection description for a given plane
data_source = 'c:\tgp_data\fe.sqw';

proj_110.u=[1,1,0];
proj_110.v=[-1,1,0];
proj_110.type='rrr';
proj_110.uoffset=[0,0,0,0]';


%% Read in cut as a normal Horace data structure
slice_file='c:\tgp_data\w110.sqw';
w110 = read_sqw(slice_file);
plot(w110)
lx -2 3; 
ly 0 400;
lz 0 0.4



%% Create background from higher momentum end of the plot
% (Can plot any output, at any stage, of course)
wbackcut = cut(w110,1,[2,3]);       % 1D cut
acolor b
plot(wbackcut)

wback = replicate(wbackcut,w110);   % Create 2D cut by replicating along the 'missing' plot axis
wdiff = w110-wback;                 % Subtract the background
plot(wdiff)
lz 0 0.2


%% Correct for magnetic form factor
ff = sqw(w110,@feformsqr,0.057);    % Calculate the Fe form factor
wcor = wdiff / ff;                  % Divide the background subtracted data 
plot(wcor)
lz 0 0.7


%% smooth data
wcor = smooth(wcor);
plot(wcor)
lz 0 0.7

%% overplot dispersion relation
fedisp=dispersion(wcor,@bcc_hfm,45);
acolor y
pl(fedisp,'Horace_2D')


%% Make 1D cut along 110

% Take cut from the data source, or the 2D cut we've just created - should be identical
d1 = cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [225,250]);
acolor b
plot(d1)

%% Make series of cuts

% Take cut from the data source, or the 2D cut we've just created - should be identical
d1(1) = cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [150,175]);
d1(2) = cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [175,200]);
d1(3) = cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [200,250]);
d1(4) = cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [225,250]);
acolor b r k g
d1=d1+[0,0.1,0.2,0.3];
plot(d1)



