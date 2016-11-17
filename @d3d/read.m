function varargout = read (varargin)
% Read d3d object from a file or array of d3d objects from a set of files
% 
%   >> w=read(d3d,file)
%
% Need to give first argument as an d3d object to enforce a call to this function.
% Can simply create a dummy object with a call to d3d:
%    e.g. >> w = read(d3d,'c:\temp\my_file.d3d')
%
% Input:
% -----
%   d3d         Dummy d3d object to enforce the execution of this method.
%               Can simply create a dummy object with a call to d3d:
%                   e.g. >> w = read(d3d,'c:\temp\my_file.d3d')
%
%   file        File name, or cell array of file names. In this case, reads
%               into an array of d3d objects
%
% Output:
% -------
%   w           d3d object, or array of d3d objects if given cell array of
%               file names

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% ----- The following shoudld be independent of dnd, n=0,1,2,3,4 ------------
% Work via sqw class type


% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:},'$obj_and_file_ok');
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
% Now call sqw cut routine. Output (if any), is a cell array, as method is passed a data source structure
%argout=read(sqw,w,args{:});
%argout{1}=dnd(argout{1});   % as return argument is sqw object of dnd-type
argout=read_dnd(w,args{:}); % TODO: fixit!
if ~iscell(argout)
    argout = {argout};
end

% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
