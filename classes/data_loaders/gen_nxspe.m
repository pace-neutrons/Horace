function varargout = gen_nxspe(S,ERR,en,par_file,nxspe_file,efix, varargin)
% Function to create rundata object or cell array of such objects
% from existing signal, error and detector arrays and save this object to
% nxspe file(s) if requested.
%
% Usage:
%
%>>gen_nxspe(S,ERR,en,par_file,nxspefile_name,efix);
%  -- create nxspe file for direct instrument with undefined rotation angle
%     using signal, error and energy arrays provided by user and detector
%     information provided in par file or appropriate detector
%     structure. All arrays have to be consistent with each other. (see below)
%
%>>gen_nxspe(S,ERR,en,par_file,nxspefile_name,efix,emode,psi);
%  -- create fully defined nxspe file including rotation angle with parameters
%     as above.
%
%>>rd = gen_nxspe(S,ERR,en,par_file,nxspefile_name,efix,emode,psi,...
%       alatt, angdeg, u, v, omega, dpsi, gl, gs);
%  -- create fully defined nxspe file and return fully defined
%     cellarray of rundata classes or single rundata class for a single
%     nxspefile_name file.
%
%>>rd = gen_nxspe(S,ERR,en,par_file,'',efix,emode,psi,...
%       alatt, angdeg, u, v, omega, dpsi, gl, gs);
%  --  build and return cellarray of fully defined crystal rundata classes
%      for further usage but do not save information into a nxspe file.
%      Saving can be performed later using rd.saveNXSPE('filename') method.
%      (see rundata constructor or rundata.gen_runfiles method for similar
%      functionality but different implementation emphasis)
%
%      When nxspe data are saved, number of nxspe files is defined by
%      number of elements in nxspefile_name cellarray and all other inputs
%      dimensions must be consistent with this number.
%      When nxspefile_name
%      is empty, number of generated rundata instances is determined by
%      third dimension of S array size(S) == [nen,npix,n_rundata_files] if
%      S is array or number or elements in cellarray if S is cellarray
%
% Where:
% S    [nen,npix,n_files] array of signals or cellarry containing
%      n_files pointers to [nen,npix]-sized signal arrys
% ERR  sized as S array or cellarray of errors
% en   [nen+1,n_files] array or n_files cellarry of arrays of energy bins
%
% par_file  -- either ascii string defining full path to par or phx file
%         (See http://docs.mantidproject.org/nightly/algorithms/SavePAR.html
%          or http://docs.mantidproject.org/nightly/algorithms/SavePHX.html
%          for these formats description)
%     or   path to nxspe file containing detectors information.
%     or   6 column array (size == [6,n_det]) with detector information
%          convertible to Horace Detpar structure.
%     or   Horace Detpar structure with detectors information.
%
% nxspe_file -- the full name and path to the file to save resulting nxspe
%               data
%      or  empty string
%      or  cellarry of full file names to save nxspe.
%         Number of files to generate is usually defined by the size of this
%         cellarray unless this parameter is empty. When is empty, the
%         number is defined by the size of cellarray containing energy bin
%         boundaries.
%
% efix  -- incident energy or n_files array or cellarray of energies
% emode -- instrument mode (1 -- direct, 2 indirect, 0 -- elastic)
% psi   -- array or cellarray of rotation angles
%
% alatt, angdeg, u, v, omega, dpsi, gl, gs -- optional parameters, defining
%         full rundata class, necessary to convert rundata into sqw object.
%
%         This information is not stored into nxspe file. See rudata gen_runfiles
%         or gen_sqw for detailed description of these parameters
%
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
%

%
% briefly check main inputs consistency (detailed consistency will be
% verified during gen_runfiles operation.
[ok,mess,S,ERR,en,nxspe_file,n_files, inputs_are_cellarrays,save_nxspe,params] = ...
    check_and_preprocess_inputs(S,ERR,en,nxspe_file,efix,varargin{:});
if ~ok
    error('GEN_NXSPE:invalid_arguments',mess);
end
if nargout > 0 % return runfiles
    return_runfiles = true;
else
    return_runfiles = false;
end
%
if return_runfiles
    if isempty(which('horace_init'))
        gen_rudatah = false;
    else % generate extended Horace rundatah files
        gen_rudatah = true;
    end
else
    gen_rudatah = false;
end

if gen_rudatah %HACK -- assumes the knowledge about the derived class BAD!
    % But do we really care? proper oop assumes overloading gen_nxpse for
    % Horace but this solution looks much better to use.
    runfiles = rundatah.gen_runfiles(cell(1,n_files),par_file,params{:},'-allow_missing');
else
    runfiles = rundata.gen_runfiles(cell(1,n_files),par_file,params{:},'-allow_missing');
end

if inputs_are_cellarrays
    for i=1:n_files
        runfiles{i}.S  = S{i};
        runfiles{i}.ERR  = ERR{i};
        runfiles{i}.en  = en{i};
        check_correctness(runfiles{i}.S, runfiles{i}.ERR,runfiles{i}.en,i);
    end
else
    for i=1:n_files
        runfiles{i}.S   = S(:,:,i);
        runfiles{i}.ERR = ERR(:,:,i);
        runfiles{i}.en  = en(:,i);
        check_correctness(runfiles{i}.S, runfiles{i}.ERR,runfiles{i}.en,i);
    end
end
%
if save_nxspe
    for i=1:n_files
        runfiles{i}.saveNXSPE(nxspe_file{i});
    end
end
%
if nargout == 0
    return;
elseif nargout == 1
    if n_files == 1
        varargout{1} = runfiles{1};
    else
        varargout{1} = runfiles;
    end
else
    if nargout ~= n_files
        error('GEN_NXSPE:invalid_outputs',...
            ' number of output arguments should be either one or equal to number of nxspe files to save')
    else
        varargout = runfiles(:);
    end
end




function [ok,mess,S,ERR,en,nxspe_file,n_files, inputs_are_cellarrays,save_nxspe,params] = ...
    check_and_preprocess_inputs(S,ERR,en,nxspe_file,efix,varargin)
% check the consistency of all input arguments
%
ok = true;
mess = '';
%
if numel(size(S)) ==2 && ~iscell(S)
    S = {S};
end
if numel(size(ERR)) ==2  && ~iscell(ERR)
    ERR = {ERR};
end
if numel(size(en)) ==2 && any(size(en)==1)  && ~iscell(en)
    en = {en};
end


if iscell(en)
    inputs_are_cellarrays = true;
else
    inputs_are_cellarrays = false;
end

if isempty(nxspe_file)
    save_nxspe = false;
    if inputs_are_cellarrays
        n_files = numel(S);
    else
        [~,~,n_files] = size(S);
    end
else
    save_nxspe = true;
    if iscellstr(nxspe_file)
        n_files = numel(nxspe_file);
    else
        n_files = 1;
        nxspe_file = {nxspe_file};
    end
end

if inputs_are_cellarrays
    if ~(numel(S) == n_files && numel(ERR) == n_files)
        ok = false;
        mess = 'number of elements in S and ERR cellarrays has to be equal';
        return;
    elseif numel(en) ~= n_files
        if numel(en) == 1
            cen = cell(1,n_files);
            en = cellfun(@(x)(en{1}),cen,'UniformOutput',false);
        else
            ok = false;
            mess = 'number of elements in cellarray of energies has to be 1 or equal to number of elements in cellarrsys of S and ERR';
            return;
        end
    end
else
    if ~(size(S,3) == n_files && size(ERR,3) == n_files)
        ok = false;
        mess = 'last dimension of S and ERR array has to be equal to number of files to save';
        return;
    elseif size(en,2) ~= n_files
        if any(size(en))==1
            cen = cell(1,n_files);
            en = cellfun(@(x)(en),cen,'UniformOutput',false);
        else
            mess = 'second dimension of the array of energies has to be 1 or equal to number nxspe files or rundata classes to build';
        end
    end
end

% Convert remaining input parameters into the form, acceptable by
% gen_runfiles function
if nargin < 5
    ok = false;
    mess = 'gen_nxspe needs at least 6 input arguments.';
    return;
elseif nargin == 5
    % input parameters for gen_runfiles
    params={efix,1,[1,1,1],[90,90,90],[1,0,0],[0,1,0],nan};
elseif nargin == 6
    params={efix,1,[1,1,1],[90,90,90],[1,0,0],[0,1,0],varargin{1}};
elseif nargin == 7
    params={efix,varargin{2},[1,1,1],[90,90,90],[1,0,0],[0,1,0],varargin{1}};
elseif nargin == 8
    params={efix,varargin{2},varargin{3},[90,90,90],[1,0,0],[0,1,0],varargin{1}};
elseif nargin == 9
    params={efix,varargin{2:4},[1,0,0],[0,1,0],varargin{1}};
elseif nargin == 10
    params={efix,varargin{2:5},[0,1,0],varargin{1}};
elseif nargin == 11
    params={efix,varargin{2:6},varargin{1}};
elseif nargin > 11
    params={efix,varargin{2:6},varargin{1},varargin{7:end}};
end

function  check_correctness(S, ERR,en,i)
if is_string(S) || is_string(ERR) || is_string(en)
    qd = {S,ERR,en};
    wrong_fields = cellfun(@(x)(is_string(x)),qd);
    errs = qd(wrong_fields);
    error('GEN_NSPE:invalid_arguments','rundata instance N %d; Error: %s',i,errs{1})
end


