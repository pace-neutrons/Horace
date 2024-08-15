classdef test_parse_char_options< TestCase
    properties
    end
    methods
        function this=test_parse_char_options(name)
            this = this@TestCase(name);
        end

        function test_options_only(~)
            opt = {'-opt1','-opt2'};
            arguments = {'-opt1'};
            [ok,mess,true1,false2]=parse_char_options(arguments,opt);

            assertTrue(ok);
            assertTrue(isempty(mess));
            assertTrue(true1);
            assertTrue(~false2);
        end

        function test_parse_char_options_extra_no_out_throw(~)
            opt = {'-opt1','-opt2'};
            arg = {'aaa','bbb','-opt1','ccc','-dddd'};
            [ok,mess,true1,false2]=parse_char_options(arg,opt);
            assertTrue(~ok);
            assertTrue(strcmp('Invalid input key: "aaa"',mess));
        end

        function test_parse_char_options_extra_out(~)
            opt = {'-opt1','-opt2'};
            arg = {'aaa','bbb','-opt1','ccc','-dddd'};

            [ok,mess,true1,false2,left]=parse_char_options(arg,opt);
            assertTrue(ok);
            assertTrue(isempty(mess));
            assertTrue(true1);
            assertTrue(~false2);
            assertEqual({'aaa','bbb','ccc','-dddd'},left);
        end
    end
end
