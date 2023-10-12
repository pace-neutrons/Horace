classdef test_fcloser < TestCase
    properties
        sqw_obj_for_tests;
    end

    methods
        function obj = test_fcloser(varargin)
            if nargin == 0
                name = varargin{1};
            else
                name = 'test_fcloser';
            end
            obj = obj@TestCase(name);
        end
        function file_deleter(~,fid)
            fn = fopen(fid);
            if isempty(fn)
                return
            else
                fclose(fid);
            end
            delete(fn);
        end
        function test_automated_fcloser_works(obj)
            test_file = fullfile(tmp_dir,'fcloser_test_auto.bin');
            fh = fopen(test_file,'wb+');
            assertTrue(fh>0);
            clOb = onCleanup(@()file_deleter(obj,fh));

            fclsr = fcloser(fh);
            assertFalse(isempty(fclsr));
            assertTrue(isvalid(fclsr));

            clear fclsr
            assertEqual(exist('fclsr','var'),0)

            fn = fopen(fh);
            assertTrue(isempty(fn));
        end

        function test_initialized_fcloser_works(obj)
            test_file = fullfile(tmp_dir,'fcloser_test.bin');
            fh = fopen(test_file,'wb+');
            assertTrue(fh>0);
            clOb = onCleanup(@()file_deleter(obj,fh));

            fclsr = fcloser(fh);
            assertFalse(isempty(fclsr));
            assertTrue(isvalid(fclsr));

            fclsr.delete();
            assertTrue(isempty(fclsr));
            assertFalse(isvalid(fclsr));

            fn = fopen(fh);
            assertTrue(isempty(fn));

            clear fclsr
            assertEqual(exist('fclsr','var'),0)
        end

        function test_empfy_fcloser_works(~)
            fclsr = fcloser();
            assertTrue(isempty(fclsr));
            assertTrue(isvalid(fclsr));

            fclsr.delete();
            assertTrue(isempty(fclsr));
            assertFalse(isvalid(fclsr));

            clear fclsr
            assertEqual(exist('fclsr','var'),0)
        end

    end

end
