function varargout = head(obj,varargin)
% Display a summary of an dnd object or array of dnd objects.
%
%   >> head(w)              % Display summary for object (or array of objects)
%   >> head(sqw,filename)   % Display summary for named file (or array of names)
%
% To return header information in a structure, without displaying to screen:
%
%   >> h=head(...)          % Fetch principal header information
%   >> h=head(...,'-full')  % Fetch full header information
%
%
% The facility to get head information from file(s) is included for completeness, but
% more usually you would use the function:
%   >> head_horace(filename)
%   >> h=head_horace(filename)
%   >> h=head_horace(filename,'-full')
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
%   '-full'     if present, then returns all header and the
%               image information.
%   '-data_only' if present, then returns all header and the
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
[ok,mess,hfull,data_only] = parse_char_options(varargin,{'-full','-data_only'});
if ~ok
    error('HORACE:DnDBase:invalid_argument',mess);
end
nout = nargout;

nw = numel(obj);

hout = cell(1,nw);
if nout>0
    for i=1:nw
        hout{i} =obj(i).to_head_struct(hfull,data_only);
    end


    if nout == 1
        varargout{1} = [hout{:}];
    else
        for i=1:nout
            varargout{i} = hout{i};
        end
    end
else
    for i=1:nw
        sqw_display_single(obj(i))
    end
end

