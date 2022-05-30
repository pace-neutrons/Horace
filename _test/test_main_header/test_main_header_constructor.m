classdef test_main_header_constructor< TestCase
    %
    %
    %


    properties
        sample_dir;
        sample_file;
    end
    methods

        function this=test_main_header_constructor(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this=this@TestCase(name);
        end
        % tests
        function test_empty_constructor(~)
            th = main_header_tester();
            assertEqual(th.nfiles,0)
            assertTrue(isempty(th.filename))
            assertTrue(isempty(th.filepath))
            assertTrue(isempty(th.title))
            %
            assertTrue(th.no_cr_date_known);

            dt_now = datetime("now");
            dt_tested = th.creation_date;
            % in case th.creation_date returned a second later time,
            % modify dt_now to be 1 sec later
            dt_now_p = dt_now;
            dt_now_p.Second = dt_now_p.Second+1;
            dt_tested_cl = th.get_creation_time(dt_tested);

            assertTrue(all(char(dt_tested_cl) == char(dt_now)...
                | char(dt_tested_cl) == char(dt_now_p)))
        end

    end
end


