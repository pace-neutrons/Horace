% Create test data

clear classes
test_data

%-------------------------------------------------------------
kk=mfclass(w1);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.set_bind(1,-2);
kk=kk.add_bind(2,1);


%-------------------------------------------------------------
kk=mfclass(w1);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.set_bind([2,1],[4,-1],13);
kk=kk.set_bind(1,-2);
kk=kk.add_bind([2,1],[4,-1],13);

kk=kk.set_global_background;

kk=kk.set_local_foreground;


%-------------------------------------------------------------
kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.set_bbind(4,-1,13);   
kk=kk.add_bbind(2,-2);


kk=kk.set_global_background;

kk=kk.set_local_foreground;



%-------------------------------------------------------------
warr4=[warr3,w1+100];
kk=mfclass(warr4);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.set_bbind(4,-1,13);   
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

%-------------------------------------------------------------
% Test binding indirectly to self
kk=mfclass(w1);

kk=kk.set_fun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.set_bind(1,2,13); kk.pbind
kk=kk.add_bind(2,3,13); kk.pbind
kk=kk.add_bind(3,1,13); kk.pbind


%-------------------------------------------------------------
%   20 July 2016
%-------------------------------------------------------------
% Test new binding algorithms 20/7/16
% Clear all parameters
kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk2=kk;

kk2=kk2.set_bbind(4,-1,13);   
kk2=kk2.add_bbind(2,-2);

kk2=kk2.clear_bbind;

if isequaln(kk,kk2),disp('OK'),else disp('*** ERROR ***'),end


%-------------------------------------------------------------
% Test clear a few functions
kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.set_bbind(4,-1,13);   
kk=kk.add_bbind(2,-2);

kk2=kk;

% This:
kk=kk.add_bbind([1,3],{3,1});   % bind p3 to p1 for funs 1 & 3

% Should be the same as:
kk2=kk2.add_bbind(3,1);
kk2=kk2.clear_bbind(2);
kk2=kk2.add_bbind(2,{4,-1,13});
kk2=kk2.add_bbind(2,{2,-2});

if isequaln(kk,kk2),disp('OK'),else disp('*** ERROR ***'),end

%-------------------------------------------------------------
% Test free - I
kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100]);
kk=kk.set_bfun(@toot,[1,100,24,2]);

kk=kk.set_free([0,1])

kk=kk.set_bfree([0,1,0,1])


%-------------------------------------------------------------
% Test free - II
kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.clear_free

kk=kk.clear_bfree(2)

kk=kk.clear_bfree

%-------------------------------------------------------------
% Test free - III
kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100]);
kk=kk.set_bfun(@toot,[1,100,24,2]);
kk=kk.set_bfun(2,@parp,[88,89,90]);

kk=kk.set_free([0,1])

kk=kk.set_bfree({[0,1,0,1],[0,0,0],[1,1,0,0]})


%-------------------------------------------------------------
% Test binding of loads of functions
ww = repmat([warr3,w1+100],1,25);

kk=mfclass(ww);

kk=kk.set_fun(@noggle,101:200,logical(round(rand(1,100))));
kk=kk.set_bfun(@toot,1001:1100,logical(round(rand(1,100))));

kk=kk.set_bbind({99,-2,99},{100,-1,13});

ibnd=1:2:97;
iind=ibnd+1;
bnd=cell(1,numel(ibnd));
for i=1:numel(bnd)
    bnd{i}={ibnd(i),iind(i)};
end

tic;
kk=kk.add_bbind(bnd{:});
toc;

ibnd2=(1:4:97) + 1;
bnd2=cell(1,numel(ibnd2));
for i=1:numel(bnd2)
    bnd2{i}={ibnd2(i),-1};
end

kk2=kk;
tic;
kk2=kk2.add_bbind(bnd2{:});
toc;


%-------------------------------------------------------------
% Test binding of loads of functions - now with ratios
ww = repmat([warr3,w1+100],1,25);

kk=mfclass(ww);

kk=kk.set_fun(@noggle,101:200,logical(round(rand(1,100))));
kk=kk.set_bfun(@toot,1001:1100,logical(round(rand(1,100))));

kk=kk.set_bbind({99,-2,99},{100,-1,13});

ibnd=1:2:97;
iind=ibnd+1;
bnd=cell(1,numel(ibnd));
for i=1:numel(bnd)
    bnd{i}={ibnd(i),iind(i),7};
end

tic;
kk=kk.add_bbind(bnd{:});
toc;

ibnd2=(1:4:97) + 1;
bnd2=cell(1,numel(ibnd2));
for i=1:numel(bnd2)
    bnd2{i}={ibnd2(i),-1,12.4};
end

kk2=kk;
tic;
kk2=kk2.add_bbind(bnd2{:});
toc;


%-------------------------------------------------------------
%   24 August 2016
%-------------------------------------------------------------
% Test different binding procedures

kkref=mfclass(warr3);
kkref=kkref.set_fun(@noggle,[1,100],[1,0]);
kkref=kkref.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kkref;
kk=kk.set_bbind(4,-1,13);   
kk=kk.add_bbind(2,-2);

kk2=kkref;
kk2=kk2.set_bind(kk.pbind);
kk2=kk2.set_bbind(kk.bpbind);





%============================================================
% Features that could be improved
%============================================================

%-------------------------------------------------------------
% Global to local binding  20/7/16
%
% Should catch case of binding a global function parameter to
% a local function parameter. In this example, a parameter of
% the global foreground is implicitly bound to a parameter of the
% first local background function. Probably should require 
% explicit local function index in this case; the user
% might expect that this would bind all local background functions.

kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.add_bind(2,-1);   % why does this work? (is global foreground)


%-------------------------------------------------------------
% Not very informative error message - should notice that function
% has not been defined, which is why there are no free parameters
kk=mfclass(warr3);
kk=kk.add_bbind(3,-1);

%-------------------------------------------------------------
% Not very informative error message - looks puzzling
kk=mfclass(w1);

kk=kk.set_fun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.add_bind({2,3},{3,4});
kk=kk.add_bind(3,-1);


%-------------------------------------------------------------
% Syntax incorrect, but looks as if it ought to be: need 
% better message?

kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);


% This fails: could be a more helpful message
kk=kk.add_bbind([2,3],[3,4]);

% This works: but could a user type the above instead by mistake?
kk=kk.add_bbind({2,3},{3,4});




%============================================================
% BUGS
%============================================================


%============================================================
% SOLVED BUGS
%============================================================

kk=mfclass(w1);

kk=kk.set_fun(@toot,[1,100,24,2],[0,1,1,0]);

kk2=kk;

% This:
kk=kk.add_bind(2,3);
kk=kk.add_bind(3,4);

% Should be equivalent to this:
kk2=kk2.add_bind({2,3},{3,4});

if isequaln(kk,kk2),disp('OK'),else disp('*** ERROR ***'),end

%-------------------------------------------------------------
kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.add_bbind({2,3},{3,4});
kk=kk.add_bbind(3,-1);


%-------------------------------------------------------------

kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.add_bbind({2,3},{3,4});
kk=kk.add_bbind(3,-1);

kk=kk.clear_fun     % fails

kk=kk.clear_bfun    % ok
kk=kk.clear_fun     % now OK!

%-------------------------------------------------------------

% Wan't removing the data
kk=mfclass(warr3);

kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

kk=kk.remove_data

































