function [head,obj]  = get_main_header(obj,varargin)
% Return main sqw file header class stored in the file, 
% the loader is initialized with.
%
% Usage:
%>>[head,obj]  = obj.get_main_header() % Returns the header class
%         present in sqw file. Modifies the name of the sqw file, the
%         header has been build for to the current name of the file
%>>[head,obj]  = obj.get_main_header('-keep_original') % Returns the header class
%         present in sqw file, keeps the original file name.

%
[ok,mess,keep_original,verbatim,argi] = parse_char_options(varargin,...
    {'-keep_original','-verbatim'});
if ~ok
    error('HORACE:faccess_sqw_v4:invalid_argument',...
        mess)
end
keep_original = keep_original||verbatim;
%
[obj,head] = obj.get_sqw_block('bl__main_header',argi{:});

if ~keep_original
    [fp,fn,fext] = fileparts(obj.full_filename);
    head.filename = [fn,fext];
    head.filepath = fp;
end