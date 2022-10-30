function [nin,nout,fn_present,filenames,argi]= parse_cut_inputs_(nin,nout,varargin)
% partial parser for inputs of the genetic cut function, extracted into
% separate routine for testability
%
% Inputs:
% nin       -- number of object to make cut
% nout      -- number of object to return from cut function
% varargin  -- other cut arguments, containing the parameters, necessary
%              for cut including optional filenames
% Output
% nin       -- modified and verified number of input objects to cut
% nout      -- number of outputs, requested by the function. May be
%              provided as one of the function methods
% fn_present-- logical indicating that filenames are present among cut
%              inputs
% filenames -- number of files to save cuts into 
% argi      -- other cut arguments stripped from the filenames

is_nout = strcmpi(varargin,'-nargout');
if any(is_nout)
    nou = find(is_nout);
    nout_pos = nou+1;
    is_nout(nout_pos) = true;
    nout = varargin{nout_pos};
    argi = varargin(~is_nout);
    if ~(isnumeric(nout)&&isscalar(nout))
        error('HORACE:cut:invalid_argument', ...
            'Number of ouptput argument parameter should be numeric scalar. It is %s', ...
            disp2str(nout));
    end
else
    argi = varargin;
end

% check if names of the files to save cut results are present, stored
% in cellarray and defined for all cuts to write to.
is_filename = cellfun(@(x)(iscell(x)&&(ischar(x{1})||isstring(x{1}))|| ...
    ((ischar(x)||isstring(x))&&~strncmp(x,'-',1))),argi);
fn_present = any(is_filename);
if ~fn_present
    if nout == 0
        error('HORACE:cut:invalid_argument', ...
            'cut(s) without output objects are requested but no file(s) to save their results are provided');
    end
    filenames = {};
else
    filenames = argi(is_filename);
    argi = argi(~is_filename);
    if ischar(filenames)||isstring(filenames)
        if nin>1
            [fb,fn,fext] = fileparts(filenames);
            filenames = cell(nin,1);
            for i=1:nin
                f_name = sprintf('%s_cutN%d%s',fn,i,fext);
                filenames{i} = fullfile(fb,f_name);
            end
        else
            filenames = {filenames};
        end
    else % cell;
        if numel(filenames) < nin
            error('HORACE:cut:invalid_argument', ...
                'Multiple cuts with output to file are requested, but number of output files is smaller then number of cuts to do')
        end
    end
end

if nout>1
    if nout>nin
        error('HORACE:cut:invalid_argument', ...
            'Number of input cut sources (%d) is smaller then number of requested outputs (%d)',...
            nin,nout);
    end
    nin = nout;
end
