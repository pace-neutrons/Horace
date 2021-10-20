classdef planner_config < config_base
    % Class defines configuration of horace_planner
    %
    % To see the list of current configuration option values:
    %   >> planner_config
    %
    % To set values:
    %   >> pc = planner_config();
    %   >> pc.name1=val1;
    % or
    %   >> set(planner_config,'name1',val1,'name2',val2,...)
    %
    %
    % To fetch values:
    % >> pc = planner_config();
    % >> val1 = pc.name1;
    %or
    % >>[val1,val2,...]=get(planner_config,'name1','name2',...)
    %
    %
    %hor_config methods are:
    % -----------
    %   par_file          - The full path to the file, containing detector
    %                       positions (par file)
    %
    properties(Dependent)
        par_file         % The file containing detector positions
        u                % 3-vector along beam direction
        v
        ei
        en_transf
        psimin
        psimax
        alatt
        angdeg
        latpt
    end
    properties(Access=protected, Hidden=true)
        % private properties behind public interface
        par_file_ = '';
        u_ = [1,0,0];
        v_ = [0,1,0];
        ei_= 100;
        en_transf_ = 50;
        psimin_ = 0;
        psimax_ = 90;
        alatt_=[2.83,2.83,2.93];
        angdeg_=[90,90,90];
        latpt_ = [1,1,1];
    end
    
    properties(Constant, Access=private)
        % change this list if saveable fields have changed or redefine
        % get_storage_field_names function below
        saved_properties_list_ = {...
            'par_file','u','v','ei','en_transf', 'psimin','psimax',...
            'alatt','angdeg','latpt'};
    end
    
    methods
        function obj=planner_config()
            obj=obj@config_base(mfilename('class'));
        end
        
        %-----------------------------------------------------------------
        % overloaded getters
        function par = get.par_file(this)
            par = get_or_restore_field(this,'par_file');
        end
        function u = get.u(this)
            u = get_or_restore_field(this,'u');
        end
        function v = get.v(this)
            v = get_or_restore_field(this,'v');
        end
        function ei = get.ei(this)
            ei = get_or_restore_field(this,'ei');
        end
        function en = get.en_transf(this)
            en = get_or_restore_field(this,'en_transf');
        end
        function psimin = get.psimin(this)
            psimin = get_or_restore_field(this,'psimin');
        end
        function psimax = get.psimax(this)
            psimax= get_or_restore_field(this,'psimax');
        end
        function alatt = get.alatt(this)
            alatt= get_or_restore_field(this,'alatt');
        end
        function angdeg = get.angdeg(this)
            angdeg= get_or_restore_field(this,'angdeg');
        end
        function latpt = get.latpt(this)
            latpt= get_or_restore_field(this,'latpt');
        end
        %-----------------------------------------------------------------
        % overloaded setters
        function obj = set.par_file(obj,val)
            if ~(ischar(val) || is_string(val))
                error('HORACE:planner_config:invalid_argument',...
                    'The input file should be a string containing full file name. Actually it is: %s',...
                    evalc('disp(val)'));
            end
            config_store.instance().store_config(obj,'par_file',val);
        end
        function obj=set.u(obj,val)
            if ~isnumeric(val) || numel(val) ~=3
                error('HORACE:planner_config:invalid_argument',...
                    'The input u should be numeric 3-vector. Actually it is: %s',...
                    evalc('disp(val)'));
            end
            config_store.instance().store_config(obj,'u',val);
        end
        function obj=set.v(obj,val)
            if ~isnumeric(val) || numel(val) ~=3
                error('HORACE:planner_config:invalid_argument',...
                    'The input v should be numeric 3-vector. Actually it is: %s',...
                    evalc('disp(val)'));
            end
            config_store.instance().store_config(obj,'v',val);
        end
        function obj=set.ei(obj,val)
            if ~isnumeric(val) || val<=0 || numel(val)>1
                error('HORACE:planner_config:invalid_argument',...
                    'The input Ei should be single positive number. Actually it is: %s',...
                    evalc('disp(val)'));
            end
            config_store.instance().store_config(obj,'ei',val);
        end
        function obj=set.en_transf(obj,val)
            if ~isnumeric(val) || numel(val)>1
                error('HORACE:planner_config:invalid_argument',...
                    'The input en_transf should be signle number. Actually it is: %s',...
                    evalc('disp(val)'));
            end
            config_store.instance().store_config(obj,'en_transf',val);
        end
        function obj=set.psimin(obj,val)
            if ~isnumeric(val) || numel(val)>1
                error('HORACE:planner_config:invalid_argument',...
                    'The input psimin should be signle number. Actually it is: %s',...
                    evalc('disp(val)'));
            end
            config_store.instance().store_config(obj,'psimin',val);
        end
        function obj=set.psimax(obj,val)
            if ~isnumeric(val) || numel(val)>1
                error('HORACE:planner_config:invalid_argument',...
                    'The input psimax should be signle number. Actually it is: %s',...
                    evalc('disp(val)'));
            end
            config_store.instance().store_config(obj,'psimax',val);
        end
        function obj=set.alatt(obj,val)
            if ~isnumeric(val) || numel(val) ~=3
                error('HORACE:planner_config:invalid_argument',...
                    'The input alatt should be numeric 3-vector. Actually it is: %s',...
                    evalc('disp(val)'));
            end
            config_store.instance().store_config(obj,'alatt',val);
        end
        function obj=set.angdeg(obj,val)
            if ~isnumeric(val) || numel(val) ~=3
                error('HORACE:planner_config:invalid_argument',...
                    'The input angdeg should be numeric 3-vector. Actually it is: %s',...
                    evalc('disp(val)'));
            end
            config_store.instance().store_config(obj,'angdeg',val);
        end
        function obj=set.latpt(obj,val)
            if ~isnumeric(val) || numel(val) ~=3
                error('HORACE:planner_config:invalid_argument',...
                    'The input latpt should be numeric 3-vector. Actually it is: %s',...
                    evalc('disp(val)'));
            end
            config_store.instance().store_config(obj,'latpt',val);
        end
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function fields = get_storage_field_names(this)
            % helper function returns the list of the public names of the fields,
            % which should be saved
            fields = this.saved_properties_list_;
        end
        %
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface.
            % Relies on assumption, that each public
            % field has a private field with name different by underscore
            value = this.([field_name,'_']);
        end
        
    end
end
