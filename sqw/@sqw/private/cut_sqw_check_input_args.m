function [ok, mess, data_source, proj, pbin, args, opt] = ...
    cut_sqw_check_input_args (data_source_in, ndims_in, return_cut, varargin)
% Parse the input arguments to cut_sqw_main and cut_sqw_sym_main
%
%   >> [ok, mess, data_source, proj, pbin, args, opt] = ...
%           cut_sqw_check_input_args (data_source_in, ndims_in, return_cut, a1, a2,...)
%
% This function determine if the input arguments a1, a2,... have the form:
%    ([proj], p1_bin, p2_bin,..., arg1, arg2, ...
%           [keyword_1[, val_1]], [keyword_2[, val_2]],..., ['-save' &/or <filename>])
% where the filename can appear immediately before or in amongst any keywords
%
% Input:
% ------
%   data_source_in  Input data source (cellstr or sqw object)
%   ndims_in        Dimensionality of the sqw object in the file or object
%   return_cut      True if a cut is to be returned, false if not
%   a1, a2,...      Arguments ([proj], p1_bin, p2_bin,..., arg1, arg2, ...
%                       [keyword_1[, val_1]], [keyword_2[, val_2]],...
%                       ['-save' &/or <filename>])
%                  where the filename can appear immediately before or in
%                  amongst any keywords
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message if not OK, empty string '' otherwise
%   data_source     Name of file containing sqw data, or sqw object
%   proj            Projection object, or [] if no projection information given
%   pbin            Cell array of numeric row vectors containing binning 
%                  information. The length of the vectors is not checked
%   args            Cell array of any other arguments
%   opt             Options structure. Currently has fields
%                       keep_pix    True if pixels to be kept, false otherwise
%                       parallel    True if parallel cut option to be used
%                       outputfile  Name of output file to which to save file.
%                                   If no saving required, then is ''


% T.G.Perring: 26 August 2018


% Default output of correct classes
proj = projection(struct());
pbin = cell(1,0);
args = cell(1,0);
opt = struct();


% Determine if data source is sqw object or file
% ----------------------------------------------
if iscellstr(data_source_in)
    data_source=data_source_in{1};
elseif ischar(data_source_in)
    data_source=data_source_in;
elseif isa(data_source_in,'sqw')
    data_source=data_source_in;
else
    error('CUT_SQW:runtime_error',...
        'Logic problem in chain of cut methods. See T.G.Perring')
end


% Parse the input arguments
% -------------------------
keyval_def = struct('pix',true,'parallel',false,'save',false);
flags = {'pix','parallel','save'};

parse_opt = struct('prefix','-','keys_at_end',false);
[par, keyval, present, ~, ok, mess] = parse_arguments (varargin, keyval_def, flags, parse_opt);
if ~ok
    return
end
% For reasons of backwards compatibility with the syntax that allows a character string
% to be the output filename without the '-save' option being given, assume that if
% the last element of par is a character string then it is a file name
if numel(par)>0 && is_string(par{end})
    outfile = par{end};
    par = par(1:end-1);
else
    outfile = '';
end


% Get leading projection, if present, and strip from parameter list
% -----------------------------------------------------------------
if numel(par)>=1 && (isstruct(par{1}) ||...
        isa(par{1},'aProjection') || isa(par{1},'projaxes'))
    proj_given=true;
    if isa(par{1},'aProjection')
        proj=par{1};
    else
        proj=projection(par{1});
    end
    par = par(2:end);
else
    proj_given=false;
    proj = [];
end


% Do checks on remaining input arguments
% --------------------------------------
% Get remaining arguments with projection stripped off if necessary
if proj_given
    npbin_expected = 4;         % all components of Q and energy
else
    npbin_expected = ndims_in;  % must match the number of plot axes
end

% Checks on binning arguments and get excess arguments
if numel(par)>=npbin_expected
    pbin = par(1:npbin_expected);
    pbin_ok = true(size(pbin));
    for i=1:npbin_expected
        if isempty(pbin{i})
            pbin{i} = [];
        elseif isnumeric(pbin{i})
            pbin{i} = pbin{i}(:)';  % ensure row vectors
        else
            pbin_ok(i) = false;
        end
    end
    if ~all(pbin_ok)
        ok = false;
        mess = ['Binning arguments must all be numeric, but arguments ',num2str(find(~pbin_ok)),' are not'];
        return
    end
    args = par(npbin_expected+1:end);
else
    ok = false;
    if ~proj_given          % must refer to plot axes (in the order of the display list)
        mess = 'Number of binning arguments must match the number of dimensions of the sqw data being cut';
    else                    % must refer to new projection axes
        mess = 'Must give binning arguments for all four dimensions if new projection axes';
    end
    return
end


% Check consistency of optional arguments
% ---------------------------------------
% Fill options structure (output file name filled in next section)
opt.keep_pix = keyval.pix;
opt.parallel = keyval.parallel;
opt.outfile = outfile;

% Save to file if '-save', prompting for file if no file name provided
if keyval.save || (~present.save && ~isempty(outfile))
    save_to_file = true;
elseif ~keyval.save && isempty(outfile)
    save_to_file = false;
else
    ok = false;
    mess = 'Use of ''-save'' option and/or provision of output file name are not consistent';
    return
end

if save_to_file
    % Check output file name
    if ~isempty(outfile)
        % Check file name makes reasonable sense if one has been supplied
        [~,~,out_ext]=fileparts(outfile);
        if length(out_ext)<=1    % no extension or just a dot
            ok = false;
            mess = ['Output filename ''',outfile,''' has no extension - check optional arguments'];
            return
        end
    else
        % Prompt for output file name
        if opt.keep_pix
            outfile = putfile('*.sqw');
        else
            outfile = putfile('*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
        end
        if (isempty(outfile))
            ok = false;
            mess = 'No output file name given';
            return
        end
    end
    
    % Test output file can be opened - don't want to discover there are problems after lots of calculation
    % [Not yet fully supported with sqw_formats_factory but can be. Now just test creation of new file
    % is possible  and delete it]
    fout = fopen (outfile, 'wb');   % this command also clears contents of existing file
    if (fout < 0)
        error ('CUT_SQW:runtime_error','Cannot open output file %s',outfile)
    end
    fclose(fout);
    delete(outfile);
    
elseif ~return_cut
    % Check work needs to be done (*** might want to make this case prompt to save to file)
    ok = false;
    mess = 'Neither output cut object nor output file requested - routine is not being asked to do anything';
    return
end

opt.outfile = outfile;
