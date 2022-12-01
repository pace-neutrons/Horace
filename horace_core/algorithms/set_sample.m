function varargout = set_sample (w,sample)
% Change the sample in an sqw object or array of objects
% in memory or on file
%
%   >> wout = set_sample (w, sample)
%
%
% Input:
% -----
%   w          Input sqw object or cell-array of objects or file or list
%              of files
%
%   sample      Sample object (IX_sample object)
%
% Output:
% -------
%   wout        depending on inpt, list of modified sqw objects or names of
%               modified files with sample set.
%

% Original author: T.G.Perring
%



% This routine is also used to set the sample in sqw files, when it overwrites the input file.

% Parse input
% -----------
if ~iscell(w)
    w = {w};
end
set_multi = numel(sample) == numel(w);

% Perform operations
% ==================
nobj=numel(w);     % number of sqw objects or files
out = cell(1,nobj);
for i=1:nobj
    win = w{i};
    if ischar(win)||isstring(win)
        out{i} = win;
        ldr = sqw_formats_factory.instance().get_loader(win);
        if ~ldr.sqw_type
            % Check that the data has the correct type
            error('HORACE:algorithms:invalid_argument', ...
                'Sample can only be set or changed in sqw-type data. File N%d, name: %s does not contain sqw object', ...
                i,win)
        end
        exper = ldr.get_header('-all');
        if set_multi
            exper = exper.set_sample(sample(i));
        else
            if isempty(sample)
                sample = IX_null_sample();
            end
            exper = exper.set_sample(sample(1));
        end
        ldr= ldr.upgrade_file_format(); % also reopens file in update mode if format is already the latest one
        ldr.put_samples(exper.samples);
        ldr.delete();
    elseif isa(win,'sqw')
        out{i} = win;
        exper = win.experiment_info;
        if set_multi
            exper = exper.set_sample(sample(i));
        else
            exper = exper.set_sample(sample(1));
        end
        out{i}.experiment_info = exper;
    else
        error('HORACE:algorithms:invalid_argument', ...
            'Sample can only be set or changed in sqw-type data. Object N%d, has type %s', ...
            i,class(win));
    end
end

% format output parameters according to the output request
if nargout == 1 && nobj>1
    varargout{1} = out;
else
    for i=1:nargout
        varargout{i} = out{i};
    end
end

