classdef test_parallel_mf < TestCase
    % Performs some tests of fitting to Horace objects using parallel multifit_sqw and other functions.

    properties
        w1data;
        w2data;
        w4ddata;
        win;

        hpc_back;
        par_back;
    end

    methods
        function obj = test_parallel_mf(name)
            % Construct object
            obj = obj@TestCase(name);

            % Read in data
            data_dir = fileparts(mfilename('fullpath'));

            obj.w1data = read_sqw(fullfile(data_dir,'w1data.sqw'));
            obj.w2data = read_sqw(fullfile(data_dir,'w2data.sqw'));
            hp = horace_paths;
            obj.w4ddata = read_sqw(fullfile(hp.test_common,'sqw_4d.sqw'));
            obj.win=[obj.w1data,obj.w2data];     % combine the two cuts into an array of sqw objects and fit

        end

        % ------------------------------------------------------------------------------------------------
        function obj = test_fit_one_dataset(obj)
            % Example of fitting one sqw object

            hc = hpc_config;
            hc_clob = set_temporary_config_options(hc, 'parallel_multifit', false);

            mss = multifit_sqw_sqw([obj.w1data]);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
            mss = mss.set_free([1,1,0,0,0]); % set which parameters are floating
            mss = mss.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0]}); % set background function(s)
            mss = mss.set_bfree([1,1,1,1,1]);    % set which parameters are floating
            mss = mss.set_bbind({1,[1,-1],1},{2,[2,-1],1});

            % And now fit
            [~, fitpar_ser] = mss.fit();


            hc.parallel_multifit = true;

            hc.parallel_cluster = 'dummy';
            hc.parallel_workers_number = 1;
            [~, fitpar_par] = mss.fit();
            assertTrue(is_same_fit(fitpar_ser, fitpar_par))

            hc.parallel_workers_number = 3;
            pc = {'parpool'};
%             for pc = {'herbert', 'mpiexec_mpi', 'parpool'}
                hc.parallel_cluster = pc{1};
                [~, fitpar_par] = mss.fit();
                assertTrue(is_same_fit(fitpar_ser, fitpar_par))
%             end
        end

        % ------------------------------------------------------------------------------------------------
        function obj = test_fit_multidimensional_dataset(obj)
            % Example of simultaneously 4d data
            hc = hpc_config;
            hc_clob = set_temporary_config_options(hc, 'parallel_multifit', false);

            mss = multifit_sqw_sqw([obj.w4ddata]);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
            mss = mss.set_free([1,1,0,0,0]); % set which parameters are floating
            mss = mss.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0]}); % set background function(s)
            mss = mss.set_bfree([1,1,1,1,1]);    % set which parameters are floating
            mss = mss.set_bbind({1,[1,-1],1},{2,[2,-1],1});

            % And now fit
            [~, fitpar_ser] = mss.fit();

            hc.parallel_multifit = true;

            hc.parallel_cluster = 'dummy';
            hc.parallel_workers_number = 1;
            [~, fitpar_par] = mss.fit();
            assertTrue(is_same_fit(fitpar_ser, fitpar_par))

            skipTest('Re #1824 enable when parallel multifit is fixed and working. This one shows bug in distrubute')
            hc.parallel_workers_number = 3;
            pc = {'parpool'};
%             for pc = {'herbert', 'mpiexec_mpi', 'parpool'}
                hc.parallel_cluster = pc{1};
                [~, fitpar_par] = mss.fit();
                assertTrue(is_same_fit(fitpar_ser, fitpar_par))
%             end

        end

        function obj = test_fit_two_datasets(obj)
            % Example of simultaneously fitting more than one sqw object

            hc = hpc_config;
            hc_clob = set_temporary_config_options(hc, 'parallel_multifit', false);

            mss = multifit_sqw_sqw(obj.win);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
            mss = mss.set_free([1,1,0,0,0]); % set which parameters are floating
            mss = mss.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}); % set background function(s)
            mss = mss.set_bfree([1,1,1,1,1]);    % set which parameters are floating
            mss = mss.set_bbind({1,[1,-1],1},{2,[2,-1],1});

            % And now fit
            [~, fitpar_ser] = mss.fit();

            hc.parallel_multifit = true;

            hc.parallel_cluster = 'dummy';
            hc.parallel_workers_number = 1;
            [~, fitpar_par] = mss.fit();
            assertTrue(is_same_fit(fitpar_ser, fitpar_par))

            skipTest('Re #1824 enable when parallel multifit is fixed and working')
            hc.parallel_workers_number = 3;
            pc = {'herbert'};
%             for pc = {'herbert', 'mpiexec_mpi', 'parpool'}
                hc.parallel_cluster = pc{1};
                [~, fitpar_par] = mss.fit();
                assertTrue(is_same_fit(fitpar_ser, fitpar_par))
%             end
        end

        % ------------------------------------------------------------------------------------------------
        function obj = test_fit_two_datasets_ave(obj)
            % Example of simultaneously fitting more than one sqw object
            % Average over pixels in a bin

            hc = hpc_config;
            hc_clob = set_temporary_config_options(hc, 'parallel_multifit', false);

            mss = multifit_sqw_sqw(obj.win);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
            mss = mss.set_free([1,1,0,0,0]); % set which parameters are floating
            mss = mss.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}); % set background function(s)
            mss = mss.set_bfree([1,1,1,1,1]);    % set which parameters are floating
            mss = mss.set_bbind({1,[1,-1],1},{2,[2,-1],1});
            mss.average = true;

            % And now fit
            [~, fitpar_ser] = mss.fit();

            hc.parallel_multifit = true;

            hc.parallel_cluster = 'dummy';
            hc.parallel_workers_number = 1;
            [~, fitpar_par] = mss.fit();
            assertTrue(is_same_fit(fitpar_ser, fitpar_par))

            skipTest('Re #1824 enable when parallel multifit is fixed and working')
            hc.parallel_workers_number = 3;
            pc = {'mpiexec_mpi'};
%             for pc = {'herbert', 'mpiexec_mpi', 'parpool'}
                hc.parallel_cluster = pc{1};
                [~, fitpar_par] = mss.fit();
                assertTrue(is_same_fit(fitpar_ser, fitpar_par))
%             end
        end
    end
end
