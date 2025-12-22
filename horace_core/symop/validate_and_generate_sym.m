function [sym, fold] = validate_and_generate_sym(sym)
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

    sym = repmat(sym, fold, 1);
elseif isa(sym,'SymopIdentity')
    fold = 1;
elseif iscell(sym)
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
            % If not regular fold
            if ~(equal_to_tol(sym{i}.theta_deg, sym{2}.theta_deg, 'tol', 1e-4) || ...
                    equal_to_tol(sym{i}.theta_deg / (i-1), sym{2}.theta_deg, 'tol', 1e-2))
                error('HORACE:symmetrise_sqw:invalid_argument', ...
                    ['Cell array rotation reduction must be either repeated array' ...
                    ' of one rotation or evenly-spaced progression around unit circle'])
            end
        end

        fold = fold - 1;
        sym = repmat(sym{2}, fold, 1);

    elseif all(cellfun(@(x) isa(x, 'SymopReflection') || ...
            isa(x, 'SymopIdentity'), sym))
        sym = cat(1, sym{:});
        fold = numel(sym);
    else
        error('HORACE:symmetrise_sqw:not_implemented', ...
            'Cell array sym must be cell array of either all SymopReflection or all SymopRotation. (SymopIdentity is ignored)')
    end

else
    error('HORACE:symmetrise_sqw:not_implemented', ...
        'Symmetrise does not currently support %s', class(sym))
end
end
