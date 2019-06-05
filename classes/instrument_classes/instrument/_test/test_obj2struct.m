function test_obj2struct

mod1 = IX_moderator; mod1.distance = 1;
mod2 = IX_moderator; mod2.distance = 2;
mod3 = IX_moderator; mod3.distance = 3;
mod4 = IX_moderator; mod4.distance = 4;


% Simple structure
clear S1
S1.a = {'hello'};
Sres = obj2structIndep(S1);


% Fix a bug
clear S2
S2.a = {[mod1,mod2]};
Sres = obj2structIndep(S2);


% Complicated structure
clear Ssub2 Ssub S
Ssub2.aa = 'kitty';
Ssub2.bb = IX_aperture;

Ssub.a = {'hello',[34,35],[mod1,mod2],{mod3,mod4},Ssub2};
Ssub.b = [101,102,103];

S.alph = IX_fermi_chopper;
S.beta = Ssub;

Sres = obj2structIndep(S);
