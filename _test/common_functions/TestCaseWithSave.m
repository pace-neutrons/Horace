classdef TestCaseWithSave < TestCase
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        old=[];  % old dataset one comares against
        tol = 1.e-8; % accuracy of the test

        results_path ='';
        results_filename='results_to_compare_with.mat';
        
        want_to_save_output=false; % if we want test results or save them as example to test against it later. 
        datasets_to_save;          % cellarray of the datasets prepared for saving.        
        % addotopma; parameters for equal_to_tol function
        comparison_par={'min_denominator', 0.01};
        filelist_toclear={};
        path_toclear={};
    end
    
    methods
        function this=TestCaseWithSave(varargin)
         % constructor

            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this = this@TestCase(name);
            if nargin>1
                inputFile = varargin{2};
                [this.results_path,this.results_filename]=fileparts(inputFile);
            else
                this.results_path=fileparts(mfilename('fullpath'));                                
                inputFile = fullfile(this.results_path,this.results_filename);
            end
                                   
            this.want_to_save_output=false;            
           % load old data if necessary
            if not(this.want_to_save_output) && exist(inputFile,'file')
                this.old=load(inputFile);
            end
            this.datasets_to_save=struct();
            
        end
        %------------------------------------------------------------------        
        function rm_files(this,varargin)
            for i=1:numel(varargin)
                if exist(varargin{i},'file')
                    delete(varargin{i});
                end
            end
        end
        %------------------------------------------------------------------        
        function delete(this)
            warn=warning('off','all'); 
            rm_files(this,this.filelist_toclear{:});

            for i=1:numel(this.path_toclear)       
                rmpath(this.path_toclear{i});  
            end
            warning(warn);  
        end
        %------------------------------------------------------------------
        function this=add_to_files_cleanList(this,varargin)
           this.filelist_toclear=add_data_to_list(this.filelist_toclear,varargin{:});             
        end
        %
        function this=add_to_path_cleanList(this,varargin)        
            this.path_toclear= add_data_to_list(this.path_toclear,varargin{:});           
        end
        %------------------------------------------------------------------               
        function this=test_or_save_variables(this,varargin)
            % method to test input variable in vararging agains saved
            % values or save these variables to the structure to save it
            % later (or deal with them any other way)
            for i=1:numel(varargin)
                if not(this.want_to_save_output)
                    [ok,mess]=equal_to_tol(varargin{i}, this.old.(inputname(i+1)), this.tol,this.comparison_par{:});
                    assertTrue(ok,['[',inputname(i+1),'] :',mess])
                else
                    this.datasets_to_save.(inputname(i+1))=varargin{i};
                end
            end
        end
        %------------------------------------------------------------------       
        function save(this)
            % save fitting output to the file to test against it later
            if get(herbert_config,'log_level')>-1
                disp('===========================')
                disp('    Save output')
                disp('===========================')
            end
            meth=methods(this);
            ometha = metaclass(this);            
            class_name =ometha.Name;
            % select the methods which are the tests among all test methods
            istests = cellfun(@(x)( ~isempty(regexp(x,'^test_','once')) && ~strcmpi(x,class_name)),meth);
            test_methods=meth(istests);
            % indicate that you want to store results of the test rather
            % then testing them agains results, saved earlier. 
            % Check for that is in test_or_save_variables
            this.want_to_save_output=true;
            % run test methods
            for i=1:numel(test_methods)
                fh=@(x)this.(test_methods{i});
                fh(this);
            end
            
            % save results
            output_file=fullfile(tempdir(),this.results_filename);
            dsts=this.datasets_to_save;
            names = fieldnames(dsts);
            save(output_file,'-struct','dsts',names{:})
            
            if get(herbert_config,'log_level')>-1
                disp(' ')
                disp(['Output saved to ',output_file])
                disp(' ')
            end            
        end
        %------------------------------------------------------------------             
        function this=subsasgn(this,S,B) 
            % old matlabs do not understand private field. 
            if any(ismemmber(S.subs,'results_filename'))
                error('TestCaseWithSave:privare_field','Can not change results_filename');
            end
            builtin('subassign',this,S,B);
        end
    end
    
end

