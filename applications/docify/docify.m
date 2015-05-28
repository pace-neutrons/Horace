function varargout=docify(file_in,file_out)
% Insert documentation constructed from meta documentation
%
%   >> docify(file_in)          % insert documentation and replace file
%   >> docify(file_in,file_out) % insert documentation and write to new file
%
% The format for meta documentation is as follows:
%
% Skip over leading comment lines, that is, a contiguous set of lines beginning
% with '%'. This block will be replaced by documentation constructed from
% the meta documentation block (if one is found)
%
% Search for a block of comment lines before any executable code that
% contains a meta documentation block. This will have the form:
%   % <#doc_beg:>
%   %   :
%   % <#doc_end:>
%
% or, more generally:
%
%   % <#doc_def:>
%   %   :
%   % <#doc_beg:>
%   %   :
%   % <#doc_end:>
%
% The optional section between <#doc_def:> and <#doc_beg:> will contain the
% values of substitution strings and/or values of logical flags that select
% comment blocks in the section between <#doc_beg:> and <#doc_end:>
%
% EXAMPLE: Simple use:
%   % <#doc_beg:>
%   % Evaluate derivative of input spectrum
%   %   >> y = deriv (w, mderiv)
%   % Input:
%   %   w       Input data:
%   % <#file: 'data_type_description.txt'>
%   %   mderiv  Order of derivative (1,2,...)
%   % Output:
%   %   y       Same object type as input
%   %
%   % <#file:> 'further_notes.txt'
%   % <#doc_end:>
%
% EXAMPLE: More complex use: define the substitueion strings func_suffix
% and my_file, and define the block of comments titled 'main' as active
%   % <#doc_def:>
%   %   func_suffix = '_sqw'
%   %   main = 1
%   %   my_file = 'stuff.txt'
%   % <#doc_beg:>
%   %   This line will appear as the first comment
%   %   <#file:> 'c:\temp\comments.txt'
%   %   <main:>
%   %   This line will be written if main=1 in the definition block
%   %   and so will this file of comments be read:
%   %   <#file:> <my_file>
%   %   <main/end:>
%   % <#doc_end:>
%
% - Substitution strings and logical block selection are global. In the above
%   example:
%       - all occurences of <func_suffix> will be replaced by '_sqw' in the
%         files that are read in the main documentation block
%         ('c:\temp\comments.txt' and 'stuff.txt' in this case).
%       - all blocks <main:> ... <main_end:> in those files will be retained;
%         any other blocks will be ignored (unless their name is set to 1 as well)
%
% - Any file that will be read is assumed to be a documentation file, which
%   means that it can only contain
%       - lines that begin with '%'
%       - lines that contain only a logical block start and end indicators
%         such as '<main:>' and '<main_end:>'  (note that '<main:>' and
%         '% <main:>' are equivalent; the leading '%' is ignored)
%       - lines that give a file substitution e.g. <#file:> 'stuff.txt' (or
%         equivalently % <#file:> 'stuff.txt')
%
% - Documentation files can be nested
%
% - Global substitution strings and logical block selection can be overidden
%   in a documentation file by defining their values at the top
%   e.g. if 'stuff.txt' is:
%
%   %   Never use variables with the name multifit<func_suffix>
%   %   as this will cause a crash, as explained below:
%   %   <#file:> 'warning.txt'
%
%   then the value of main could be overridden by instead having:
%
%   % <#doc_def:>
%   %   main=0
%   % <#doc_beg:>
%   %   Never use variables with the name multifit<func_suffix>
%   %   as this will cause a crash, as explained below:
%   %   <#file:> 'warning.txt'
%
%   Another way of overiding a value is to pass as an argument: in the main
%   call
%   % <#doc_def:>
%   %    :
%   %   main = 1
%   %   my_file = 'stuff.txt'
%   %    :
%   % <#doc_beg:>
%   %   This line will appear as the first comment
%   %       :
%   %   <#file:> <my_file>  0
%   %       :
%   % <#doc_end:>
%
%   then stuff.txt contains the lines:
%   % <#doc_def:>
%   %   main='#1'
%   % <#doc_beg:>
%   %   Never use variables with the name multifit<func_suffix>
%   %   as this will cause a crash, as explained below:
%   %   <#file:> 'warning.txt'


replace=(nargin==1);

while true
    % Parse meta documentation in an m-file
    [ok,mess,source,no_change]=parse_doc(file_in);
    if ~ok, break, end
    
    % Write out the parsed source file
    if ~no_change
        if ~replace
            [file_full_out,ok,mess]=translate_write (file_out);
            if ~ok, break, end
        else
            file_full_in=translate_read(file_in);   % we know this must already have worked
            [~,name,ext]=fileparts(file_full_in);
            file_full_out=fullfile(tempdir,[name,str_random,ext]);
        end
        try
            save_text(source,file_full_out)
        catch
            ok=false;
            mess=['Unable to write to file: ',file_full_out];
            break
        end
        if replace
            try
                movefile(file_full_out,file_full_in,'f');
            catch
                ok=false;
                mess=['Unable to replace file: ',full_file_in];
                break
            end
        end
    end
    break
end

% Catch case of error
if ~ok
    if nargout==0
        error('docify:docify',error_message(mess))
    else
        warning('docify:docify',error_message(mess))
    end
end

if nargout>=1, varargout{1}=ok; end
if nargout>=2, varargout{2}=mess; end
