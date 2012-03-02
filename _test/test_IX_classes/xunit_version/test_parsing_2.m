function test_parsing_2
%% Test of simple parsing routines
[ok,mess,ind,val]=parse_keywords({'moo','hel','hello'},'hel',14);
assertTrue(ok);
assertEqual(2,ind);
assertEqual(14,val{1});

[ok,mess,par,ind,val]=parse_args_simple_ok_syntax({'moo','hel','hello'},[13,14],true,'hel',14)
assertTrue(ok);
assertEqual(2,ind);
assertEqual(14,val{1});


[ok,mess,par,ind,val]=parse_args_simple_ok_syntax({'moo','hel','hello'},'hel',14)
assertTrue(ok);
assertEqual(2,ind);
assertEqual(14,val{1});



