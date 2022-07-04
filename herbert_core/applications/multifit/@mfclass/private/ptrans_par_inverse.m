function [pf,p,bp]=ptrans_par_inverse(S, p_info)
% Change parameter value cell arrays to floating parameter values for function evaluation
%
%   >> [pf,ok,mess,p,bp]=ptrans_par_inverse(S, p_info)
%
% Input:
% ------
%   S       Structure with fields:
%               p      - Foreground parameter values (if foreground function(s) present)
%                          If only one function, a row vector
%                          If more than one function: a row cell array of row vectors
%               bp     - Background parameter values (if background function(s) present)
%                          If only one function, a row vector
%                          If more than one function: a row cell array of row vectors
%          (This is the format produced by fit and simulate)
%
%   p_info  Structure containing information to convert to function parameters
%          (See the function ptrans_initialise for details)
%
% Output:
% -------
%   pf      Array of free parameters
%   p       Column cell array of column vectors, each with the parameter values
%          for the foreground function(s)
%   bp      Column cell array of column vectors, each with the parameter values
%          for the background function(s)
%   ok      True if S and p_info are mutually consistent once free parameters
%          have been subsituted from S
%   mess    Error message if not ok; if ok then mess = ''


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)

    if ~isstruct(S)
        error('HERBERT:mfclass:invalid_argument', 'Input argument is not a structure')
    end

    [p_in] = extract_parameters (S, true, p_info);
    [bp_in] = extract_parameters (S, false, p_info);

    pp_in = [p_in;bp_in];
    pf = pp_in(p_info.free);
    [p,bp]=ptrans_par(pf,p_info);

    % Check that the parameters generated fromt the free parameters are consistent with input
    pp = [zeros(0,1); cell2mat(cellfun(@(x)x(:),p,'UniformOutput',false));...
          cell2mat(cellfun(@(x)x(:),bp,'UniformOutput',false))];
    tol = 1e-12;
    min_denominator = 1;
    if ~equal_to_relerr(pp_in,pp,tol,min_denominator)
        error('HERBERT:mfclass:bad_binding', 'The fixed and/or binding ratios of input argument parameters are inconsistent with those of the object');
    end
end

%--------------------------------------------------------------------------------------------------
function [pp0] = extract_parameters (S,is_fore,p_info)
    % Extraact the input parameters, checking for consistency of lengths of arrays with object

    if is_fore
        str = 'fore';
        nam = 'p';
        nptot = p_info.nptot;
        np = p_info.np;
    else
        str = 'back';
        nam = 'bp';
        nptot = p_info.nbptot;
        np = p_info.nbp;
    end

    % Check that the required fields are present
    if nptot > 0     % there are foreground function parameters
        if isfield(S,nam)
            if isnumeric(S.(nam))
                if numel(np) == 1 && numel(S.(nam)) == nptot
                    pp0 = S.(nam)(:);
                else
                    error('HERBERT:mfclass:invalid_argument', ['Input argument ',str,'ground parameter array length is inconsistent with object']);
                end
            elseif iscell(S.(nam)) && all(cellfun(@isnumeric,S.(nam)))
                if numel(S.(nam)) == numel(np) && all(cellfun(@numel,S.(nam)) == np)
                    pp0 = [zeros(0,1);cell2mat(cellfun(@(x)x(:),S.(nam),'UniformOutput',false)')];     % enforce [0,1] if empty
                else
                    error('HERBERT:mfclass:invalid_argument', ['Input argument ',str,'ground parameter cell array or element lengths are inconsistent with object'])
                end
            else
                error('HERBERT:mfclass:invalid_argument', ['Input argument ',str,'ground parameter field is not a single numeric array or a cell array of numeric arrays']);
            end
        else
            error('HERBERT:mfclass:invalid_argument', ['Input argument does not contain any ',str,'ground parameter values']);
        end
    else
        if isfield(S,nam)
            if iscell(S.(nam)) && numel(S.(nam)) == numel(np) && all(cellfun(@isempty,S.(nam)))
                pp0 = zeros(0,1);
            else
                error('HERBERT:mfclass:invalid_argument', ['Input argument ',str,'ground parameter cell array or element lengths are inconsistent with object']);
            end
        else
            pp0 = zeros(0,1);
        end
    end
end
