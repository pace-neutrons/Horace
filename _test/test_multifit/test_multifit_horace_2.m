classdef test_multifit_horace_2 < TestCaseWithSave
    % Performs some tests of fitting to Horace objects using multifit_sqw_sqw
    % Optionally writes results to output file
    %
    %   >> runtests test_multifit_horace_2  % Compares with previously saved results in
    %                                       % test_multifit_horace_2_output.mat
    %                                       % in the same folder as this function
    %
    %   >> test_multifit_horace_2('-save)   % Save to test_multifit_horace_2_output.mat
    %                                       % in the Matlab temporary folder (copy to
    %                                       % the same folder as this function after)
    %
    %   >> runtests test_multifit_horace_2:<test_func> % run a particular test from this
    %                                       % this test suite
    %
    % Reads previously created test data sets.
    
    properties
        w1data
        w2data
        win
    end
    
    methods
        function this=test_multifit_horace_2(name)
            % Construct object
            output_file = 'test_multifit_horace_2_output.mat';
            this = this@TestCaseWithSave(name, output_file);
            
            % Read in data
            data_dir = fileparts(mfilename('fullpath'));
            
            this.w1data = sqw(fullfile(data_dir,'w1data.sqw'));
            this.w2data = sqw(fullfile(data_dir,'w2data.sqw'));
            this.win=[this.w1data,this.w2data];     % combine the two cuts into an array of sqw objects and fit
            
            % Save output, if requrested
            %this.save();
        end
        
        % ------------------------------------------------------------------------------------------------
        function this=test_fit(this)
            % Test the reversal of foreground and background models in multifit_sqw_sqw
            
            % Fit with global foreground
            mss = multifit_sqw_sqw(this.win);
            mss = mss.set_fun(@sqw_bcc_hfm,  [5,5,0,10,0]);  % set foreground function(s)
            mss = mss.set_free([1,1,0,0,0]); % set which parameters are floating
            mss = mss.set_bfun(@sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}); % set background function(s)
            mss = mss.set_bfree([1,1,1,1,1]);    % set which parameters are floating
            mss = mss.set_bbind({1,[1,-1],1},{2,[2,-1],1});
            [wfit_1,fitpar_1] = mss.fit();
            
            % Fit using local foreground model
            mss = multifit_sqw_sqw(this.win);
            mss = mss.set_local_foreground;
            mss = mss.set_fun(@sqw_bcc_hfm_no_bkgd, {[5,5,1.2,10],[5,5,1.4,15]});  % set foreground function(s)
            mss = mss.set_bind({1,[1,1],1},{2,[2,1],1});
            mss = mss.set_bfun(@sqw_constant, 0); % set background function(s)
            [wfit_1_locfore,fitpar_1_locfore] = mss.fit();            
            
            % Check fit parameter values
            p1=[fitpar_1.bp{1},fitpar_1.bp{2}];
            p1sig=[fitpar_1.bsig{1},fitpar_1.bsig{2}];
            p1_alt=[fitpar_1_locfore.p{1},fitpar_1_locfore.bp{1}(1),fitpar_1_locfore.p{2},fitpar_1_locfore.bp{2}(1)];
            p1sig_alt=[fitpar_1_locfore.sig{1},fitpar_1_locfore.bsig{1}(1),fitpar_1_locfore.sig{2},fitpar_1_locfore.bsig{2}(1)];
            
            tol = [1e-10,1e-8];
            assertTrue(equal_to_tol(p1, p1_alt, tol),...
                'local background and local foreground equivalent fitting give different answers')
            assertTrue(equal_to_tol(p1sig, p1sig_alt, tol),...
                'local background and local foreground equivalent fitting give different answers')

            % Test against saved or store to save later; ingnore string
            % changes - these are filepaths
            assertEqualToTolWithSave (this, wfit_1, 'tol', tol, 'ignore_str', 1)
            assertEqualToTolWithSave (this, wfit_1_locfore, 'tol', tol, 'ignore_str', 1)
            assertEqualToTolWithSave (this, fitpar_1, 'tol', tol, 'ignore_str', 1)
            assertEqualToTolWithSave (this, fitpar_1_locfore, 'tol', tol,  'ignore_str', 1)
        end        
        
    end
end
