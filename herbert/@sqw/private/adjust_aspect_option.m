function [ok,mess,adjust,present]=adjust_aspect_option(args_in)
% Determine presence and value of option to request the aspect ratio is adjusted
%
%   >> [args_out,status]=adjust_aspect_option(args_in)
%
% Input:
% ------
%   args_in     Cell array (row) of arguments
%
% Output:
% -------
%   args_out    Cell array of options with last one stripped if it is one
%              of the valid strings:
%               '-aspect'   Change aspect ratio according to data axes
%                          (This is the default if no option present)
%               '-noaspect' Do not change aspect ratio
%
%   status      true  if '-aspect' or neither present
%               false if '-noaspect'
%
% Isolate an option that needs to be coded better later on; present as part
% of on-going developments for non-orthogonal axes

% Toby Perring 10 August 2015


% Default
ok=true;
mess='';
adjust=true;
present=false;

% Strip off final option '-aspect' or '-noaspect'
if numel(args_in)>=1 && is_string(args_in{end}) && numel(args_in{end})>=2 && args_in{end}(1)=='-'
    tf=strncmpi(args_in{end},{'-aspect','-noaspect'},numel(args_in{end}));
    if any(tf)
        adjust=tf(1);
        present=true;
    else
        ok=false;
        mess=['Unrecognised option: ',args_in{end}];
        adjust=false;
        present=false;
    end
end
