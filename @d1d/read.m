function varargout = read (varargin)
% Read d1d object from a file or array of d1d objects from a set of files
% 
%   >> w=read(d1d,file)
%
% Need to give first argument as an d1d object to enforce a call to this function.
% Can simply create a dummy object with a call to d1d:
%    e.g. >> w = read(d1d,'c:\temp\my_file.d1d')
%
% Input:
% -----
%   d1d         Dummy d1d object to enforce the execution of this method.
%               Can simply create a dummy object with a call to d1d:
%                   e.g. >> w = read(d1d,'c:\temp\my_file.d1d')
%
%   file        File name, or cell array of file names. In this case, reads
%               into an array of d1d objects
%
% Output:
% -------
%   w           d1d object, or array of d1d objects if given cell array of
%               file names

% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)

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
