classdef main_header_cl < serializable
    % Class describes the main header of the Horace sqw object
    %
    % NOTE:
    % In addition to containing the file creation information, the class
    % is designed to maintain the proper file creation date.
    % To set up file creation date, actual creation date have to be
    % assigned to the obj.creation_date  property. Then the date becames
    % defined and maintained in various class load/save operations.
    %
    % e.g:
    %  >> obj = main_header_cl();
    %  >> now = obj.creation_date;
    %  >> obj.creation_date = now;
    %
    % The pattern should be used to set up the file creation date in all
    % algorithms, intended to create new sqw files
    %
    % Construct an instanciation of main header class
    %
    % obj = main_header_cl();
    % obj = main_header_cl(filename);
    % obj = main_header_cl(filename,filepath);
    % obj = main_header_cl(filename,filepath,title);
    % obj = main_header_cl(filename,filepath,title,nfiles);
    %OR:
    % obj = main_header_cl(cl_struc);
    % where cl_struc is the structure, containing any set of public
    % properties available to contructor with their correspondent values
    %

    properties(Dependent)
        % the properties describe the header structure
        filename; % the name of the file, where the
        filepath; % the path, where the file has been initially created
        title;    % title (description) of the sqw object
        nfiles;   % number of runs contributed into the sqw file this header
        %           is responsible for

        creation_date; % The date when this header (in the sqw file) was created

        % method returns false, if the file creation date is not stored
        % together with binary data in old binary files
        creation_date_defined;
    end
    properties(Dependent,Hidden)
        % return filename mangled with the creation date, used to write
        % creation date together with filename in old style v3 binary
        % Horace files
        filename_with_cdate;
        % hidden property allowing save/restore creation_date_defined
        % property used by loadobj/saveobj methods only
        creation_date_defined_privately;
    end

    properties(Access = protected)
        filename_ = '';
        filepath_ = '';
        title_    = '';
        nfiles_   = 0;
        creation_date_ = '';
        creation_date_defined_ = false;
    end

    properties(Constant)
        dt_format = 'yyyy-mm-ddTHH:MM:SS';
    end

    methods
        function obj = main_header_cl(varargin)
            % Construct an instance of main header class
            %
            % obj = main_header();
            % obj = main_header(filename);
            % obj = main_header(filename,filepath);
            % obj = main_header(filename,filepath,title);
            % obj = main_header(filename,filepath,title,nfiles);

            switch nargin
                case 0
                    return;
                case 1
                    arg = varargin{1};

                    if isa(arg,'main_header')
                        obj = arg;
                    elseif isstruct(arg)
                        obj = serializable.from_struct(arg,obj);
                        if isfield(arg,'filename_with_cdate')
                            obj.filename_with_cdate = arg.filename_with_cdate;
                        end
                    elseif ischar(arg)
                        obj.filename = arg;
                    else
                        error('HORACE:main_header:invalid_argument',...
                            'Can not construct main header from parameter %s',...
                            evalc('disp(arg))'))
                    end
                otherwise
                    param_names_list = obj.saveableFields();
                    [obj,remains] = obj.set_positional_and_key_val_arguments(...
                        param_names_list(1:4),false,varargin{:});

                    if ~isempty(remains)
                        error('HORACE:main_header:invalid_argument',...
                            'Too many arguments provided on instantiation, excess args: %s', evalc('disp(remains)'))
                    end
            end
        end

        function tit = get.title(obj)
            tit = obj.title_;
        end

        function obj = set.title(obj,val)
            if ~(ischar(val) || isstring(val))
                error('HORACE:main_header:invalid_argument', ...
                    'Bad title (%s). title must be string or char array.', ...
                    evalc('disp(val)'));
            end
            obj.title_ = val;
        end

        function tit = get.filename(obj)
            tit = obj.filename_;
        end

        function obj = set.filename(obj,val)
            if ~(ischar(val) || isstring(val))
                error('HORACE:main_header:invalid_argument', ...
                    'Bad filename (%s). filename must be string or char array.', ...
                    evalc('disp(val)'));
            end
            obj.filename_ = val;
        end

        function tit = get.filepath(obj)
            tit = obj.filepath_;
        end

        function obj = set.filepath(obj,val)
            if ~(ischar(val) || isstring(val))
                error('HORACE:main_header:invalid_argument', ...
                    'Bad filepath (%s). filepath must be string or char array.', ...
                    evalc('disp(val)'));
            end
            obj.filepath_ = val;
        end

        function nf = get.nfiles(obj)
            nf = obj.nfiles_;
        end

        function obj = set.nfiles(obj,val)
            if ~isnumeric(val) || val<0 || ~isscalar(val)
                error('HORACE:main_header:invalid_argument', ...
                    'Bad nfiles (%s). Number of files must be a non-negative scalar numeric value.',...
                    evalc('disp(val)'));
            end
            obj.nfiles_ = val;
        end

        %------------------------------------------------------------------

        function cd = get.creation_date(obj)
            % Retrieve file creation date either from stored value, or
            % from system file date.
            if obj.creation_date_defined_
                dt = obj.convert_datetime_from_str(obj.creation_date_);
            else % assume that creation date is unknown and
                % will be set as creation date of the file later and
                % explicitly.
                % Return either file date if file exist or
                % actual date, if it does not
                file = fullfile(obj.filepath,obj.filename);

                if ~isfile(file)
                    dt = datetime("now");
                else
                    finf= dir(file);
                    dt = datetime(finf.date);
                end

            end
            cd = obj.DT_out_transf_(dt);
        end

        function obj = set.creation_date(obj,val)
            % explicitly set up creation date and make it "known"
            if ischar(val)
                dt = obj.convert_datetime_from_str(val);
            elseif isa(val,'datetime')
                dt  = val;
            else
                error('HORACE:main_header:invalid_argument', ...
                    'Bad creation date (%s). File creation date must be datetime class or string, compatible with datetime function according to format %s.', ...
                    evalc('disp(val)'), obj.dt_format);
            end

            obj.creation_date_    = dt;
            obj.creation_date_defined_ = true;
        end

        function is = get.creation_date_defined(obj)
            is = obj.creation_date_defined_;
        end

        %------------------------------------------------------------------
        % hidden properties, do not use unless understand deeply why they
        % are here
        function is = get.creation_date_defined_privately(obj)
            is = obj.creation_date_defined_;
        end

        function obj = set.creation_date_defined_privately(obj,val)
            obj.creation_date_defined_ = logical(val);
        end

        %------------------------------------------------------------------
        % sqw_binfile_common interface
        %------------------------------------------------------------------
        function fnc = get.filename_with_cdate(obj)
            % this method is used to mangle filename with file creation
            % date and used to save them in a Horace binary file
            % version 3.XXX and lower
            if obj.creation_date_defined_
                fnc = [obj.filename,'$',obj.creation_date];
            else
                % if creation date have not been defined, get only filename
                fnc = obj.filename;
            end
        end

        function obj = set.filename_with_cdate(obj,val)
            % Take filename and file creation date as it would be
            % stored in Horace binary file version 3.xxxx, separate it into parts
            % and set parts as appropriate properties of the main_header class.
            %
            % If filename is mangled with file creation date, the file
            % creation date becomes "known";
            obj = set_filename_with_cdate_(obj,val);
        end
    end
    %------------------------------------------------------------------    
    % SERIALIZABLE INTERFACE
    properties(Constant,Access = protected)
        % fields used with serializable interface. Keep order of fields
        % unchanged, as setting creation_date sets also creation_date_defined_
        % and creation_date_defined_privately sets/reads creation_date_defined_
        % (contrary to usual convention, but necessary for supporting old
        % mat and sqw files, which do not have these proerties stored within them)
        fields_to_save_ = {'filename','filepath','title','nfiles',...
            'creation_date','creation_date_defined_privately'};
    end
    
    methods
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end

        function flds = saveableFields(~)
            flds = main_header_cl.fields_to_save_;
        end

    end

    methods(Static)
        % Utility routines:
        function datt = convert_datetime_from_str(in_str)
            % convert main_header_cl's generated time string into
            % datetime format (datetime format differs from date(vec|num|str) format)
            tmp = datevec(in_str, main_header_cl.dt_format);
            datt = datetime(tmp);
        end

        function tstr = convert_datetime_to_str(date_time)
            % convert datetime class into main_header_cl's specific string,
            % containing date and time.
            tstr = main_header_cl.DT_out_transf_(date_time);
        end
    end

    methods(Static,Access=protected)
        function dtstr = DT_out_transf_(dt)
            % transform date-time into the requested string
            if ~isa(dt,'datetime')
                warning('HORACE:main_header_cl:invalid_argument', ...
                    'call to class-protected function with invalid argument. Something wrong with class usave')
                dt = datetime('now');
            end

            dtstr = datestr(dt, main_header_cl.dt_format);
        end
    end
end
