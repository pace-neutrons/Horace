function varargout = head(obj,varargin)
% Display a summary of an sqw object or file containing sqw information.
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
[ok,mess,full_data] = parse_char_options(varargin,{'-full'});
if ~ok
    error('HORACE:head:invalid_argument',mess);
end

nout = nargout;
nw = numel(obj);
if nout==0
    for i=1:nw
        display(obj(i));
    end
else
    hout = cell(1,nw);
    for i=1:nw
        hout{i} =obj(i).data.to_head_struct(full_data);
        hout{i}.npixels = obj(i).pix.num_pixels;
        hout{i}.nfiles   = obj(i).main_header.nfiles;
        hout{i}.creation_date= obj(i).main_header.creation_date;
    end
end
if nout>0
    varargout = hout(1:nout);
end
