function [ok, mess, file_full_in, changed, file_full_out] = docify_single...
    (file_in, file_out, doc_filter)
% Insert documentation constructed from meta documentation for a single file
%
%   >> [ok, mess, file_full_in, changed, file_full_out] = docify_single...
%                                           (file_in, file_out, doc_filter)
%
% Input:
% ------
%   file_in     Input file name
%   file_out    Output file name (if empty, then replaces file_in)
%   doc_filter  Determine which doc_beg...doc_end sections to parse:
%              If false: parse all sections, whether tagged with filter keyword or not
%              If true:  parse only untagged sections
%              If cell array of strings:
%                        parse only those sections tagged with one or more
%                        of the keywords in the list that is doc_filter
%
% Output:
% -------
%   ok              =true if all OK, =false if not
%   mess            Message. It may have contents even if OK==true, in which
%                  case it is purely informational or warning.
%   file_full_in    Full name of input file
%   changed         True if meta-documentation parsing changes the source;
%                  false otherwise
%   file_full_out   Full name of output file (same as input file if file is
%                  replaced or changed==false)


replace_file = isempty(file_out);

while true  % while...end only so the 'break' feature can be used
    % Parse meta documentation in an m-file
    [ok,mess,source,changed] = parse_top_doc (file_in,doc_filter);
    if ok
        file_full_in = translate_read(file_in);   % we know this must already have worked
    else
        file_full_in = '';
        file_full_out = '';
        break
    end
    
    % Write out the parsed source file
    if changed
        % The documentation changed as a result of parsing the meta documentation
        % Get temporary file name  or new file name according to whether or not
        % to replace the input file
        if replace_file
            [~,name,ext]=fileparts(file_full_in);
            file_full_out=fullfile(tmp_dir,[name,str_random,ext]);
        else
            [file_full_out,ok,mess] = translate_write (file_out);
            if ~ok, break, end
        end
        % Write to file
        try
            save_text(source,file_full_out)
        catch
            ok=false;
            if replace_file
                mess={'Unable to write to temporary output file:',file_full_out};
            else
                mess={'Unable to write to output file:',file_full_out};
            end
            break
        end
        % If replace_file, copy the temporary file now we know it was written without problem
        if replace_file
            try
                movefile(file_full_out,file_full_in,'f');
                file_full_out = file_full_in;
            catch
                ok=false;
                mess={'Unable to replace input file with temporary file:',file_full_out};
                break
            end
        end
    else
        file_full_out = file_full_in;
    end
    break
end
