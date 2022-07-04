function test_ptrans_initialise

test_data

warr4=[warr3,w1+100];
kk=mfclass(warr4);
kk=kk.set_fun(@noggle,[1,100],[1,0]);
kk=kk.set_bfun(@toot,[1,100,24,2],[0,1,1,0]);

% Check with no bound parmaeters
[ok, mess, pf, p_info] = ptrans_initialise_(kk);
if ~ok, error('ERROR'), end

% Remove data, but bind some parameters so still OK
%---------------------------------------------------
% Completely remove first and third data sets
kk=kk.set_mask(1,'remove',[-1,11]);
kk=kk.set_mask(3,'remove',[14,25]);

% Should fail - unconstrained parameters
[ok, mess, pf, p_info] = ptrans_initialise_(kk);
if ok, error('ERROR'), else disp(mess), end

% Should be OK
kk=kk.add_bbind([1,3],{2,[2,2]},{3,[3,2]});
[ok, mess, pf, p_info] = ptrans_initialise_(kk);
if ~ok, error('ERROR'), end

