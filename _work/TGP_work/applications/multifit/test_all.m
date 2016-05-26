% Create test data

clear classes
test_data

%-------------------------------------------------------------
kk=mfclass(w1);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.set_bind([2,1],[4,-1],13);
kk=kk.set_bind(1,-2);
kk=kk.add_bind([2,1],[4,-1],13);

kk=kk.set_global_background;

kk=kk.set_local_foreground;


% To look at bindings
disp_bind(kk)


%-------------------------------------------------------------
kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.set_bbind(4,-1,13);   % why does this work? (is global foreground)
kk=kk.add_bbind(2,-2);


kk=kk.set_global_background;

kk=kk.set_local_foreground;




