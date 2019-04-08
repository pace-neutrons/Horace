function [data_source, args, mess] = horace_function_parse_input (nargout_caller,varargin)
% Resolve input arguments to sqw and dnd methods where a file may be the source of data.
%
%   >> [data_source_struct, args, source_arg_is_filename, mess] = ...
%           horace_function_parse_input (nargout_caller, data_object, arg1, arg2,...)
%
%   >> [data_source_struct, args, source_arg_is_filename, mess] = ...
%          	horace_function_parse_input (nargout_caller, dummy_data_object, filename, arg1, arg2,...)
%
%   >> [data_source_struct, args, source_arg_is_filename, mess] = ...
%          	horace_function_parse_input (nargout_caller, dummy_data_object, data_source_struct, arg1, arg2,...)
%
% NOTE: File names must not begin with a dash, '-'. Strings beginning with a dash are
%       reserved for character keyword options.
%
% WARNING: This function is for use only within methods that can take both Horace data object
%          or data filenames. It is NOT for public use.
%
% Input:
% ------
%   nargout_caller  Number of output arguments expected by the caller function. This is used
%                  to create the field nargout_req in the output data source object if the input
%                  data is an object or filename(s)
% *EITHER*
%   data_object     sqw or dnd object (or arrays of objects) containing data to be processed
%                  by the caller function.
% *OR*
%   dummy_object    Dummy data object (e.g. from call to sqw constructor with no input arguments)
%                  This determines what sort of data the file(s) or data source object
%                  must contain (class must be one of sqw, d0d, d1d, d2d, d3d or d4d).
%
%   data_source     Data source object from an earlier call to this function (see output argument
%                  below for detailed description).
%                    *OR*
%                   If the final input argument is '$obj_and_file_ok', then a file name, or cell array
%                  of file names, containing Horace data. This option is for those rare cases where
%                  we want an object method to be able to take a file name e.g. w=read(sqw,'myfile.sqw')
%                  as an alternative to >> w=read_sqw('myfile.sqw'). This option is best avoided
%                  because it sits outside the standard convention for the writing of methods that
%                  operate on both objects and files.
%                   
%
%   arg1, arg2,...  All other input arguments; these are passed through in output argument args (see below)
%
% Output:
% -------
%   data_source_struct
%                   Data source structure containing information about the input data. Its fields are:
%                       source_is_file  Logical flag
%                                           =true if file name data
%                                           =false if sqw or dnd object data
%                       data            Data source
%                                       - Cell array of file names source_is_file==true
%                                       - Array of objects containing the data if false
%                       sqw_type        Logical array indicating type of data in the data file or object
%                                           sqw_type(i)=true if sqw data
%                                           sqw_type(i)=false if dnd type
%                                       In the case of file data, this is how to read the file and not what
%                                      the actual contents are. That is, the file may contain sqw data,
%                                      but if sqw_type(i) is false then it will be read as dnd object.
%                       ndims           Array giving dimensions of the data
%                       nfiles          Array giving number of contributing spse data sets to each data source
%                                      Contains zeros if not sqw_type. (This is the case even if the file
%                                      data contains sqw information, because if sqw_type==false then the
%                                      file is going to be read as a dnd object)
%                       source_arg_is_struct
%                                       Type of input data source:
%                                           =true if it was a data source structure
%                                           =false if it was an object or file name
%                       nargout_req     Number of output arguments required as a minimum by the
%                                      function that originally created the data source structure.
%                                      Further calls to this function do not change this value,
%                                      as it indicates how many output arguments are required by the
%                                      function that originally contructed the data source structure.
%
%                   The data source structure contents are determined from the input data source (object,
%                  file, or data source object). 
%
%                   If object data source:
%                   ----------------------
%                   - if sqw object, then it must all be sqw-type i.e. contain pixel information.
%                     (If the caller function is an sqw method, then if it operates on dnd-type
%                     input it is assumed that the dnd method that calls it will have already
%                     packed the data into a data source object.)
%                   - Any dnd object is valid.
%
%                   If file data source:
%                   --------------------
%                   - if dummy sqw object: the file(s) must all contain sqw-type data i.e. contain
%                     pixel information
%                   - if dummy dnd object: the file(s) must all contain data of the same dimensionality
%                     as the dummy object. The files can be sqw-type, but they will be read as dnd type.
%
%                   If data source structure:
%                   -------------------------
%                   This will have been constructed from a previous call to this function. The only
%                   action that is taken is to update the data field in the structure according
%                   to the dummy object:
%                    - 'round down' the sqw type if file data source structure;
%                    - use dnd() or sqw() according to class(dummy_obj) if object data source structure.
%
%   args            Input argument list stripped of sqw_object or dummy_sqw_object, and data_source_in
%
%   source_arg_is_filename
%                   Scalar logical:
%                       true:  data_source_in is a file name or cell array of file names
%                       false: Otherwise, that is:
%                           - data_source_in is a data source structure (see input arguments for details)
%                           - there is no data_source_in because the sqw object was the data source.
%                   Can use this argument in conjuction with the value of source_is_file to determine
%                   which if the three scenarios of data applies: sqw object, filename(s), data_source structure
%
%   mess            Error message: empty if no problems.

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)


% Default values if there is an error
data_source=struct('source_is_file',{},'data',{},'sqw_type',{},'ndims',{},'nfiles',{},'source_arg_is_struct',{},...
    'nargout_req',{},'loaders_list',{} );
args=cell(1,0);

% Parse input arguments
% ---------------------
narg=numel(varargin);
% Check if the input format (nargout_caller, dummy_obj, filename,...,'$obj_and_file_ok') is permitted
if narg>=1 && is_string(varargin{end}) && strcmpi(varargin{end},'$obj_and_file_ok')
    obj_and_file_ok=true;
    narg=narg-1;
else
    obj_and_file_ok=false;
end

% Check for valid argument lists
if narg>=2 && is_filename(varargin{2}) && (is_horace_data_file_opt(varargin{1}) || (obj_and_file_ok && is_horace_data_object(varargin{1})))  
    % Input arguments must start: (nargout_caller, dummy_obj, filename,...,'$obj_and_file_ok')
    %                         or: (nargout_caller, file_opt, filename,...)
    % The dummy object determines the data that must be contained in the files:
    %  - if sqw object: All files contain sqw data i.e. have pixel information.
    %  - if dnd object: All files must have the same dimensionality as the dummy object.
    %                  The files will be read as dnd data; any pixel information is ignored.
    try
        [sqw_type,ndims,nfiles,filename,mess,ld] = is_sqw_type_file(sqw,varargin{2});
    catch
        mess = 'Unable to read data file(s) - check file(s) exist and are Horace data file(s) (sqw or dnd type binary file)';
    end
    if isempty(mess)
        [is_opt,opt_sqw,opt_dnd,opt_hor]=is_horace_data_file_opt(varargin{1});
        if is_opt
            sqw_obj=false;
            dnd_obj=false;
        else
            sqw_obj=isa(varargin{1},'sqw');
            dnd_obj=~sqw_obj;
        end
        if (sqw_obj||opt_sqw) && ~all(sqw_type(:))
            mess='Data file(s) must all be sqw type i.e. must contain pixel information';
        elseif dnd_obj && ~all(ndims(:)==dimensions(varargin{1}(1)))
            mess=['Data file(s) must all contain data with the same dimensionality as the dnd method (n=',...
                num2str(dimensions(varargin{1}(1))),')'];
        elseif opt_dnd && ~all(ndims(:)==ndims(1))
            mess='Data file(s) must all contain data with the same dimensionality';
        elseif opt_hor && ~(all(sqw_type(:))||all(ndims(:)==ndims(1)))
            mess='Data file(s) must all be sqw type (i.e. must contain pixel information) or have the same number of dimensions';
        else
            data_source(1).source_is_file=true;
            data_source(1).data=filename;
            if narg>=3, args=varargin(3:narg); else args=cell(1,0); end     % to work in all cases
            if sqw_obj||opt_sqw||(opt_hor&&all(sqw_type(:)))
                data_source(1).sqw_type=sqw_type;
            else
                data_source(1).sqw_type=false(size(sqw_type));  % force dnd reading of files
            end
            data_source(1).ndims=ndims;
            if data_source(1).sqw_type
                data_source(1).nfiles=nfiles;
            else
                data_source(1).nfiles=zeros(size(nfiles));      % if forced dnd reading, set nfiles to match
            end
            data_source(1).source_arg_is_struct=false;
            data_source(1).nargout_req=nargout_caller;
            data_source(1).loaders_list = ld; % cellarray of loaders --- one per file
        end
    end
    
elseif narg>=2 && is_horace_data_object(varargin{1}) && (isstruct(varargin{2}) &&...
        numel(fields(data_source))==numel(fields(varargin{2})) &&...
        all(strcmp(fields(data_source),fields(varargin{2}))))
    % Input arguments must start: (nargout_caller, dummy_obj, data_source_structure,...)
    % Already checked that the contents of the data_source_structure are valid if got this far.
    % However, must make sure that the data_source object is consistent with the class of dummy_obj.
    % We 'round down' the sqw type if file data source structure; or use dnd() or sqw() according
    % to class(dummy_obj) if object data source structure.
    mess='';
    if ~isa(varargin{1},'sqw')
        % Dummy object is d0d, d1d,... or d4d
        % If file or object data, must do the following:
        if any(varargin{2}.ndims~=dimensions(varargin{1}(1)))
            mess='Not all data sources have the correct dimensionality';
        else
            data_source=varargin{2};
            data_source.sqw_type=false(size(data_source.sqw_type));
        end
        % If object data, must convert (only do if different, to avoid overheads)
        if ~data_source.source_is_file && isa(data_source.data,'sqw')
            data_source.data=dnd(data_source.data);
        end
        % Make sure the nfiles is zet to zero
        data_source.nfiles=zeros(size(data_source.nfiles));
    else
        % Dummy object is sqw object
        data_source=varargin{2};
        if ~data_source.source_is_file && ~isa(data_source.data,'sqw')
            data_source.data=sqw(data_source.data);     % turn dnd object into dnd-type sqw object
        end
    end
    if isempty(mess)
        data_source.source_arg_is_struct=true;
        if narg>=3, args=varargin(3:narg); else args=cell(1,0); end    % to work in all cases
    end
    
elseif narg>=1 && is_horace_data_object(varargin{1})
    % Input arguments must start: (nargout_caller, data_object,...)
    % We restrict the call to make a hard check on input, that is, an sqw object must
    % contain pixel information (to be consistent with how file data is handled).
    % That is, a dnd-tpye sqw object is not permitted.
    mess='';
    if isa(varargin{1},'sqw')
        sqw_type=true(size(varargin{1}));
        ndims=zeros(size(varargin{1}));
        nfiles=zeros(size(varargin{1}));
        for i=1:numel(varargin{1})
            if ~is_sqw_type(varargin{1}(i))
                mess='Data file(s) must all be sqw type i.e. must contain pixel information';
                break
            end
            ndims(i)=dimensions(varargin{1}(i));
            nfiles(i)=varargin{1}(i).main_header.nfiles;
        end
    else
        sqw_type=false(size(varargin{1}));
        ndims=dimensions(varargin{1}(1)) * ones(size(varargin{1}));
        nfiles=zeros(size(varargin{1}));
    end
    if isempty(mess)
        data_source(1).source_is_file=false;
        data_source(1).data=varargin{1};   % should be efficient - just copying a pointer
        data_source(1).sqw_type=sqw_type;
        data_source(1).ndims=ndims;
        data_source(1).nfiles=nfiles;
        data_source(1).source_arg_is_struct=false;
        data_source(1).nargout_req=nargout_caller;
        if narg>=2, args=varargin(2:narg); else args=cell(1,0); end    % to work in all cases
    end
    
else
    mess='Invalid data source';
end
