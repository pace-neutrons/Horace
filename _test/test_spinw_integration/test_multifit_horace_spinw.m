classdef test_multifit_horace_spinw< TestCaseWithSave
    % Performs some tests of fitting to Horace objects using multifit_sqw and other functions.
    % Optionally writes results to output file
    %
    %   >>runtests test_multifit_horace_spinw            % Compares with previously saved results in test_multifit_horace_spinw_output.mat
    %                                        % in the same folder as this function
    %   >>save(test_multifit_horace_spinw())    % Save to test_multifit_horace_spinw_output.mat
    %
    %   >>test_name(test_multifit_horace_spinw()) % run particular test from this
    %
    % Reads previously created test data sets.
    properties
        test_data_path;
        sd;  % source data for fitting
        w1data;
        w2data;
        win;
        sbcc;        % SpinW object
    end
    
    methods
        function this=test_multifit_horace_spinw(varargin)
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this = this@TestCaseWithSave(name,fullfile(fileparts(mfilename('fullpath')),'test_multifit_horace_1_output.mat'));
            
            this.comparison_par={ 'min_denominator', 0.1, 'ignore_str', 1, 'nan_equal', 1};
            this.tol = 1.e-2;
            
            demo_dir=fileparts(mfilename('fullpath'));
            
            % Read in data
            % ------------
            this.w1data=read_sqw(fullfile(demo_dir,'w1data.sqw'));
            this.w2data=read_sqw(fullfile(demo_dir,'w2data.sqw'));
            
            % Setup SpinW
            % -----------
            try
                try
                    this.sbcc = sw;
                catch
                    % spinW version 3 naming convention.
                    this.sbcc = spinw;
                end
            catch
                warning('Cannot initialize spinW object. No test run');
                return;
            end
            sbcc=this.sbcc;
            S=2.5;    % Fe3+
            sbcc.fileid(0);   % Silences information text from SpinW to commandline window
            sbcc.genlattice('lat_const',[1 1 1]*2.886,'angle',[90 90 90]*pi/180,'sym','I m -3 m');  % bcc Fe
            sbcc.addatom('r',[0 0 0]','S',[S],'label',{'Fe'});
            sbcc.gencoupling('maxDistance',5);
            sbcc.addmatrix('mat',eye(3),'label',{'J1'},'color',[0; 255; 255]);       sbcc.addcoupling('mat','J1','bond',1);
            sbcc.addmatrix('mat',diag([0 0 -1]),'color', [255; 0; 0],'label',{'D'}); sbcc.addaniso('D');
            sbcc.genmagstr('mode','direct','S',[0 0 1; 0 0 1]');  % Ferromagnetic
            sbcc = spinw_setpar(sbcc,'mapping',{'D(3,3)','J1'},'hermit',false,'convolvfn',@spinw_gauss_sqw,'useMex',true);
            % We want to use the same parameter numbers as disp_bcc_hfm (gap energy and J*S)
            % so need to scale D,J and intensity by 1/S, and additionally, D by half.
            sbcc = spinw_setpar(sbcc,'partrans',@(x)x./[2*S S S 1 1]);
               
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
        function this=test_fit_morethenone(this)
            % ------------------------------------------------------------------------------------------------
            % Example of fitting more than one sqw object
            % -------------------------------------------------------------------------------------------------
            if isempty(this.sbcc)
                return
            end
            % This will take a long time with your cross-section... first the evaluation of the initial conditions
            wsim_1=multifit_sqw_sqw(this.win, @spinw_sqw, {[5,5,0,10,0] this.sbcc}, [1,1,0,0,0],...
                @spinw_sqw, {{[5,5,1.2,10,0] this.sbcc},{[5,5,1.4,15,0] this.sbcc}}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}}, 'evaluate' );
            
            % acolor b r  % Set colours to blue followed by red; repeats this in succession if more than two objects in an array
            % dp(this.win)     % Draw Points
            % pl(wsim_1)  % Plot Line
            
            % and now the fit
            [wfit_1,fitpar_1]=multifit_sqw_sqw(this.win, @spinw_sqw, {[5,5,0,10,0] this.sbcc}, [1,1,0,0,0],...
                @spinw_sqw, {{[5,5,1.2,10,0],this.sbcc},{[5,5,1.4,15,0],this.sbcc}}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}});
            % Test against saved or store to save later
            % Test only against simulated spectra from analytical calculations, because fit parameters differ significantly due
            % to accumulation of numerical errors in diagonalisation procedure.
            this=save_or_test_variables(this,wsim_1);
            tol = this.tol;
            this.tol = -1;  
            this=save_or_test_variables(this,wfit_1,fitpar_1);
            this.tol = tol;
            % acolor b r  % Set colours to blue followed by red; repeats this in succession if more than two objects in an array
            % dp(this.win)     % Draw Points
            % pl(wfit_1)  % Plot Line
        end
        
        function this=test_fit_averg_hkl(this)
            if isempty(this.sbcc)
                return
            end
            % This will be faster, because it gets the average h,k,l,e for all data pixels in a bin
            % and evaluates only at that point. The final answer will be a little different of course -
            % the extent will be dependent on how rapidly your dispersion function varies, and how big your
            % bins are in the cut.
            wsim_2=multifit_sqw_sqw(this.win, @spinw_sqw, {[5,5,0,10,0] this.sbcc}, [1,1,0,0,0],...
                @spinw_sqw, {{[5,5,1.2,10,0],this.sbcc},{[5,5,1.4,15,0],this.sbcc}}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}}, 'evaluate', 'ave' );
            
            [wfit_2,fitpar_2]=multifit_sqw_sqw(this.win, @spinw_sqw, {[5,5,0,10,0] this.sbcc}, [1,1,0,0,0],...
                @spinw_sqw, {{[5,5,1.2,10,0],this.sbcc},{[5,5,1.4,15,0],this.sbcc}}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}}, 'ave' );
            % Test against saved or store to save later
            this=save_or_test_variables(this,wsim_2);
            tol = this.tol;
            this.tol = -1;  
            this=save_or_test_variables(this,wfit_2,fitpar_2);
            this.tol = tol;
            % acolor b r  % Set colours to blue followed by red; repeats this in succession if more than two objects in an array
            % dp(this.win)     % Draw Points
            % pl(wfit_2)  % Plot Line
            
        end
        % ------------------------------------------------------------------------------------------------
        % Example of fitting single dataset or independently fitting an array of datasets
        % -------------------------------------------------------------------------------------------------
        function this=test_fit_single_or_array(this)
            if isempty(this.sbcc)
                return
            end
            % Check fit_sqw correctly fits array of input
            [wfit_single1,fitpar_single1]=fit_sqw(this.w1data, @spinw_sqw, {[5,5,1,10,0] this.sbcc}, [0,1,1,1,1], @linear_bkgd, [0,0]);
            
            [wfit_single2,fitpar_single2]=fit_sqw(this.w2data, @spinw_sqw, {[5,5,1,10,0] this.sbcc}, [0,1,1,1,1], @linear_bkgd, [0,0]);
            [wfit_single12,fitpar_single12]=fit_sqw(this.win, @spinw_sqw, {[5,5,1,10,0] this.sbcc}, [0,1,1,1,1], @linear_bkgd, [0,0]);
            
            assertTrue(equal_to_tol([wfit_single1,wfit_single2],wfit_single12),'fit_sqw workspaces not working');
            assertTrue(equal_to_tol([fitpar_single1,fitpar_single2],fitpar_single12),'fit_sqw fitting not working')
            
            % Test against saved or store to save later
            this=save_or_test_variables(this,wfit_single1,wfit_single2,wfit_single12);
            
        end

        function this=test_fit_single_or_array2(this)
            if isempty(this.sbcc)
                return
            end
        
            [wfit_single12,fitpar_single12]=fit_sqw(this.win, @spinw_sqw, {[5,5,1,10,0.05] this.sbcc}, [0,1,1,1,1], @linear_bkgd, [0,0]);
            
            [wfit_single1,fitpar_single1]=multifit_sqw(this.w1data, @spinw_sqw, {[5,5,1,10,0.05] this.sbcc}, [0,1,1,1,1], @linear_bkgd, [0,0]);
            [wfit_single2,fitpar_single2]=multifit_sqw(this.w2data, @spinw_sqw, {[5,5,1,10,0.05] this.sbcc}, [0,1,1,1,1], @linear_bkgd, [0,0]);
            
            assertTrue(equal_to_tol([wfit_single1,wfit_single2],wfit_single12),'fit_sqw not working for dataset');
            assertTrue(equal_to_tol([fitpar_single1,fitpar_single2],fitpar_single12),'fit_sqw not working for fit parameters');
            
            fitpar_single1.corr=[];
            fitpar_single2.corr=[];
            fitpar_single12(1).corr=[];
            fitpar_single12(2).corr=[];
            
            tol = this.tol;
            this.tol = -1;
            % Error values on background is very large due to background being near zero... ignore it.
            fitpar_single1.sig(5)=NaN;     this.old.fitpar_single1.sig(5)=NaN; 
            fitpar_single2.sig(5)=NaN;     this.old.fitpar_single2.sig(5)=NaN; 
            fitpar_single12(1).sig(5)=NaN; this.old.fitpar_single12(1).sig(5)=NaN; 
            fitpar_single12(2).sig(5)=NaN; this.old.fitpar_single12(2).sig(5)=NaN;
            fitpar_single1.p(5)=NaN;       this.old.fitpar_single1.p(5)=NaN;
            fitpar_single12(1).p(5)=NaN;   this.old.fitpar_single12(1).p(5)=NaN;
            fitpar_single1.bp(1)=NaN;      this.old.fitpar_single1.bp(1)=NaN;
            fitpar_single12(1).bp(1)=NaN;  this.old.fitpar_single12(1).bp(1)=NaN;
            this=save_or_test_variables(this,fitpar_single1,fitpar_single2,fitpar_single12);
            this.tol=tol;
            %
            
        end

        function this=test_multifit_single_or_array(this)
            if isempty(this.sbcc)
                return
            end
            % Check fit_sqw_sqw behaves as is should
            [wfit_sqw_sqw,fitpar_sqw_sqw]=fit_sqw_sqw(this.win, @spinw_sqw, {[5,5,1,10,0] this.sbcc}, ...
                [0,1,1,1,0], @spinw_sqw, {[5,5,0,1,0] this.sbcc}, [0,0,0,0,1]);
            [tmp1,ftmp1]=multifit_sqw_sqw(this.w1data, @spinw_sqw, {[5,5,1,10,0] this.sbcc}, [0,1,1,1,1]);
            [tmp2,ftmp2]=multifit_sqw_sqw(this.w2data, @spinw_sqw, {[5,5,1,10,0] this.sbcc}, [0,1,1,1,1]);
            assertTrue(equal_to_tol([tmp1,tmp2],wfit_sqw_sqw,-1e-8),'fit_sqw_sqw not working')
            
            % Test against saved or store to save later
            this=save_or_test_variables(this,wfit_sqw_sqw);
            tol = this.tol;
            this.tol = -1;  
            this=save_or_test_variables(this,fitpar_sqw_sqw);
            this.tol = tol;
        end
    end
end
