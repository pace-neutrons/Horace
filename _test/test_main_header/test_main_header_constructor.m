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
        function test_serialize_deserialize_keeps_defined_date(obj)
            inputs = struct('filename','test_file','filepath','test_path',...
                'title','my_test_title','nfiles',10);
            th = main_header_tester(inputs);
            assertEqual(th.filename,'test_file');
            assertEqual(th.filepath,'test_path');
            assertEqual(th.title,'my_test_title');
            assertEqual(th.nfiles,10);
            assertFalse(th.creation_date_defined);

            date_tested = th.creation_date;
            close_date = obj.get_close_date(date_tested);

            th.creation_date = date_tested;
            assertTrue(th.creation_date_defined);


            assertTrue(all(date_tested == close_date));
            assertEqual(th.filename_with_cdate,['test_file$',date_tested])

            dat = th.saveobj();

            th_rec = serializable.loadobj(dat);

            assertEqual(th,th_rec);
        end

        function test_serialize_deserialize_keeps_undefined_date(obj)
            inputs = struct('filename','test_file','filepath','test_path',...
                'title','my_test_title','nfiles',10);
            th = main_header_tester(inputs);
            assertEqual(th.filename,'test_file');
            assertEqual(th.filepath,'test_path');
            assertEqual(th.title,'my_test_title');
            assertEqual(th.nfiles,10);
            assertFalse(th.creation_date_defined);

            date_tested = th.creation_date;
            close_date = obj.get_close_date(date_tested);

            assertTrue(all(date_tested == close_date));
            assertEqual(th.filename_with_cdate,'test_file')

            dat = th.saveobj();

            th_rec = serializable.loadobj(dat);

            assertEqual(th,th_rec);
        end
        function test_partial_constructor(~)
            th = main_header_cl('my_file','my_path');
            assertEqual(th.filename,'my_file');
            assertEqual(th.filepath,'my_path');
            assertTrue(isempty(th.title));
            assertEqual(th.nfiles,0);
            assertFalse(th.creation_date_defined)
        end

        function test_invalid_setter_throws(~)
            th = main_header_tester();
            function setter(prop_name,prop_val)
                th.(prop_name) = prop_val;
            end

            assertExceptionThrown(@()setter('nfiles','a'),...
                'HORACE:main_header:invalid_argument');

            assertExceptionThrown(@()setter('filename',10),...
                'HORACE:main_header:invalid_argument');

            assertExceptionThrown(@()setter('filepath',10),...
                'HORACE:main_header:invalid_argument');

            assertExceptionThrown(@()setter('title',10),...
                'HORACE:main_header:invalid_argument');

            assertExceptionThrown(@()setter('creation_date',10),...
                'HORACE:main_header:invalid_argument');

            assertExceptionThrown(@()setter('creation_date_defined',1),...
                'MATLAB:class:noSetMethod');

        end
        function test_existing_file_creation_date(~)
            th = main_header_tester();
            the_file = mfilename('fullpath');
            [fp,fn,fe] = fileparts(the_file);

            file = [fn,'.m'];
            th.filename = file ;
            th.filepath = fp;

            assertFalse(th.creation_date_defined);

            % test the mechanism of defining new creation date
            % the creation date is taken from the existing file
            % creation date
            ct_tested = th.creation_date;

            assertEqual(th.filename_with_cdate,file)

            th.creation_date = ct_tested ;
            assertTrue(th.creation_date_defined);
            assertEqual(th.creation_date,ct_tested);

            assertEqual(th.filename_with_cdate,[file,'$',ct_tested])
        end

        function test_non_existing_file_and_other_properties(~)
            th = main_header_tester();
            th.nfiles = 10;
            assertEqual(th.nfiles,10)
            th.filename = 'some_file';
            assertEqual(th.filename,'some_file')
            th.filepath = '/path';
            assertEqual(th.filepath,'/path');
            th.title = 'some title';
            assertEqual(th.title,'some title');

            assertFalse(th.creation_date_defined);

            % test the mechanism of defining new creation date
            ct_tested = th.creation_date;

            assertEqual(th.filename_with_cdate,'some_file')

            th.creation_date = ct_tested ;
            assertTrue(th.creation_date_defined);
            assertEqual(th.creation_date,ct_tested);

            assertEqual(th.filename_with_cdate,['some_file$',ct_tested])
        end
        function test_empty_constructor(obj)
            th = main_header_tester();
            assertEqual(th.nfiles,0)
            assertTrue(isempty(th.filename))
            assertTrue(isempty(th.filepath))
            assertTrue(isempty(th.title))
            %
            assertFalse(th.creation_date_defined);


            date_tested = th.creation_date;
            date_selected = obj.get_close_date(date_tested);

            assertTrue(all(date_tested == date_selected));
        end
        function equal_date = get_close_date(~,date_tested)
            % helper routine to get current date and time, close to one,
            % to be obtained from main_header_cl method.
            %
            % Use after main_header_cl.creation_date function is called.
            % Inputs:
            % date_tested -- the date, obtained from main_header_cl.creation_date
            %                function,
            date_now = datetime("now");
            % in case date_tested returned a second earlier time,
            % modify dt_now to be 1 sec earlier
            date_now_m = date_now;
            date_now_m.Second = date_now_m.Second-1;
            %
            wrtr = main_header_tester.get_creation_time_out_formater();
            % convert to properly formatted string
            date_now = wrtr(date_now);
            date_now_m = wrtr(date_now_m);
            if all(date_now == date_tested)
                equal_date = date_now;
            else
                equal_date = date_now_m;
            end

        end

    end
end
