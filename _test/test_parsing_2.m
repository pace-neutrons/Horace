%% test of simple parsing routines
[ok,mess,ind,val]=parse_keywords({'moo','hel','hello'},'hel',14)

[ok,mess,par,ind,val]=parse_args_ok_syntax({'moo','hel','hello'},[13,14],true,'hel',14)

[ok,mess,par,ind,val]=parse_args_ok_syntax({'moo','hel','hello'},'hel',14)

