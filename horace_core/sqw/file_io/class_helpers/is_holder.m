classdef is_holder
    % Simple helper class to transfer insturment and sample information to
    % a client in homogeneous form
    %
    properties(Access=protected,Hidden=true)
        instrument_=[];
        sample_ = [];
        n_files_=0;
        set_samp_ = false;
        set_inst_ = false;
    end
    properties(Dependent)
        % property to keep instrument information
        instrument;
        % property to keep sample information
        sample;
        % number of files contributed into sqw file to change
        n_files;
        % boolean, indicating that this class has been generated to
        % set up sample
        setting_sampl;
        % boolean, indicating that this class has been generated to
        % set up instrument.
        setting_instr;
    end
    
    methods
        %
        function obj=is_holder(instr,sampl)
            % class constructor.
            % Usage:
            %>>obj=is_holder(instr,sampl)
            % where:
            %inst - the cellarray or array of instrument(s) to save.
            %       (can be empty if instrument is not intented to be set)
            %samp - the cellarray or array of sample(s) to save.
            %       (can be empty if sample is not intented to be set)
            nin = numel(instr);
            if nin  == 0
                obj.set_inst_ = false; % if instrument is empty, we are not setting it
                nin = 1;
            else
                obj.set_inst_ = true;
            end
            obj.instrument_=instr;
            obj.n_files_ = nin;
            
            nsa = numel(sampl);
            if nsa == 0
                obj.set_samp_ = false; % if sample is empty, we are not setting it
                nsa = 1;
            else
                obj.set_samp_ = true;
            end
            if nsa ~=1 && nin ~= 1 && nsa ~= nin
                error('SQW_FILE_IO:invalid_argument',...
                    ' number of samples %d and number of instruments %d have to be 1 or equal to each other',...
                    nsa,nin);
            end
            obj.sample_ =sampl;
            if nsa ~= 1
                obj.n_files_ = nsa;
            end
        end
        %
        function is= is_empty(obj)
            % checks if the class is empty, e.g. not contains neither
            % sample not the instrument.
            if isempty(obj.instrument_) && isempty(obj.sample_)
                is = true;
            else
                is = false;
            end
        end
        %
        function ins = get.instrument(obj)
            % returns instrument(s) stored by the class or empty structure if
            % the instrument has not been stored
            if isempty(obj.instrument_)
                ins  = struct();
            else
                if obj.n_files_ ~= numel(obj.instrument_)
                    ins = repmat(obj.instrument_(1),1,obj.n_files_);
                else
                    ins = obj.instrument_;
                end
            end
        end
        %
        function sam = get.sample(obj)
            % returns sample(s) stored by the class or empty structure if
            % the instrument has not been stored
            
            if isempty(obj.sample_)
                sam  = struct();
            else
                if obj.n_files_ ~= numel(obj.sample_)
                    sam = repmat(obj.sample_(1),1,obj.n_files_);
                else
                    sam = obj.sample_;
                end
            end
        end
        %
        function nsa = get.n_files(obj)
            nsa = obj.n_files_;
        end
        function obj = set.n_files(obj,val)
            obj.n_files_ = val;
        end
        %
        function set = get.setting_sampl(obj)
            set = obj.set_samp_;
        end
        function set = get.setting_instr(obj)
            set = obj.set_inst_;
        end
        
        %
    end
    
end

