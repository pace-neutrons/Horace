function [ok,mess] = save_ascii (w, file)
% Writes IX_dataset_1d or array of IX_dataset_1d to an ascii file. Inverse of read_ascii.
%
%   >> save_ascii (w)           % prompts for file to write to
%   >> save_ascii (w, file)     % write to named file
%   >> save_ascii (w, fid)      % write to currently open text file
%
%   >> [ok,mess] = save_ascii (...)    % Return status and error message
%                                       % (ok=true all fine, ok=false otherwise)
%
% If a histogram data set, the output file format is, for example:
%
%   title = La(Pb)MnO3 data
%   xlab = energy transfer
%   ylab = S(Q,w)
%   xunit = meV
%   distribution = 1
%       x(1)    y(1)    e(1)
%       x(2)    y(2)    e(2)
%        :       :       :
%       x(n)    y(n)    e(n)
%       x(n+1)
%
% If point spectrum, then the x-y-e columns terminate as
%        :       :       :
%       x(n)    y(n)    e(n)
%
% If w is an array of spectra, tben the spectra will be written out in series
%  - If title or xlabel extends over more than one line, then this will appear
%    in the ascii file as e.g.
%       title = La(Pb)MnO3 data
%       title = 300K
%       title = Run number 12345
%
% Can be read back into matlab with the function read_ascii


% Get file name - prompting if necessary - and open the file
% ----------------------------------------------------------
permission='wt';
if nargin==2 && isnumeric(file)
    [file_full,ok,mess]=fidcheck(file,permission);
    fid_given=true;
else
    if ~exist('file','var'), file=''; end
    [file_full,ok,mess]=putfilecheck(file);
    if ok
        fid=fopen(file_full,permission);
        if (fid<0)
            ok=false; mess=['Cannot open file ' file_full];
        end
    end
    fid_given=false;
end
if ~ok && nargout==0, error(mess), end


% Write data to file
% ------------------
for i=1:length(w)
    labels = put_struct_to_labels (struct('title',w(i).title));
    x_axis= put_struct_to_labels (struct(w(i).x_axis));
    for j=1:numel(x_axis)
        x_axis{j}=['x_',x_axis{j}];
    end
    labels=[labels,x_axis];
    labels = put_struct_to_labels (struct('x_distribution',w(i).x_distribution), labels);
    s_axis= put_struct_to_labels (struct(w(i).s_axis));
    for j=1:numel(s_axis)
        s_axis{j}=['signal_',s_axis{j}];
    end
    labels=[labels,s_axis];
    for j=1:numel(labels)
        fprintf(fid,'%-s\n',labels{j});
    end
    if length(w(i).x)==length(w(i).signal) % point data
        fprintf (fid, '%30.16g %30.16g %30.16g \n', [w(i).x; w(i).signal'; w(i).error']);
    else
        fprintf (fid, '%30.16g %30.16g %30.16g \n', [w(i).x(1:end-1); w(i).signal'; w(i).error']);
        fprintf (fid, '%30.16g \n', w(i).x(end));
    end
end

% Close file if function was given a file name, not fid:
if ~fid_given
    fclose(fid);
end

% Ensure that if no arguments, do not get any output (otherwise from command line
% a succesful >> write_acsii(w) would print "ans = 1")
if nargout==0
    clear ok mess
end
