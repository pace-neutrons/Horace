function varargout = head(obj,varargin)
% Display a summary of an sqw object or file containing sqw information.
%
%   >> head(w)              % Display summary for object (or array of objects)
%
% To return header information in a structure, without displaying to screen:
%
%   >> h=head(...)          % Fetch principal header information
%   >> h=head(...,'-full')  % Fetch full header information
%
%
% The facility to get head information from file(s) is included for completeness, but
% more usually you would use the function:
%   >> head(filename)
%   >> h=head(filename,___)

% Alternative (old) form is also possible:
%   >> h=head_horace(___)
%
%
% Input:
% -----
%   w           sqw object or array of sqw objects
%       *OR*
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each sqw object
%
% Optional keyword:
%   '-full'     Keyword option; if present, then returns all header and the
%              detector information. In fact, it returns the full data structure
%              except for the signal, error and pixel arrays.
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

% Original author: T.G.Perring
%


% Check input arguments
[ok,mess,full_data,argi] = parse_char_options(varargin,{'-full'});
if ~ok
    error('HORACE:head:invalid_argument',mess);
end
if ~isempty(argi)
    if isfile(argi{1})
        file = argi{1};
        if ispc
            file = strrep(file,'\','/');
        end
        mess = sprintf([ ...
            ' Invalid input key: "%s"\n.' ...
            ' Are you using old "head" format in the form: head(sqw,%s)?\n' ...
            ' Update your script to run "head(%s)" command instead'], ...
            file,file,file);
    else
        mess = sprintf('Invalid input key: "%s"',disp2str(argi{1}));
    end
    error('HORACE:head:invalid_argument',mess);
end

nout = nargout;
nw = numel(obj);
hout = cell(1,nw);
fields_req = sqw.head_form(false,full_data);
for i=1:nw
    dnd_val = struct2cell(obj(i).data.to_head_struct(false,false));
    if full_data
        data_val = struct2cell(obj(i).data.to_head_struct(false,true));
    else
        data_val  = {};
    end
    sqw_val = {obj(i).main_header.nfiles,obj(i).pix.num_pixels,...
        obj(i).pix.data_range,obj(i).main_header.creation_date};
    all_val = [dnd_val(1:end-1);sqw_val(:);data_val(:)];
    hout{i} = cell2struct(all_val,fields_req);
end

if nout>0
    if nout == 1
        varargout{1} = [hout{:}];
    else
        for i=1:nout
            varargout{i} = hout{i};
        end
    end
else
    for i=1:nw
        display(hout{i})
    end
end
