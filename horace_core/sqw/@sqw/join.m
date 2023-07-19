function wout = join(w,wi)
% Join an array of sqw objects into an single sqw object
% This is intended only as the reverse of split
%
%   >> wout = join(w,wi)
%   >> wout = join(w)
%
% Input:
% ------
%   w       array of sqw objects, each one made from a single spe data file
%   wi      initial pre-split sqw object (optional, recommended).
%
% Output:
% -------
%   wout    sqw object

% Original author: G.S.Tucker
% 2015-01-20

nfiles = length(w);

% Catch case of single contributing spe dataset
if nfiles == 1
    wout = w;
    return
end

initflag = exist('wi', 'var') && ~isempty(wi) && isa(wi, 'sqw') ...
    && wi.main_header.nfiles == nfiles;

% Default output
if initflag
    wout = sqw(wi);
    main_header = wi.main_header;
    detpar0 = wi.detpar;
else
    wout = sqw();
    main_header = w(1).main_header;
    main_header.nfiles = 1;
    detpar0 = w(1).detpar;
end

for i = 1:nfiles
    wi_main_header = w(i).main_header;
    wi_main_header.nfiles = 1;
    [ok, mess] = equal_to_tol(wi_main_header, main_header);
    if ~ok
        error('HORACE:join:invalid_argument', mess)
    end
end
clear main_header;
clear wi_main_header;

% Start pulling in data
experiment = cell(size(w));
detpar = cell(size(w));
data = cell(size(w));
pix = cell(size(w));
for i = 1:nfiles
    experiment{i} = w(i).experiment_info; % Will be used as is
    detpar{i} = w(i).detpar; % Needs to be reduced to only a single struct
    data{i} = w(i).data;     % Needs to be combined
    pix{i} = w(i).pix;
end

for i = 1:nfiles
    detpar_t = w(i).detpar;
    [ok, mess] = equal_to_tol(detpar_t, detpar0);
    if ~ok
        error('HORACE:join:invalid_argument', mess)
    end
end

% Check which sqw objects in the input structure contributed to the
% pre-split sqw object.
run_contributes = (cellfun(@(x) ...
                           any(x.s, 'all') || ...
                           any(x.e, 'all') || ...
                           any(x.npix, 'all'), data) ...
                   | ...
                   cellfun(@(x) ...
                           any(~isnan(x.pix_range), 'all') || ...
                           any(x.data, 'all'), pix));

main_header.nfiles = sum(run_contributes); % For the output structure

data = data(run_contributes);
pix = pix(run_contributes);
experiment = experiment(run_contributes);

for i = 1:numel(pix)
    pix{i}.run_idx = i; % repopulate individual run numbers
end

wout.main_header = main_header;
 % This should be a cell array of the individual headers
wout.experiment_info = Experiment.combine_experiments(experiment, false, true);
wout.detpar = detpar0;

wout.data = data{1};

sz = size(wout.data.npix); % size of contributing signal, variance, and npix arrays
wout.data.s = zeros(sz);
wout.data.e = zeros(sz);
wout.data.npix = zeros(sz);

for i = 1:numel(data)
    wout.data.s = wout.data.s + (data{i}.s .* data{i}.npix);
    wout.data.e = wout.data.e + (data{i}.e .* (data{i}.npix .^ 2));
    wout.data.npix = wout.data.npix + data{i}.npix;
end

[wout.data.s, wout.data.e] = normalize_signal(wout.data.s, wout.data.e, wout.data.npix);

ind = zeros(sz);
num_pix = sum(wout.data.npix, 'all');
wout.pix = PixelDataMemory(num_pix);

for i = 1:numel(pix)
    curr_pix = 1;
    local_npix_ind = 1;
    for j = 1:numel(wout.data.npix)
        curr_npix = data{i}.npix(j);
%         if curr_npix == 0
%             local_npix_ind = local_npix_ind + wout.data.npix(j);
%             continue
%         end
        local_ind = local_npix_ind+ind(j);

        wout.pix.data(:, local_ind:local_ind+curr_npix-1) = ...
            pix{i}.data(:, curr_pix:curr_pix+curr_npix-1);
        curr_pix = curr_pix + curr_npix;
        ind(j) = ind(j) + curr_npix;
        local_npix_ind = local_npix_ind + wout.data.npix(j);
    end
end

end
