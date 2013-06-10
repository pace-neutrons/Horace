%% Test of simple parsing routines
[ok,mess,ind,val]=parse_keywords({'moo','hel','hello'},'hel',14);
if ~ok,  error('Problem with parse_keywords'), end

[ok,mess,par,ind,val]=parse_args_simple_ok_syntax({'moo','hel','hello'},[13,14],true,'hel',14);
if ~ok,  error('Problem with parse_args_simple_ok_syntax'), end

[ok,mess,par,ind,val]=parse_args_simple_ok_syntax({'moo','hel','hello'},'hel',14);
if ~ok,  error('Problem with parse_args_simple_ok_syntax'), end
