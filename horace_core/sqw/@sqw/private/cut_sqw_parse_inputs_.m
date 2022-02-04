function [proj, pbin,opt] = ...
    cut_sqw_parse_inputs_(obj,ndims_in, return_cut, varargin)
% Take cut parameters in any possible form (see below)
% and return the standard form of the parameters.
%
% Inputs:
% ndims      -- number of dimensions in the input data object to cut
%
% return_cut -- if true, cut should be returned as requested, if false, cut
%               would be written to file
%
% varargin   -- any of the following:
%   >> {data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin}
%
%   >> {..., '-nopix'}      % output cut is dnd structure (i.e. no
%                                   % pixel information is retained)
%
%   >>{...,  filename}  % save cut to named file
%
% where:
% ------
%   varargin contains:
%
%   proj           Data structure containing details of the requested projection
%                  or the structure, which defines projection (may be
%                  missing)
%
%   p1_bin          Binning along first Q axis
%   p2_bin          Binning along second Q axis
%   p3_bin          Binning along third Q axis
%   p4_bin          Binning along the energy axis:
%   with any of the following formats:
%           - [] or ''          Plot or integration axis: use bin boundaries
%                               and the binning of input data.
%           - [pstep]           Plot axis: sets step size; plot limits
%                               taken from the extent of the data. If pstep
%                               is 0, step is also taken from input data
%                               (equivalent to [])
%           - [plo, phi]        Integration axis: range of integration
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centers
%                               and step size
%                               For example, [106, 4, 116] will define a plot
%                               axis with bin edges 104-108, 108-112, 112-116.
%                               if step is 0, the step is taken from the
%                               step of the input data
%           - [plo, rdiff, phi, rwidth]
%                                Integration axis: minimum range center,
%                                distance between range centers, maximum range
%                                center, range size for each cut.
%                                When using this syntax, an array of cuts is
%                                returned. The number of cuts produced will
%                                be the number of rdiff sized steps between plo
%                                and phi; phi will be automatically increased
%                                such that rdiff divides phi - plo.
%                                For example, [106, 4, 113, 2] defines the
%                                integration range for three cuts, the first
%                                cut integrates the axis over 105-107, the
%                                second over 109-111 and the third 113-115.

% Parse the input arguments to cut_sqw_main and cut_sqw_sym_main
%
%   >> [proj, pbin, opt] = ...
%           cut_sqw_parse_inputs_(data_source_in, ndims_in, return_cut, a1, a2,...)
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
%   a1, a2,...      Arguments in arbitrary form:
%                   ([proj], p1_bin, p2_bin,..., arg1, arg2, ...
%                       [keyword_1[, val_1]], [keyword_2[, val_2]],...
%                       ['-save' &/or <filename>])
%                  where the filename can appear immediately before or in
%                  amongst any keywords
% each pN_bin can contains the following parameters:
%          - [] or ''          Use default bins (bin size and limits)
%          - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%          - [plo, phi]        Integration axis: range of integration
%          - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
%          - [plo, pstep, phi, width] Integration axis: one output cut for each integration
%                               range centred on plo, plo+step, plo+2*step... and with width
%                               given by 'width'
%                               If width=0, it is taken to be equal to pstep.
%
% Output:          Returns the aruments in standard form
% -------
%   proj            Projection object, or [] if no projection information given
%   pbin            Cell array of numeric row vectors containing binning
%                  information. The length of the vectors is not checked
%   opt             Options structure. Currently has fields
%                   keep_pix    True if pixels to be kept, false otherwise
%                   parallel    True if parallel cut option to be used
%                   outputfile  Name of output file to which to save file.
%                               If no saving required, then is ''


% Default output of correct classes
opt = struct();


% Parse the input arguments
% -------------------------
keyval_def = struct('pix',true,'parallel',false,'save',false);
flags = {'pix','parallel','save'};

parse_opt = struct('prefix','-','keys_at_end',false);
[par, keyval, present, ~, ok, mess] = parse_arguments(varargin, keyval_def, flags, parse_opt);
if ~ok
    error('HORACE:cut:invalid_argument', mess)
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
    if isa(par{1},'aProjection')
        proj=par{1};
    else
        proj=ortho_proj(par{1});
    end
    par = par(2:end);
    proj_given=true;
else
    proj = obj.get_projection();
    proj_given=false;
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
            pbin{i} = make_row(pbin{i});  % ensure row vectors
        else
            pbin_ok(i) = false;
        end
    end
    if ~all(pbin_ok)
        error('HORACE:cut:invalid_argument',...
            'Binning arguments must all be numeric, but arguments: %s are not',...
            evalc('disp(find(~pbin_ok))'));
    end
    args = par(npbin_expected+1:end);
    if ~isempty(args)
        args = evalc('disp(args)');
        error('HORACE:cut:invalid_argument',...
            'Unrecognised additional input(s): "%s" were provided to cut',...
            args);
    end
else
    if ~proj_given          % must refer to plot axes (in the order of the display list)
        error('HORACE:cut:invalid_argument',...
            'Number of binning arguments must match the number of dimensions of the sqw data being cut');
    else                    % must refer to new projection axes
        error('HORACE:cut:invalid_argument',...
            'Must give binning arguments for all four dimensions if new projection axes');
    end
end
if ~proj_given % it may be fewer parameters then actual dimensions and
    % if no projection is given, we would like to append missing binning
    % parameters with their default values.
    pbin_tmp = pbin;
    pbin = cell(4,1);
    % run checks on given pbin, and if given pbin is empty, take pbin from
    % existing projection axis
    paxis = cellfun(@select_pbin,pbin_tmp,obj.p,'UniformOutput',false);
    pbin(obj.pax) = paxis(:);
    % set other limits to integration axis
    pbin(obj.iax) = num2cell(obj.iint,1);
    % ensure row vectors    
    pbin = cellfun(@make_row,pbin,'UniformOutput',false);
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
    error('HORACE:cut:invalid_argument',...
        'Use of ''-save'' option and/or provision of output file name are not consistent');
end

if save_to_file
    % Check output file name
    if ~isempty(outfile)
        % Check file name makes reasonable sense if one has been supplied
        [~,~,out_ext]=fileparts(outfile);
        if length(out_ext)<=1    % no extension or just a dot
            error('HORACE:cut:invalid_argument',...
                'Output filename  ''%s'' has no extension - check optional arguments',...
                outfile);
        end
    else
        % Prompt for output file name
        if opt.keep_pix
            outfile = putfile('*.sqw');
        else
            outfile = putfile('*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
        end
        if (isempty(outfile))
            error('HORACE:cut:invalid_argument',...
                'No output file name given');
        end
    end
    
    % Test output file can be opened - don't want to discover there are problems after lots of calculation
    % [Not yet fully supported with sqw_formats_factory but can be. Now just test creation of new file
    % is possible  and delete it]
    fout = fopen (outfile, 'wb');   % this command also clears contents of existing file
    if (fout < 0)
        error('HORACE:cut:invalid_argument', ...
            'Cannot open output file %s',outfile)
    end
    fclose(fout);
    delete(outfile);
    
elseif ~return_cut
    % Check work needs to be done (*** might want to make this case prompt to save to file)
    error('HORACE:cut:invalid_argument', ...
        'Neither output cut object nor output file requested - routine is not being asked to do anything');
end
opt.outfile = outfile;
%
function x=make_row(x)
if size(x,1)>1
    x = x';
end

function pbin=select_pbin(pbin_given,paxis)

if isempty(pbin_given)
    bin_width = paxis(2)-paxis(1);
    pbin = [paxis(1),bin_width,paxis(end)];
    return
end
if numel(pbin_given) == 1
    pbin = [paxis(1),pbin_given,paxis(end)];
    return
end
if size(pbin_given,1)>1
    pbin = pbin_given';
else
    pbin = pbin_given;
end