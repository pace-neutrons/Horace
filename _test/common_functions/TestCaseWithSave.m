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
        % the string printed in the case of errors in
        % test_or_save_variables intended to provide additional information
        % about the error (usually set in front of test_or_save_variables)
        errmessage_prefix = ''
        % the classes which are currently changing so should be stored
        % differently -- some fields or class definition may change.
        transient_classes={'sqw','dnd','data_sqw_dnd','d1d','d2d','d3d','d4d'};
        convert_class_funs;
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
            %----------------------------------------------------------
            % TRANSIENT OPERATION! necessary (and valid) until data
            % class changes are not completed
            this.convert_class_funs{1} = @(x)(convert_old_sqw_to_new_sqw(this,x));
            this.convert_class_funs{2} = @(x)(convert_old_dnd_to_new_dnd(this,x));
            this.convert_class_funs{3} = @(x)(convert_old_data_sqw_dnd(this,x));
            this.convert_class_funs{4} = @(x)(convert_old_d1d(this,x));
            this.convert_class_funs{5} = @(x)(convert_old_d2d(this,x));
            this.convert_class_funs{6} = @(x)(convert_old_d3d(this,x));
            this.convert_class_funs{7} = @(x)(convert_old_d4d(this,x));
            
            this.want_to_save_output=false;
            
            % load old data if necessary
            if not(this.want_to_save_output) && exist(inputFile,'file')
                this.old=load(inputFile);
            end
            this.datasets_to_save=struct();
            
        end
        %------------------------------------------------------------------
        function new_sqw=convert_old_sqw_to_new_sqw(this,old_sqw)
            old_data = struct(old_sqw.data);
            
            if isfield(old_data,'axis_caption_fun')
                old_data= rmfield(old_data,'axis_caption_fun');
            end
            new_data = data_sqw_dnd(old_data);
            old_sqw.data = new_data;
            new_sqw = old_sqw;
        end
        function new_dnd=convert_old_dnd_to_new_dnd(this,old_dnd)
            old_data = struct(old_dnd);
            
            if isfield(old_data,'axis_caption_fun')
                old_data= rmfield(old_data,'axis_caption_fun');
            end
            new_dnd = dnd(old_data);
        end
        function new_data=convert_old_data_sqw_dnd(this,old_data_cl)
            old_data = struct(old_data_cl);
            
            if isfield(old_data,'axis_caption_fun')
                old_data= rmfield(old_data,'axis_caption_fun');
            end
            new_data = data_sqw_dnd(old_data);
        end
        function new_dnd=convert_old_d1d(this,old_d1d)
            old_data = struct(old_d1d);
            
            if isfield(old_data,'axis_caption_fun')
                old_data= rmfield(old_data,'axis_caption_fun');
            end
            new_dnd = d1d(old_data);
        end
        function new_dnd=convert_old_d2d(this,old_d2d)
            old_data = struct(old_d2d);
            
            if isfield(old_data,'axis_caption_fun')
                old_data= rmfield(old_data,'axis_caption_fun');
            end
            new_dnd = d2d(old_data);
        end
        function new_dnd=convert_old_d3d(this,old_d3d)
            old_data = struct(old_d3d);
            
            if isfield(old_data,'axis_caption_fun')
                old_data= rmfield(old_data,'axis_caption_fun');
            end
            new_dnd = d3d(old_data);
        end
        function new_dnd=convert_old_d4d(this,old_d4d)
            old_data = struct(old_d4d);
            
            if isfield(old_data,'axis_caption_fun')
                old_data= rmfield(old_data,'axis_caption_fun');
            end
            new_dnd = d4d(old_data);
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
            keys = {'ignore_str','nan_equal','min_denominator','tol','convert_old_classes'};
            [keyval,ws_list] = extract_keyvalues(varargin,keys);
            if numel(ws_list) == 0
                return;
            end
            
            % function decides if the variable equal to tol
            f_tol_present = @(var)(isstring(var)&&strcmp(var,'tol'));
            % check if var 'tol' among the input arguments
            tol_provided = cellfun(f_tol_present,keyval);
            if any(tol_provided)
                itol = find(tol_provided);
                toll = keyval{itol+1};
                tol_provided(itol+1)=true;
                keyval = keyval(~tol_provided);
            else
                toll = this.tol;
            end
            
            f_mind_present = @(var)(isstring(var)&&strcmp(var,'min_denominator'));
            mind_provided = cellfun(f_mind_present,keyval);
            
            if ~any(mind_provided)
                if numel(keyval)>0
                    keyval = [keyval(:);this.comparison_par(:)];
                else
                    keyval = this.comparison_par;
                end
            end
            % check if old class conversion is requested
            tmp_str = cellfun(@(x)(num2str(x)),keyval,'UniformOutput',false);
            convert_old_class_place  = ismember(tmp_str,'convert_old_classes');
            if any(convert_old_class_place)
                keyval = keyval(~convert_old_class_place);
                convert_old=true;
            else
                convert_old=false;
            end
            
            
            
            for i=1:numel(ws_list)
                if not(this.want_to_save_output)
                    ref_data = this.old.(inputname(i+1));
                    if convert_old
                        class_name = class(ws_list{i});
                        class_to_convert_found = ismember(this.transient_classes,class_name);
                        if any(class_to_convert_found)
                            convertor = this.convert_class_funs{class_to_convert_found};
                            ref_data = convertor(ref_data);
                        end
                        
                    end
                    [ok,mess]=equal_to_tol(ws_list{i}, ref_data,toll,keyval{:});
                    
                    assertTrue(ok,[this.errmessage_prefix,': [',inputname(i+1),'] :',mess])
                else
                    this.datasets_to_save.(inputname(i+1))=ws_list{i};
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
        %         function this=subsasgn(this,S,B)
        %             % old matlabs do not understand private field.
        %             if any(ismember(S.subs,'results_filename'))
        %                 error('TestCaseWithSave:privare_field','Can not change results_filename');
        %             end
        %             builtin('subassign',this,S,B);
        %         end
    end
    
end

