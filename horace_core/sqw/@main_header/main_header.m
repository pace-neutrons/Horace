classdef main_header < serializable
    % Class describes the main header of the Horace sqw object


    properties(Dependent)
        % the properties describe the header structure
        filename; % the name of the file, where the
        filepath; % the path, where the file has been initially created
        title;    % title (description) of the sqw object
        nfiles;   % number of runs contributed into the sqw file this header
        %           is responsible for
        %
        creation_date % The date when this header (in the sqw file) was created
        % method returns true, if the file creation date is not stored
        % together with binary data in old binary files
        no_cr_date_known
    end
    properties(Dependent,Hidden)
        % return filename mangled with the creation date, used to write
        % creation data together with filename in old style v3 binary
        % Horace files
        filename_with_cdate
    end
    properties(Access = protected)
        filename_ = '';
        filepath_ = '';
        title_    = '';
        nfiles_   = 0;
        creation_date_='';
        no_cr_date_known_= true;
    end
    properties(Constant,Access = protected)
        fields_to_save_ = {'filename','filepath','title','nfiles',...
            'no_cr_date_known','creation_date'};
        % date/time format to store in file
        DT_format_ = '%d-%02d-%02dT%02d:%02d:%02d';
        % transform date-time into the requested string
        DT_out_transf_ = @(dt)sprintf(main_header.DT_format_, ...
            dt.Year,dt.Month,dt.Day,dt.Hour,dt.Minute,round(dt.Second));
    end

    methods
        function obj = main_header(varargin)
            % Construct an instance of main header class
            %
            % obj = main_header();
            % obj = main_header(filename);
            % obj = main_header(filename,filepath);
            % obj = main_header(filename,filepath,title);
            % obj = main_header(filename,filepath,title,nfiles);
            if nargin == 0
                return;
            end
            if nargin == 1
                if isa(varargin{1},'main_header')
                    obj = varargin{1};
                elseif isstruct(varargin{1})
                    obj = serializable.from_structf(varargin{1});
                elseif ischar(varargin{1})
                    obj.filename = varargin{1};
                else
                    error('HORACE:main_header:invalid_argument',...
                        'can not construct main header from parameter %s',...
                        evalc('disp(varargin{1}))'))
                end
                return;
            else
                validators = {@ischar,@ischar,@ischar,@isnumeric};
                param_names_list = obj.saveableFields();
                [obj,remains] = obj.set_positional_and_key_val_arguments(...
                    param_names_list(1:4),validators,varargin);
                if ~isempty(remains)
                    error('HORACE:main_header:invalid_argument',...
                        '')
                end
            end
        end
        %
        function tit = get.title(obj)
            tit = obj.title_;
        end
        function obj = set.title(obj,val)
            if ~(ischar(val) || isstring(val))
                error('HORACE:main_header:invalid_argument', ...
                    'title has to be string or char array and it is %s',...
                    class(val));
            end
            obj.title_ = val;
        end
        %
        function tit = get.filename(obj)
            tit = obj.filename_;
        end
        function obj = set.filename(obj,val)
            if ~(ischar(val) || isstring(val))
                error('HORACE:main_header:invalid_argument', ...
                    'filename has to be string or char array and it is %s',...
                    class(val));
            end
            obj.filename_ = val;
        end
        %
        function tit = get.filepath(obj)
            tit = obj.filepath_;
        end
        function obj = set.filepath(obj,val)
            if ~(ischar(val) || isstring(val))
                error('HORACE:main_header:invalid_argument', ...
                    'filename has to be string or char array and it is %s',...
                    class(val));
            end
            obj.filepath_ = val;
        end
        %
        function nf = get.nfiles(obj)
            nf = obj.nfiles_;
        end
        function obj = set.nfiles(obj,val)
            if ~isnumeric(val) || val<0
                error('HORACE:main_header:invalid_argument', ...
                    'Number of files should have non-negative numeric value. It is %s',...
                    evalc('disp(val)'));
            end
            obj.nfiles_ = val;
        end
        %------------------------------------------------------------------
        function cd = get.creation_date(obj)
            cd = get_creation_date_(obj);
        end
        function obj = set.creation_date(obj,val)
            % explicitly set up creation date and make it "known"
            obj = set_creation_date_(obj,val);
        end
        function unknown = get.no_cr_date_known(obj)
            unknown = obj.no_cr_date_known_;
        end
        %------------------------------------------------------------------
        % sqw_binfile_common interface
        %------------------------------------------------------------------
        function fnc = get.filename_with_cdate(obj)
            % this method is used to mangle filename with file creation
            % date and used to save them in a Horace binary file
            % version 3.XXX and lower
            if obj.no_cr_date_known_
                % if creation date have not been defined, get only filename
                fnc = obj.filename;
            else
                fnc = [obj.filename,'$',obj.creation_date];
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
        %--------------------------------------------------
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end
        function flds = saveableFields(~)
            flds = main_header.fields_to_save_;
        end
    end
end