function [proj, pbin, sym, opt] = ...
    cut_parse_inputs_(obj, ndims_in, return_cut, varargin)
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
%   >> {data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin, sym}
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
%
%   sym          Symmetry operator (or an array of symmetry operators
%                  to be applied in the order sym(1), sym(2),...)
%                  by which a symmetry related cut is to be accumulated.
%                   Must be a subclass of Symop.
%
%                For several symmetry related cuts, provide a cell array
%                  of symmetry operators and/or arrays of symmetry operators
%           EXAMPLES
%                   s1 = SymopReflection([1,0,0],[0,1,0],[1,1,1]);
%                   s2 = SymopReflection([1,0,0],[0,0,1],[1,1,1]);
%                   % For all four symmetry related cuts:
%                   sym = {s1,s2,[s1,s2]};
%                    The following cuts will be accumulated:
%                       -- Apply identity (original binning)
%                       -- Apply s1
%                       -- Apply s2
%                       -- Apply s2*s1
%
%NOTE:
% The cut bin ranges are expressed in the coordinate system related to
% the target projection
%
%
% Parse the input arguments to cut
%
%   >> [proj, pbin, sym, opt] = ...
%           cut_sqw_parse_inputs_(data_source_in, ndims_in, return_cut, a1, a2,...)
%
% This function determines if the input arguments a1, a2,... have the form:
%    ([proj,] p1_bin, p2_bin,..., arg1, arg2, ...
%           [keyword_1[, val_1],] [keyword_2[, val_2],...,] [sym,] ['-save' &/or <filename>])
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
%  sym              Symop, or array/cell array thereof
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

parse_opt = struct('keys_at_end',false);
[par, keyval, present, ~, ok, mess] = parse_arguments(varargin, keyval_def, flags, parse_opt);
if ~ok
    error('HORACE:cut:invalid_argument', mess)
end

% For backwards compatibility with syntax that allows a character array
% to be the output filename without the '-save' option, assume that if
% the last element of par is a character string then it is a file name
if ~isempty(par) && istext(par{end}) && ~strncmp(par{end}, '-', 1)
    outfile = par{end};
    par = par(1:end-1);
else
    outfile = '';
end

% Get leading projection, if present, and strip from parameter list
% -----------------------------------------------------------------

opt.proj_given = ~isempty(par) && ...
    (isstruct(par{1}) || isa(par{1},'aProjectionBase'));

if opt.proj_given
    if isa(par{1},'aProjectionBase')
        proj=par{1};
    else
        proj=line_proj(par{1});
    end
    par = par(2:end);
    % all components of Q and energy
    npbin_expected = 4;
else
    proj = obj.proj;
    % must match the number of plot axes
    npbin_expected = ndims_in;
end

% Get symmetry operations, if present, and strip from parameter list
% ------------------------------------------------------------------

if isa(par{end}, 'Symop') || ...
        iscell(par{end}) && any(cellfun(@(x) isa(x, 'Symop'), par{end}))

    sym = par{end};
    par = par(1:end-1);

    sym = check_sym_arg(sym);
else
    sym = {SymopIdentity()};
end

% Do checks on remaining input arguments
% --------------------------------------
% Get remaining arguments with projection stripped off if necessary

% Checks on binning arguments and get excess arguments
if numel(par) < npbin_expected
    if opt.proj_given          % must refer to new projection axes
        error('HORACE:cut:invalid_argument',...
            'Must give binning arguments for all four dimensions if new projection axes');
    else                   % must refer to plot axes (in the order of the display list)
        error('HORACE:cut:invalid_argument',...
            'Number of binning arguments must match the number of dimensions of the sqw data being cut');
    end

elseif numel(par) > npbin_expected
    error('HORACE:cut:invalid_argument',...
        'Unrecognised additional input(s): "%s" were provided to cut',...
        disp2str(par(npbin_expected+1:end)));
end

pbin = par(1:npbin_expected);

pbin_ok = cellfun(@(x) isempty(x) || isnumeric(x), pbin);
if ~all(pbin_ok)
    error('HORACE:cut:invalid_argument',...
        'Binning arguments must all be numeric, but arguments: %s are not',...
        disp2str(find(~pbin_ok)));
end

pbin_expanded = false(size(pbin)); % if some of the binning parameters have
% 4 elements, this means that the binning parameters describe multiple
% cuts
for i=1:npbin_expected
    if isempty(pbin{i})
        pbin{i} = [];
        pbin_expanded(i) = false;
    elseif isnumeric(pbin{i})
        [pbin{i},pbin_expanded(i)] = make_row_check_expansion(pbin{i});  % ensure row vectors and check if the vector has 4 elements
    end
end

if opt.proj_given
    % There are currently no situations where we want to define lattice in
    % projection. so always take lattice from the source object
    source_proj = obj.proj;
    %if ~proj.alatt_defined
    proj.do_check_combo_arg = false;
    proj.alatt = source_proj.alatt;
    %end
    %if ~proj.angdeg_defined
    proj.angdeg = source_proj.angdeg;
    proj.do_check_combo_arg = true;    
    proj = proj.check_combo_arg();
    %end

else % it may be fewer parameters then actual dimensions and
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
    [pbin,pbin_expanded] = cellfun(@make_row_check_expansion,pbin,'UniformOutput',false);
    pbin = pbin';
    pbin_expanded = [pbin_expanded{:}];
end

if any(pbin_expanded)
    pbin = expand_multicuts(pbin,pbin_expanded);
else
    pbin = {pbin};
end

% Check consistency of optional arguments
% ---------------------------------------
% Fill options structure (output file name filled in next section)
opt.keep_pix = keyval.pix;
opt.parallel = keyval.parallel;

% Save to file if '-save', prompting for file if no file name provided
save_to_file = keyval.save || (~present.save && ~isempty(outfile));

if present.save && isempty(outfile)
    error('HORACE:cut:invalid_argument',...
        'Use of ''-save'' option and/or provision of output file name are not consistent');
end

if ~save_to_file && ~return_cut
    % Check work needs to be done (*** might want to make this case prompt to save to file)
    error('HORACE:cut:invalid_argument', ...
        'Neither output cut object nor output file requested - routine is not being asked to do anything');
end

if save_to_file
    % Check output file name
    if ~isempty(outfile)
        % Check file name makes reasonable sense if one has been supplied
        [~,~,out_ext]=fileparts(outfile);
        if length(out_ext) <= 1    % no extension or just a dot
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

        if isempty(outfile)
            error('HORACE:cut:invalid_argument',...
                'No output file name given');
        end
    end

    % Test output file can be opened - don't want to discover there are problems after lots of calculation
    % [Not yet fully supported with sqw_formats_factory but can be. For now just test creation of new file
    % is possible and delete it]
    fout = fopen (outfile, 'wb');   % this command also clears contents of existing file
    if (fout < 0)
        error('HORACE:cut:invalid_argument', ...
            'Cannot open output file %s',outfile)
    end
    fclose(fout);
    delete(outfile);

end
opt.outfile = outfile;

end

function [x,multicut]=make_row_check_expansion(x)

x = x(:)';
multicut = numel(x) == 4;

end

function pbin = expand_multicuts(pbin,pbin_expanded)
% expand binning parameters, presented as multicut into matrix of 2&3-element
% binning parameters (integration ranges and projection axes)
%
pbin_tmp = pbin;
for i=1:numel(pbin_expanded)
    if pbin_expanded(i)
        pbin_multi = pbin{i};
        if pbin_multi(1) >= pbin_multi(3)
            error('HORACE:cut:invalid_argument',...
                'third element (phi = %g) of multicut parameter N %d ([plo, rdiff, phi, rwidth]) must be larger then first (plo = %g)',...
                pbin_multi(3),i,pbin_multi(1));
        end
        if pbin_multi(2) <= 0
            error('HORACE:cut:invalid_argument',...
                'second element (rdiff = %g) of of multicut parameter N %d ([plo, rdiff, phi, rwidth]) must be larger then 0',...
                pbin_multi(2),i);
        end
        if pbin_multi(4) <= 0
            error('HORACE:cut:invalid_argument',...
                'forth element (rwidth = %g) of of multicut parameter N %d ([plo, rdiff, phi, rwidth]) must be larger then 0',...
                pbin_multi(4),i);
        end

        n_cuts = floor((pbin_multi(3)-pbin_multi(1))/pbin_multi(2));

        if abs(pbin_multi(3)-pbin_multi(1)-n_cuts*pbin_multi(2)) > 4*eps
            n_cuts = n_cuts+1;
        end

        pbin_multi(3) = pbin_multi(1)+n_cuts*pbin_multi(2);
        cut_par = cell(1,n_cuts+1);
        width =  pbin_multi(4);

        for j=1:n_cuts+1
            center = pbin_multi(1)+(j-1)*pbin_multi(2);
            cut_par{j} = [center-0.5*width,center+0.5*width];
        end

        cut_par   = repmat(cut_par,size(pbin_tmp,1),1);
        pbin_tmp  = repmat(pbin_tmp,n_cuts+1,1);
        pbin_tmp(:,i) = cut_par(:);
    end
end
jind = num2cell(1:size(pbin_tmp,1));
pbin_tmp = cellfun(@(ind)({pbin_tmp(ind,:)}),jind,'UniformOutput',true);

pbin = pbin_tmp;

end

function pbin = select_pbin(pbin_given,paxis)

if isempty(pbin_given)
    bin_width = paxis(2) - paxis(1);
    bin_centers = 0.5*(paxis(1:end-1)+paxis(2:end));
    pbin = [bin_centers(1),bin_width,bin_centers(end)];

elseif numel(pbin_given) == 1
    if abs(pbin_given) < eps('single')
        new_axis = paxis;
    else
        n_steps = floor((paxis(end)-paxis(1))/pbin_given);
        paxis_end = paxis(1)+pbin_given*n_steps;        
        if paxis(end)-paxis_end  > 4*eps('single')
            n_steps = n_steps+1;
        end
        paxis_end = paxis(1)+pbin_given*n_steps;
        new_axis = linspace(paxis(1),paxis_end,n_steps+1);
    end
    bin_centers = 0.5*(new_axis(1:end-1)+new_axis(2:end));
    pbins =  new_axis(2:end)-new_axis(1:end-1);
    pbin = sum(pbins)/numel(pbins);
    pbin = [bin_centers(1),pbin,bin_centers(end)];

elseif size(pbin_given,1) > 1
    pbin = pbin_given';
else
    pbin = pbin_given;
end

end

function sym_out = check_sym_arg(sym)
% Checks on symmetry description - check valid, and remove empty descriptions
%
%   >> sym_out = check_sym_arg(sym)
%
% Input:
% ------
%   sym     Symmetry description, or cell array of symmetry descriptions.
%           A symmetry description can be:
%           - Scalar Symop object
%           - Array of Symop objects (multiple Symops to be performed in sequence)
%           - Empty argument (which will be removed)
%
% Output:
% -------
%
%   sym_out Cell array of symmetry descriptions from input sym, each one a
%             scalar or row vector of Symop objects.
%
%           Always add identity in addition to other kept symops
%
%           Empty symmetry descriptions or identity descriptions
%             are removed from the cell array.

if ~iscell(sym)   % make a cell array for convenience
    sym = {sym};
else
    sym = sym(:);
end

keep = true(size(sym));
for i=1:numel(sym)
    sym{i} = make_row(sym{i});
    if ~isempty(sym{i}) && ~isa(sym{i}, 'Symop')
        error('HORACE:cut:invalid_argument', ...
            'Symmetry descriptor must be an symop object or array of symop objects, or a cell of those');
    end

    keep(i) = ~isempty(sym{i}) && ...
        ~all(arrayfun(@(x) isa(x, 'SymopIdentity'), sym{i}));
end

%Always add identity in addition to other kept symops
sym_out = [{SymopIdentity()}; sym(keep)];

end
