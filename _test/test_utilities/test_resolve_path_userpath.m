classdef test_resolve_path_userpath< TestCase
    properties
    end
    methods
        function obj=test_resolve_path_userpath(varargin)
            if nargin == 0
                name= mfilename('class');
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        function test_file_missing_dir(~)

            new_file = tempname(getuserdir());
            [fp,fn] = fileparts(new_file);
            new_file = fullfile(fp,fn,fn);

            [ok,exist,file_name,err_mess] = check_file_writable(new_file);
            assertFalse(ok)
            assertFalse(exist);
            file = java.io.File(new_file);
            new_file_canonical= char(file.getCanonicalPath());

            assertEqual(file_name,new_file_canonical)
            assertFalse(isempty(err_mess));

        end

        function test_file_writable(~)

            new_file = tempname(getuserdir());

            [ok,file_exist,file_name,err_mess] = check_file_writable(new_file);
            assertTrue(ok)
            assertFalse(file_exist);
            file = java.io.File(new_file);
            new_file_canonical= char(file.getCanonicalPath());

            assertEqual(file_name,new_file_canonical)
            assertTrue(isempty(err_mess));
            assertFalse(is_file(file_name));
        end


        function test_file_exist(~)

            new_file = tempname(getuserdir());
            clob = onCleanup(@()delete(new_file));
            fh = fopen(new_file,'w');
            assertTrue(fh>0)
            fwrite(fh,'a');
            fclose(fh);

            [ok,exist,new_file_name,err_mess] = check_file_writable(new_file,true);
            assertTrue(ok)
            assertTrue(exist);
            file = java.io.File(new_file);
            new_file_canonical= char(file.getCanonicalPath());

            assertEqual(new_file_name,new_file_canonical)
            assertTrue(isempty(err_mess));
        end

        function test_missing_file(~)
            mis_file = tempname(getuserdir());
            [ok,exist,fullfile,err_mess] = check_file_writable(mis_file,true);
            assertFalse(ok)
            assertFalse(exist);
            file = java.io.File(mis_file);
            mis_file_canonical= char(file.getCanonicalPath());
            assertEqual(fullfile,mis_file_canonical)
            assertFalse(isempty(err_mess));
        end

        function test_options_resolve_local(~)
            this_test = 'test_resolve_path_userpath.m';
            expected = [mfilename('fullpath'),'.m'];

            actual = resolve_path(this_test);
            assertEqual(actual, expected);
        end

        function test_options_resolve_substr(~)
            this_test = fileparts(mfilename('fullpath'));

            one_up = fileparts(this_test);
            actual = resolve_path([this_test, filesep, '..']);

            assertEqual(actual, one_up);

        end
        function test_resolve_home_dir(~)
            if ~isunix
                skipTest('No "~" home directory on Windows')
            end

            expected = getuserdir();
            actual = resolve_path('~');
            if ~strcmp(expected,actual) % resolve simulink, referred by expected
                file = java.io.File(expected);
                expected = char(file.getCanonicalPath());
            end
            assertEqual(expected, actual, [' non-equal dirs: ',expected, ' and ', actual]);
        end


    end
end
