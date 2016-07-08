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



%-------------------------------------------------------------
warr4=[warr3,w1+100];
kk=mfclass(warr4);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.set_bbind(4,-1,13);   % why does this work? (is global foreground)
kk=kk.add_bbind(2,-2);

kk=kk.set_mask('keep',[2,8;9,16;18,22],'remove',[6,7]);
kk=kk.add_mask('remove',[3,4]);
kk=kk.add_mask(2,'keep',[13,15.5]);

%-------------------------------------------------------------
% Test various maskings
% -----------------------
% x,y,e array
kk=mfclass(x1,y1,e1);
kk=kk.set_mask('remove',[1.5,9.5]);
ww=kk.data_out;     % double array with lots of NaNs

kk.keep_only_unmasked = true;
ww=kk.data_out;     % double array with NaNs stripped out

% Single cell array
kk=mfclass(c1);
kk=kk.set_mask('remove',[1.5,9.5]);
ww=kk.data_out;     % double array with lots of NaNs

kk=mfclass({c1});
kk=kk.set_mask('remove',[1.5,9.5]);
ww=kk.data_out;     % double array with lots of NaNs

% Single structure
kk=mfclass(s1);
kk=kk.set_mask('remove',[1.5,9.5]);
ww=kk.data_out;     % double array with lots of NaNs

% 2D object
kk=mfclass(ww1);
kk=kk.set_mask('remove',[2,8,4,14]);
ww=kk.data_out;


kk=mfclass(ccx1);
kk=kk.set_mask('remove',[2,8,4,14]);
ww=kk.data_out;
kk.keep_only_unmasked=true;
ww=kk.data_out;

