function [ignored_blocks_list,argi] = extract_ignored_blocks_arg_(varargin)
% Extract keyword 'ignored_blocks' and correspondent ignored blocks list
% from the input parameters list. 
%
% Return the list of ignored blocks if such list is present and other
% argument list stripped of ignored block list info. 
% 
% Usage:
% [ignored_blocks_list,argi] = extract_ignored_blocks_(varargin{:});
% Where:
% varargin -- cellarray of values which may or may not contain
%             'ignored_blocks' keyword, followed by the name of the block
%             or cellarray of the block names


is_ignore_kw = cellfun(@(x)(ischar(x)||isstring(x))&&strcmp(x,'ignore_blocks'),varargin);
if ~any(is_ignore_kw )
    argi = varargin;
    ignored_blocks_list = {};
    return
end
ib_ind = find(is_ignore_kw,1);
if ib_ind == nargin
   error('HORACE:binfile_v4_common:invalid_argument', ...    
       'ignore_block keyword is provided without the list to ignore which should follow the keyword')
end
ignored_blocks_list = varargin{ib_ind+1};
if ~iscell(ignored_blocks_list) 
    if ischar(ignored_blocks_list)|| isstring(ignored_blocks_list ) % single element to ignore
        ignored_blocks_list = {ignored_blocks_list};
    else
        error('HORACE:binfile_v4_common:invalid_argument', ...            
            'Ignored block list should be cellarray of block names to ignore. It is: %s',...
        disp2str(ignored_blocks_list));
    end
end
is_ignore_kw(ib_ind+1) = true;
argi = varargin(~is_ignore_kw);


