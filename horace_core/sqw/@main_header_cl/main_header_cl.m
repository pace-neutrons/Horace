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
        %
        creation_date % The date when this header (in the sqw file) was created

        % method returns false, if the file creation date is not stored
        % together with binary data in old binary files
        creation_date_defined
    end
    properties(Dependent,Hidden)
        % return filename mangled with the creation date, used to write
        % creation data together with filename in old style v3 binary
        % Horace files
        filename_with_cdate
        % hidden property allowing save/restore creation_date_defined
        % property used by loadobj/saveobj methods only
        creation_date_defined_privately;
    end
    properties(Access = protected)
        filename_ = '';
        filepath_ = '';
        title_    = '';
        nfiles_   = 0;
        creation_date_='';
        creation_date_defined_= false;
    end
    properties(Constant,Access = protected)
        % fields used with serializable interface. Keep order of fields
        % unchanged, as setting creation_date sets also no_cr_data_known_
        % and creation_date_defined_privately should override this
        fields_to_save_ = {'filename','filepath','title','nfiles',...
            'creation_date','creation_date_defined_privately'};
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
            if nargin == 0
                return;
            end
            if nargin == 1
                if isa(varargin{1},'main_header')
                    obj = varargin{1};
                elseif isstruct(varargin{1})
                    obj = serializable.from_struct(varargin{1},obj);
                    if isfield(varargin{1},'filename_with_cdate')
                        obj.filename_with_cdate = varargin{1}.filename_with_cdate;
                    end
                elseif ischar(varargin{1})
                    obj.filename = varargin{1};
                else
                    error('HORACE:main_header:invalid_argument',...
                        'can not construct main header from parameter %s',...
                        evalc('disp(varargin{1}))'))
                end
            else
                validators = {@ischar,@ischar,@ischar,@isnumeric};
                param_names_list = obj.saveableFields();
                [obj,remains] = obj.set_positional_and_key_val_arguments(...
                    param_names_list(1:4),validators,varargin{:});
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
        function is = get.creation_date_defined(obj)
            is = obj.creation_date_defined_;
        end
        %------------------------------------------------------------------        
        % hidden properties, do not use unless understand deeply why thery
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
        %------------------------------------------------------------------
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
        %------------------------------------------------------------------
        function [iseq,mess] = eq(obj,other_obj,varargin)
            % equality statement. May be should be moved to be part of
            % serializable
            if any(size(obj) ~= size(other_obj))
                iseq = false;
                mess = 'objects have different size';
                return;
            end
            iseq = isa(other_obj,class(obj));
            if ~iseq
                mess = 'the class of the comaried objects is different';
                return;
            end
            for i=1:numel(obj)
                [iseq,mess] = iseq_(obj(i),other_obj(i),varargin{:});
            end
        end
    end
    methods(Static)
        % Service routines:
        function datt = convert_datetime_from_str(in_str)
            % convert main_header_cl's generated time string into
            % datetime format (standard datetime conversion works very
            % strangely)
            val = num2cell(sscanf(in_str,main_header_cl.DT_format_));
            datt = datetime(val{:});
        end
        function tstr = convert_datetime_to_str(date_time)
            % convert datetime class into main_header_cl's specific string,
            % containing date and time.
            tstr = main_header_cl.DT_out_transf_(date_time);
        end
    end
    methods(Static,Access=protected)
        function form =  DT_format_()       % date/time format to store in a file
            form = '%d-%02d-%02dT%02d:%02d:%02d';
        end

        function dtstr = DT_out_transf_(dt)
            % transform date-time into the requested string
            if ~isa(dt,'datetime')
                warning('HORACE:main_header_cl:invalid_argument', ...
                    'call to class-protected function with invalid argument. Something wrong with class usave')
                dt = datetime('now');
            end
            dtstr = sprintf(main_header_cl.DT_format_(), ...
                dt.Year,dt.Month,dt.Day,dt.Hour,dt.Minute,round(dt.Second));
        end
    end
end