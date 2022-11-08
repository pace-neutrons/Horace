classdef test_multifit_horace_1 < TestCaseWithSave
    % Performs some tests of fitting to Horace objects using multifit_sqw and other functions.
    % Optionally writes results to output file
    %
    %   >> runtests test_multifit_horace_1  % Compares with previously saved results in
    %                                       % test_multifit_horace_1_output.mat
    %                                       % in the same folder as this function
    %
    %   >> test_multifit_horace_1('-save')  % Save to test_multifit_horace_1_output.mat
    %                                       % in the Matlab temporary folder (copy to
    %                                       % the same folder as this function after)
    %
    %   >> runtests test_multifit_horace_1:<test_func> % run a particular test from this
    %                                       % this test suite
    %
    % Reads previously created test data sets.

    properties
        w1data
        w2data
        w4ddata
        win
    end

    methods
        function this = test_multifit_horace_1(name)
            % Construct object
            output_file = 'test_multifit_horace_1_output.mat';
            this = this@TestCaseWithSave(name, output_file);

            % Read in data
            data_dir = fileparts(mfilename('fullpath'));

            this.w1data = read_sqw(fullfile(data_dir,'w1data.sqw'));
            this.w2data = read_sqw(fullfile(data_dir,'w2data.sqw'));
            hp = horace_paths;
            this.w4ddata = read_sqw(fullfile(hp.test_common,'sqw_4d.sqw'));
            this.win=[this.w1data,this.w2data];     % combine the two cuts into an array of sqw objects and fit

            % Save reference results, if '-save' option is requested
            this.save();
        end

        % ------------------------------------------------------------------------------------------------
        function this = test_fit_one_dataset(this)
            % Example of fitting one sqw object

            mss = multifit_sqw_sqw([this.w1data]);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
            mss = mss.set_free([1,1,0,0,0]); % set which parameters are floating
            mss = mss.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0]}); % set background function(s)
            mss = mss.set_bfree([1,1,1,1,1]);    % set which parameters are floating
            mss = mss.set_bbind({1,[1,-1],1},{2,[2,-1],1});

            % Simulate at the initial parameter values
            wsim_1 = mss.simulate();

            % And now fit
            [wfit_1, fitpar_1] = mss.fit();

            % Test against saved or store to save later; ingnore string
            % changes - these are filepaths
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (this, fitpar_1, 'tol', tol, 'ignore_str', 1)
            assertEqualToTolWithSave (this, wsim_1, 'tol', tol, 'ignore_str', 1, '-ignore_date')
            assertEqualToTolWithSave (this, wfit_1, 'tol', tol, 'ignore_str', 1, '-ignore_date')
        end

        % ------------------------------------------------------------------------------------------------
        function obj = test_fit_multidimensional_dataset(obj)
            % Example of simultaneously fitting more than one sqw object

            mss = multifit_sqw_sqw([obj.w4ddata]);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
            mss = mss.set_free([1,1,0,0,0]); % set which parameters are floating
            mss = mss.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0]}); % set background function(s)
            mss = mss.set_bfree([1,1,1,1,1]);    % set which parameters are floating
            mss = mss.set_bbind({1,[1,-1],1},{2,[2,-1],1});

            % Simulate at the initial parameter values
            wsim_1 = mss.simulate();

            % And now fit
            [wfit_1, fitpar_1] = mss.fit();

            % Test against saved or store to save later; ingnore string
            % changes - these are filepaths
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, fitpar_1, 'tol', tol, 'ignore_str', 1)
            
            ref_ds = obj.getReferenceDataset('test_fit_multidimensional_dataset','wsim_1'); % Bug #797
            wsim_1.experiment_info.instruments = ref_ds.experiment_info.instruments;
            wsim_1.experiment_info.instruments = wsim_1.experiment_info.instruments.rename_all_blank();
            assertEqualToTolWithSave (obj, wsim_1, 'tol', tol, 'ignore_str', 1, '-ignore_date')
            
            ref_ds = obj.getReferenceDataset('test_fit_multidimensional_dataset','wfit_1');  % Bug #797
            wfit_1.experiment_info.instruments = ref_ds.experiment_info.instruments;
            assertEqualToTolWithSave (obj, wfit_1, 'tol', tol, 'ignore_str', 1, '-ignore_date')
            
            skipTest('This is known bug #797. Instrument is not stored/restored properly');
        end

        function this = test_fit_two_datasets(this)
            % Example of simultaneously fitting more than one sqw object

            mss = multifit_sqw_sqw(this.win);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
            mss = mss.set_free([1,1,0,0,0]); % set which parameters are floating
            mss = mss.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}); % set background function(s)
            mss = mss.set_bfree([1,1,1,1,1]);    % set which parameters are floating
            mss = mss.set_bbind({1,[1,-1],1},{2,[2,-1],1});

            % Simulate at the initial parameter values
            wsim_1 = mss.simulate();

            % And now fit
            [wfit_1, fitpar_1] = mss.fit();

            % Test against saved or store to save later; ingnore string
            % changes - these are filepaths
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (this, wsim_1, 'tol', tol, ...
                'ignore_str', 1,'-ignore_date')
            assertEqualToTolWithSave (this, wfit_1, 'tol', tol, ...
                'ignore_str', 1,'-ignore_date')
            assertEqualToTolWithSave (this, fitpar_1, 'tol', tol, ...
                'ignore_str', 1)
        end

        % ------------------------------------------------------------------------------------------------
        function this = test_fit_two_datasets_ave(this)
            % Example of simultaneously fitting more than one sqw object
            % Average over pixels in a bin

            mss = multifit_sqw_sqw(this.win);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
            mss = mss.set_free([1,1,0,0,0]); % set which parameters are floating
            mss = mss.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}); % set background function(s)
            mss = mss.set_bfree([1,1,1,1,1]);    % set which parameters are floating
            mss = mss.set_bbind({1,[1,-1],1},{2,[2,-1],1});
            mss.average = true;

            % Simulate at the initial parameter values
            wsim_2 = mss.simulate();

            % And now fit
            [wfit_2,fitpar_2] = mss.fit();

            % Test against saved or store to save later; ingnore string
            % changes - these are filepaths
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (this, wsim_2, ...
                'tol', tol, 'ignore_str', 1,'-ignore_date')
            assertEqualToTolWithSave (this, wfit_2, ...
                'tol', tol, 'ignore_str', 1,'-ignore_date')
            assertEqualToTolWithSave (this, fitpar_2, 'tol', tol, 'ignore_str', 1)
        end

        % ------------------------------------------------------------------------------------------------
        function this=test_fit_array_of_datasets(this)
            skipTest('Needs fit_sqw to be implemented.')
            % Example of fitting single datasets, and independently fitting an array of datasets
            % This exercises fit_sqw for single datasets and for an array of datasets

            % Check fit_sqw correctly fits array of input
            %             [wfit_single1,fitpar_single1]=fit_sqw(this.w1data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);
            %
            %             [wfit_single2,fitpar_single2]=fit_sqw(this.w2data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);
            %             [wfit_single12,fitpar_single12]=fit_sqw(this.win, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);

            mss = fit_sqw(this.w1data);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,1,10,0]);  % set foreground function(s)
            mss = mss.set_free([0,1,1,1,1]); % set which parameters are floating
            mss = mss.set_bfun(@linear_bkgd, [0,0]); % set background function(s)
            [wfit_single1,fitpar_single1] = mss.fit();

            mss = multifit_sqw(this.w2data);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,1,10,0]);  % set foreground function(s)
            mss = mss.set_free([0,1,1,1,1]); % set which parameters are floating
            mss = mss.set_bfun(@linear_bkgd, [0,0]); % set background function(s)
            [wfit_single2,fitpar_single2] = mss.fit();

            mss = multifit_sqw(this.win);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,1,10,0]);  % set foreground function(s)
            mss = mss.set_free([0,1,1,1,1]); % set which parameters are floating
            mss = mss.set_bfun(@linear_bkgd, [0,0]); % set background function(s)
            [wfit_single12,fitpar_single12] = mss.fit();

            assertTrue(equal_to_tol([fitpar_single1,fitpar_single2],fitpar_single12),'fit_sqw fitting not working')
            assertTrue(equal_to_tol([wfit_single1,wfit_single2],wfit_single12),'fit_sqw workspaces not working');

            %             % Test against saved or store to save later
            %             this=save_or_test_variables(this,wfit_single1,wfit_single2,wfit_single12);
        end

        % ------------------------------------------------------------------------------------------------
        function this=test_fit_test_fit_array_of_datasets_2(this)
            skipTest('Needs fit_sqw to be implemented.')
            % Example of fitting single datasets, and independently fitting an array of datasets
            % This exercises multifit_sqw for single datasets and compares with fit_sqw for an array of datasets

            [wfit_single12,fitpar_single12]=fit_sqw(this.win, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);

            [wfit_single1,fitpar_single1]=multifit_sqw(this.w1data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);
            [wfit_single2,fitpar_single2]=multifit_sqw(this.w2data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);

            assertTrue(equal_to_tol([fitpar_single1,fitpar_single2],fitpar_single12),'fit_sqw not working for fit parameters');
            assertTrue(equal_to_tol([wfit_single1,wfit_single2],wfit_single12),'fit_sqw not working for dataset');

            fitpar_single1.corr=[];
            fitpar_single2.corr=[];
            fitpar_single12(1).corr=[];
            fitpar_single12(2).corr=[];

            %             tol = this.tol;
            %             this.tol = -1;
            %             this=save_or_test_variables(this,fitpar_single1,fitpar_single2,fitpar_single12);
            %             this.tol=tol;
        end

        % ------------------------------------------------------------------------------------------------
        function this=test_fit_array_of_datasets_3(this)
            skipTest('Needs fit_sqw to be implemented.')
            % Example of fitting single datasets, and independently fitting an array of datasets
            % This exercises multifit_sqw_sqw for single datasets and fit_sqw_sqw for an array of datasets

            [wfit_sqw_sqw,fitpar_sqw_sqw]=fit_sqw_sqw(this.win, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,0], @sqw_bcc_hfm, [5,5,0,1,0], [0,0,0,0,1]);
            [tmp1,ftmp1]=multifit_sqw_sqw(this.w1data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1]);
            [tmp2,ftmp2]=multifit_sqw_sqw(this.w2data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1]);
            assertTrue(equal_to_tol([tmp1,tmp2],wfit_sqw_sqw,-1e-8),'fit_sqw_sqw not working')

            %             % Test against saved or store to save later
            %             this=save_or_test_variables(this,wfit_sqw_sqw,fitpar_sqw_sqw);
        end
    end
end
