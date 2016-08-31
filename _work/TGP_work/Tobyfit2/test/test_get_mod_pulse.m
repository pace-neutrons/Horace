% test_get_mod_pulse - test get_mod_pulse.m

load('w1inc')



[pulse_model,pp,ok,mess,p,present] = get_mod_pulse (w1inc)

% Change one of the moderators
wtmp = w1inc;

hh=wtmp.header;
moder=hh{23}.instrument.moderator;
pp=moder.pp;
moder.pp=[13,0,0];
hh{23}.instrument.moderator=moder;

wtmp.header=hh;

[pulse_model,pp,ok,mess,p,present] = get_mod_pulse (wtmp)


%--------------------

wtmp = w1inc;

kk=tobyfit2(wtmp)




