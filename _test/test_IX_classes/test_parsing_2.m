function test_parsing_2
% Test of simple parsing routines
%
% Author: T.G.Perring

banner_to_screen(mfilename)

[ok,mess,ind,val]=parse_keywords({'moo','hel','hello'},'hel',14);
if ~ok,  assertTrue(false,'Problem with parse_keywords'), end

[ok,mess,par,ind,val]=parse_args_simple_ok_syntax({'moo','hel','hello'},[13,14],true,'hel',14);
if ~ok,  assertTrue(false,'Problem with parse_args_simple_ok_syntax'), end

[ok,mess,par,ind,val]=parse_args_simple_ok_syntax({'moo','hel','hello'},'hel',14);
if ~ok,  assertTrue(false,'Problem with parse_args_simple_ok_syntax'), end

% Success announcement
% --------------------
banner_to_screen([mfilename,': Test(s) passed'],'bot')
