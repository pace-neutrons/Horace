classdef test_mfit_settings < TestCase
    properties
    end
    methods

        function obj=test_mfit_settings(name)
            if nargin < 1
                name = 'test_mfit_settings';
            end
            obj = obj@TestCase(name);
        end

        function test_set_multifun(~)
            ds1 = IX_dataset_1d();
            ds2 = IX_dataset_1d();
            mfc=mfclass(ds1,ds2);
            funs = {@(x,p)(1+p*x),@(x,p)(p+x.^2)};
            par = {1,1};
            free = {1,1};
            mfc = mfc.set_local_foreground;
            mfc = mfc.set_fun(funs,par,free);
            assertTrue(mfc.local_foreground);
        end

        function test_set_multi_fun(~)
            ds1 = IX_dataset_1d();
            ds2 = IX_dataset_1d();
            mfc=mfclass(ds1,ds2);
            funs = {@(x,p)(1+p*x),@(x,p)(p+x.^2)};

            mfc = mfc.set_fun(funs);
            assertTrue(mfc.local_foreground);
            assertTrue(iscell(mfc.fun))
            setfun = mfc.fun;
            assertEqual(setfun{1},funs{1})
            assertEqual(setfun{2},funs{2})

        end

        function test_set_one_by_one(~)
            ds1 = IX_dataset_1d();
            ds2 = IX_dataset_1d();

            mfc=mfclass([ds1,ds2]);
            mfc = mfc.set_local_foreground();

            func_fg = @(x,p)(1+p*x);
            func_bg = @(x,p)(p+x.^2);

            mfc = mfc.set_fun(func_fg ,1);

            assertTrue(mfc.local_foreground);
            setfun = mfc.fun;
            assertEqual(setfun{1},func_fg )
            assertEqual(setfun{2},func_fg )

            mfc = mfc.set_bfun(func_bg,2);

            setbfun = mfc.bfun;
            assertEqual(setbfun{1},func_bg )
            assertEqual(setbfun{2},func_bg )
        end
    end

end
