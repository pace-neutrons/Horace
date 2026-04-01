classdef test_title_squeeze < TestCase
    methods
        function this=test_title_squeeze(varargin)
            if nargin == 0
                name = 'test_title_squeeze';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end

        function test_double_input_with_empty_char(~)
            in = {1,2,'',3};
            out = title_squeeze(in);
            assertEqual(out,{char(1),char(2),char(3)})
        end
        

        function test_mixied_input_with_empty_char(~)
            in = {'aaa',"bbb",'','ccc'};
            out = title_squeeze(in);
            assertEqual(out,{'aaa','bbb','ccc'})
        end

        function test_mixied_input_with_empty_double(~)
            in = {'aaa',"bbb",[],'ccc'};
            out = title_squeeze(in);
            assertEqual(out,{'aaa','bbb','ccc'})
        end

        function test_mixied_input(~)
            in = {'aaa',"bbb",'ccc'};
            out = title_squeeze(in);
            assertEqual(out,{'aaa','bbb','ccc'})
        end
        function test_char(~)
            out = title_squeeze('aaa');
            assertEqual(out,{'aaa'})
        end

        function test_string(~)
            out = title_squeeze("aaa");
            assertEqual(out,{'aaa'})
        end
    end
end
