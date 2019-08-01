function mess_out = make_message (lstruct, iline, varargin)
% Construct error message
%
%   >> mess_out = make_message (lstruct, iline, mess1, mess2, ...)
%
% Input:
% ------
%   lstruct     Line structure: fields
%                   cstr        Row cellstr, trimmed both ends and blank lines removed
%                   cstr0       Row cellstr untrimmed lines but blank lines removed
%                   ind         Line numbers in original file
%                   flname      File name of original file
%                   flname_full Full file name of original file
%
%   iline       Line indicies in cstr at which to list
%               - [] none
%               - scalar if single identifiable line
%               - array if several lines
%               - 0  if first and last line (with '    :'  in between)
%
%   mess1       Additional messages to list in sequence (character strings
%   mess2      or cellstr). They will appear after a leading message line
%     :        and before the lines selected by iline
%
% Output:
% -------
%   mess_out    Cellstr of character strings containing the error message


% Get lines and string with actual line numbers in the original file
if isscalar(iline)
    if iline>0
        % Single line error
        line = lstruct.cstr0(iline);
        iline_str = ['line ',num2str(lstruct.ind(iline))];
    else
        % Assume error is assosiated with entire lstruct; pick out first and last lines
        if numel(lstruct.cstr0)==1
            line = lstruct.cstr0(1);
            iline_str = ['line ',num2str(lstruct.ind)];
        else
            line = [lstruct.cstr0(1),{'        :'},lstruct.cstr0(end)];
            tmp=(lstruct.ind(1):lstruct.ind(end));
            iline_str = ['lines ',char(str_compress(iarray_to_str(tmp,Inf,'m'),','))];
        end
    end
elseif numel(iline)>1
    % Multiple lines
    line = lstruct.cstr0(iline);
    iline_str = ['lines ',char(str_compress(iarray_to_str(lstruct.ind(iline),Inf,'m'),','))];
else
    % No lines to be printed
    line = {};
    iline_str = '';
end

% Make error cellstr
if ~isempty(iline_str)
    [~,mess_out]=str_make_cellstr(...
        ['Error processing input file: ', lstruct.flname, '   (',iline_str,')'],...
        varargin{:}, '=== Offending line(s):', line);
else
    [~,mess_out]=str_make_cellstr(...
        ['Error processing input file: ', lstruct.flname], varargin{:});
end
