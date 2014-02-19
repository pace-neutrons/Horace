function varargout = read (varargin)
% Read sqw object from a file or array of sqw objects from a set of files
% 
%   >> w=read(sqw,file)
%
% Need to give first argument as an sqw object to enforce a call to this function.
% Can simply create a dummy object with a call to sqw:
%    e.g. >> w = read(sqw,'c:\temp\my_file.sqw')
%
% Input:
% -----
%   sqw         Dummy sqw object to enforce the execution of this method.
%               Can simply create a dummy object with a call to sqw:
%                   e.g. >> w = read(sqw,'c:\temp\my_file.sqw')
%
%   file        File name, or cell array of file names. In this case, reads
%               into an array of sqw objects
%
% Output:
% -------
%   w           sqw object, or array of sqw objects if given cell array of
%               file names

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:},'$obj_and_file_ok');
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
nw=numel(w.data);

% Check number of arguments
if ~isempty(args)
    error('Check number of input arguments')
end

% Now read data
if w.source_is_file
    if all(w.sqw_type(:))
        wout = repmat(sqw,size(w.data));
        for i=1:nw
            wout(i)=sqw(w.data{i});
        end
    elseif all(~w.sqw_type) && all(w.ndims==w.ndims(1))
        wout = repmat(sqw('$dnd',w.ndims(1)),size(w.data));
        for i=1:nw
            wout(i)=sqw('$dnd',w.data{i});
        end
    else
        error('Data files must all be sqw type, or all dnd type with same dimensionality')
    end
    argout{1}=wout;
else
    argout{1}=w.data;  % trivial case that data source is already valid object
end

% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
