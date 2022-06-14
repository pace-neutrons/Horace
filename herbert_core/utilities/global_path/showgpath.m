function  showgpath(varargin)
% Display global path(s).
%
%   >> showgpath            % Display the names of all global paths that have been set
%   >> showgpath(pathname)  % Display the path corresponding to a particular global path
%
% See also: mkgpath, delgpath, addgpath, rmgpath, addendgpath, addbeggpath, showgpath, existgpath

% Check global path name
if nargin==1 && ~isvarname(varargin{1})
    error('Check global path is a character string that is permitted as a variable name')
elseif nargin>1
    error('Check number of input arguments')
end

if nargin==1 && ~existgpath(varargin{1})
    error(['Global path ''',varargin{1},''' does not exist.'])
end

celldir = ixf_global_path ('get',varargin{:});
disp('-------------------------------------------------')
display_global_path(celldir,'')
disp('-------------------------------------------------')

% ----------------------------------------------------------------------------
function display_global_path(celldir,indent)
   
next_indent=['    ',indent];
for i=1:numel(celldir)
    if isvarname(celldir{i}) && existgpath(celldir{i})  % global path
        disp(' ')
        disp([indent,celldir{i},':'])
        display_global_path(getgpath(celldir{i}),next_indent);
        disp(' ')
    else
        env_var=getenv(celldir{i});
        if ~isempty(env_var)
            disp(' ')
            disp([indent,celldir{i},':  (environment variable)'])
            display_global_path({env_var},next_indent);
            disp(' ')
        else
            disp([indent,celldir{i}])
        end
    end
end

% function display_global_path(celldir,indent)
%    
% next_indent=['    ',indent];
% for i=1:numel(celldir)
%     if isvarname(celldir{i})  % assume to be a global path
%         disp(' ')
%         disp([indent,celldir{i},':::'])
%         if existgpath(celldir{i})
%             display_global_path(getgpath(celldir{i}),next_indent);
%         else
%             display([next_indent,'<global path currently undefined>'])
%         end
%         disp(' ')
%     else
%         disp([indent,celldir{i}])
%     end
% end
