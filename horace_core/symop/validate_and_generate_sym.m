function [sym, fold] = validate_and_generate_sym(sym,proj)
% Check sym is a valid symmetry reduction and modify it according to
% symmetry rules.
%
% Handle conversion of sym into appropriate symmetry set
% for rotations.
%
% Inputs
% -------
% sym    Array or cell array of symmetry operations
%
% Outputs
% -------
% sym    Final set of symops to perform (expanded for rotations)
%
% fold   Number of symmetry operations to perform

if isa(sym, 'SymopReflection')
    fold = numel(sym);
    [the_same,zero_offset] = is_same_offset(sym);
    if ~the_same
        sym = num2cell(sym);
    end
elseif isa(sym, 'SymopRotation')

    % Don't need to do the 360 mapping (last == ID)
    fold = (360 / sym.theta_deg-1);

    if numel(sym) ~= 1
        error('HORACE:symmetrise_sqw:invalid_argument', ...
            'Rotational symmetry only possible for single rotation.')
    end

    if floor(fold) ~= fold
        error('HORACE:symmetrise_sqw:invalid_argument', ...
            ['Rotation is not an integer n-fold mapping onto the full circle.\n', ...
            'Fold : %1.3f'], fold+1)
    end
    zero_offset = all(abs(sym.offset(:)-zeros(3,1))<4*eps('double'));
    sym = repmat(sym, fold, 1);
elseif isa(sym,'SymopIdentity')
    fold = 1;
    zero_offset = true;
elseif iscell(sym)
    [offsets_the_same,zero_offset] = is_same_offset(sym);
    % If it's come from SymopRotation.fold or manual equivalent
    % We might have rot(0), or ID as first arg, all subsequent
    % rotations may be incremental (0, 90, 180, 270)
    % or repeated (0, 90, 90, 90) need to account for these
    if all(cellfun(@(x) isa(x, 'SymopRotation') || ...
            isa(x, 'SymopIdentity'), sym))
        if sym{1} ~= SymopIdentity() || ...
                isa(sym{1}, 'SymopRotation') && sym{1}.theta_deg ~= 0
            error('HORACE:symmetrise_sqw:invalid_argument', ...
                'For rotational reduction first element must be identity.')
        end

        fold = 360 / sym{2}.theta_deg;

        if floor(fold) ~= fold
            error('HORACE:symmetrise_sqw:invalid_argument', ...
                ['Rotation is not an integer n-fold mapping onto the full circle.\n', ...
                'Fold : %1.3f'], fold)
        end

        if numel(sym) ~= fold
            error('HORACE:symmetrise_sqw:invalid_argument', ...
                ['Cell array must be complete set of rotational reductions.\n', ...
                'Expected: %d, received: %d', fold, numel(sym)])
        end

        for i = 3:fold
            % If not regular fold or different offsets
            if ~offsets_the_same  || ~(...
                    abs(sym{i}.theta_deg-sym{2}.theta_deg)>4*eps('single') || ...
                    abs(sym{i}.theta_deg / (i-1)-sym{2}.theta_deg)>4*eps('single') ...
                    )
                error('HORACE:symmetrise_sqw:invalid_argument', [...
                    'Cell array rotation reduction must be either repeated array of one rotation\n' ...
                    'or evenly-spaced progression around unit circle\n'...
                    'having zero or the same offset for all rotations'])
            end
        end

        fold = fold - 1;
        sym = repmat(sym{2}, fold, 1);
    elseif all(cellfun(@(x) isa(x, 'SymopReflection') || ...
            isa(x, 'SymopIdentity'), sym))
        if offsets_the_same
            sym = cat(1, sym{:});
        end
        fold = numel(sym);
    else
        error('HORACE:symmetrise_sqw:not_implemented', ...
            'Cell array sym must be cell array of either all SymopReflection or all SymopRotation. (SymopIdentity is ignored)')
    end

else
    error('HORACE:symmetrise_sqw:not_implemented', ...
        'Symmetrise does not currently support %s', class(sym))
end
if ~zero_offset
    b_mat = proj.bmatrix(3);
    is_cell = iscell(sym);
    for i  =1:numel(sym)
        if is_cell
            sym{i}.b_matrix = b_mat;
        else
            sym(i).b_matrix = b_mat;
        end
    end
end
end

function [same,is_zero_offset] = is_same_offset(sym)
% check if all offsets, present on symmetry transformation are the same
if iscell(sym)
    offsets = cellfun(@(x)(x.offset),sym,'UniformOutput',false);
else
    offsets = arrayfun(@(x)(x.offset),sym,'UniformOutput',false);
end
is_zero_offset = true;
max_err = 4*eps('double');
for off = offsets
    same = all(abs(off{1}-offsets{1})<max_err);
    if is_zero_offset
        is_zero_offset = all(abs(off{1}(:) - zeros(3,1))<max_err);
    end
    if ~same
        is_zero_offset = false;
        break
    end
end

end