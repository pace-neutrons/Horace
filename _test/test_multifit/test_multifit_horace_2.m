classdef test_multifit_horace_2< TestCaseWithSave
    % Performs some tests of fitting to Horace objects using multifit_sqw and other functions.
    % Optionally writes results to output file
    %
    %   >>runtests test_multifit_horace_2            % Compares with previously saved results in test_multifit_horace_1_output.mat
    %                                        % in the same folder as this function
    %   >>save(test_multifit_horace_2())    % Save to test_multifit_horace_1_output.mat
    %
    %   >>test_name(test_multifit_horace_2()) % run particular test from this
    %
    % Reads previously created test data sets.
    properties
        test_data_path;
        sd;  % source data for fitting
        w1data;
        w2data;
        win;
    end
    
    methods
        function this=test_multifit_horace_2(varargin)
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this = this@TestCaseWithSave(name,fullfile(fileparts(mfilename('fullpath')),'test_multifit_horace_2_output.mat'));
            
            this.comparison_par={ 'min_denominator', 0.01, 'ignore_str', 1};
            %this.tol = 1.e-8;
            
            demo_dir=fileparts(mfilename('fullpath'));
            
            % Read in data
            % ------------
            this.w1data=read_sqw(fullfile(demo_dir,'w1data.sqw'));
            this.w2data=read_sqw(fullfile(demo_dir,'w2data.sqw'));
            
            
            % Combine the two cuts into an array of sqw objects and fit
            % ---------------------------------------------------------
            % The data were created using the cross-section model that is fitted shortly,
            % with parameters [5,5,1,20,0], random noise added and then a background of
            % 0.01 and 0.02 to the first and second data sets. That is, when the fit is
            % performed, we expect the results [5,5,1,20,0.01] and [5,5,1,20,0.02]
            
            % Perform a fit that constrains the first two parameters (gap and J) to be
            % the same in both data sets, but allow the intensity and gamma to vary
            % independently. A constant background can also vary independently.
            
            this.win=[this.w1data,this.w2data];
            
        end
        function this=test_fit(this)
            % fit
            [wfit_1,fitpar_1]=multifit_sqw_sqw(this.win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
                @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}});
            
            % fit using new local foreground model
            [wfit_1_locfore,fitpar_1_locfore]=multifit_sqw(this.win, @sqw_bcc_hfm_no_bkgd, {[5,5,1.2,10],[5,5,1.4,15]}, [], {{},{{1,1,-1},{2,2,-1}}},...
                @linear_bkgd, [0,0], [1,0], 'local_fore');
            
            % Check fit parameter values
            p1=[fitpar_1.bp{1},fitpar_1.bp{2}];
            p1sig=[fitpar_1.bsig{1},fitpar_1.bsig{2}];
            p1_alt=[fitpar_1_locfore.p{1},fitpar_1_locfore.bp{1}(1),fitpar_1_locfore.p{2},fitpar_1_locfore.bp{2}(1)];
            p1sig_alt=[fitpar_1_locfore.sig{1},fitpar_1_locfore.bsig{1}(1),fitpar_1_locfore.sig{2},fitpar_1_locfore.bsig{2}(1)];
            
            tol=-1e-8;
            assertTrue(equal_to_tol(p1, p1_alt, tol, 'min_denominator', 0.01),'local background and local foreground equivalent fitting give different answers');
            assertTrue(equal_to_tol(p1sig, p1sig_alt, tol, 'min_denominator', 0.01),'local background and local foreground equivalent fitting give different answers')
            % Test against saved or store to save later
            this=test_or_save_variables(this,wfit_1,wfit_1,wfit_1_locfore,fitpar_1_locfore);           

        end        
        
    end
end