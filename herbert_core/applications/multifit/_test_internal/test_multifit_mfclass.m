function test_multifit_mfclass

%  Have to compare pf and p_info
%  Do this using the debugger in multifit_main, breakpoint just after
% the last occurence of ptrans_initialise, and use the line:
%
%   >> save('c:\temp\crappy.mat','pf', 'p_info')
%
%  For mfclass:
%
%   >> [ok, mess, pf, p_info] = ptrans_initialise_(kk); ok, mess





test_data

% First test:
% ------------
kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100,55,66,77],[1,0,1,1,1]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,1]);

kk=kk.set_bind(5,4);
kk=kk.add_bind(3,[1,-1]);
kk=kk.add_bbind(4,-1,13);
kk=kk.add_bbind(2,-2);


bind={{5,4},{3,1,1}};
bbind={{{4,1,-1,13},{2,2,-1}}};

[wout,fitdata]=multifit(warr3,@noggle,[1,100,55,66,77],[1,0,1,1,1],bind,@toot,[1,100,24,2],[0,1,1,1],bbind);




% Second test test:
% ------------
kk=mfclass(warr3);

pin={[1,100,55,66,77],1000+[1,100,55,66,77],2000+[1,100,55,66,77]};
free={[1,1,1,0,0],[1,0,1,1,1],[1 1 0 0 1]};

bpin={[1,100,24,2],1000+[1,100,24,2],2000+[1,100,24,2]};
bfree={[0,1,1,1],[1,0,1,1],[1,1,0,1]};

kk=kk.set_local_foreground;
kk=kk.set_fun(@noggle,pin,free);
kk=kk.set_bfun(@toot,bpin,bfree);


kk=kk.add_bind({[1,2],[3,-3],44});
kk=kk.add_bbind([4,2],[5,-3],13);

bind={{}, {1,3,3,44}, {}};
bbind={{}, {4,5,-3,13}, {}};


[wout,fitdata]=multifit(warr3,@noggle,pin,free,bind,@toot,bpin,bfree,bbind,'local_foreground');



function compare

tmp=load('c:\temp\crappy.mat','pf', 'p_info');

isequaln(tmp.pf,pf)
isequaln(tmp.p_info,p_info)



[tmp.pf';pf']


