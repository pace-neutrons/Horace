function runfiles = gen_nxspe(S,ERR,en,par_file,nxspe_file,efix, varargin)
% Function to create rundata object or cell array of such objects
% from existing signal, error and detector arrays and save this object to
% nxspe file(s)
%
% Usage:
%
%>>gen_nxspe(S,ERR,en,par_file,nxspefile_name,efix);
%  -- create nxspe file for direct instrument with undefined rotation angle
%     using signal, error and energy arrays provided by user and detector
%     information provided in par file or appropriate detector
%     structure (see below) All arrays has to be consistent
%
%>>gen_nxspe(S,ERR,en,par_file,nxspefile_name,efix,emode,psi);
%  -- create fully defined nxspe file with parameters as above
%
%>>rd = gen_nxspe(S,ERR,en,par_file,nxspefile_name,efix,emode,psi,...
%       alatt, angdeg, u, v, omega, dpsi, gl, gs);
%  -- create fully defined nxspe file and return fully defined
%     rundata class for further usage
%
%>>rd = gen_nxspe(S,ERR,en,par_file,'',efix,emode,psi,...
%       alatt, angdeg, u, v, omega, dpsi, gl, gs);
%  --  build and return fully defined crystal  rundata class for further usage
%      but do not save it into a nxspe file. Saving can be perfomed later
%      using rd.saveNXSPE('filename') method.
%      (see rundata constructor or rundata.gen_runfiles method for similar
%      functionality but different)
%
% Where:
% S    [nen,npix,n_files] array of signals or cellarry containing
%      n_files pointers to [nen,npix]-sized signal arrys
% ERR  sized as S array or cellarray of errors
% en    nen+1 array size of n_files cellarry of array, pointing to of energy bins
%
% par_file  -- either ascii string defining full path to par or phx file
%         (See http://docs.mantidproject.org/nightly/algorithms/SavePAR.html
%          or http://docs.mantidproject.org/nightly/algorithms/SavePHX.html
%          for these formats description) or path to nxspe file containing detectors
%          information.
%     or   5- or 6 column array with detector information convertable to Horace
%     Detpar structure or this structure itself.
%
% nxspe_file -- the name of the file(s) to save resulting nxspe results
%               into or empty string or cellarry of file names.
%       number of files to generate is usually defined by the size of this
%       cellarray.
%
% efix  -- incident energy or n_files array or cellarray of energies
% emode -- instrument mode (1 -- direct, 2 indirect, 0 -- elastic)
% psi   -- array or cellarray of rotation angles
%
% alatt, angdeg, u, v, omega, dpsi, gl, gs -- optional parameters, defining
%           rundata and not stored into nxspe file. See rudata gen_runfiles
%           or gen_sqw for details of these parameters
%
% $Revision: 977 $ ($Date: 2015-02-21 18:58:56 +0000 (Sat, 21 Feb 2015) $)
%

% briefly check main inputs consistency (detailed constistency will be
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
    else % generage extended horace rundatah files
        gen_rudatah = true;
    end
else
    gen_rudatah = false;
end

if gen_rudatah %HACK -- assumes the knowlege about the derived class BAD!
    runfiles = rundatah.gen_runfiles('',par_file,params{:},'-allow_missing');
else
    runfiles = rundata.gen_runfiles('',par_file,params{:},'-allow_missing');
end

if inputs_are_cellarrays
    for i=1:n_files
        runfiles{i}.S  = S{i};
        runfiles{i}.ERR  = ERR{i};
        runfiles{i}.en  = en{i};
        check_correctness(runfiles{i}.S, runfiles{i}.ERR,runfiles{i}.en);
    end
else
    for i=1:n_files
        runfiles{i}.S   = S(:,:,i);
        runfiles{i}.ERR = ERR(:,:,i);
        runfiles{i}.en  = en(:,i);
        check_correctness(runfiles{i}.S, runfiles{i}.ERR,runfiles{i}.en);        
    end
end
%
if save_nxspe
    for i=1:n_files
        runfiles{i}.saveNXSPE(nxspe_file{i});
    end
end
%
if n_files == 1
    runfiles = runfiles{1};
end




function [ok,mess,S,ERR,en,nxspe_file,n_files, inputs_are_cellarrays,save_nxspe,params] = ...
    check_and_preprocess_inputs(S,ERR,en,nxspe_file,efix,varargin)
% check the consistency of all input arguments
%
ok = true;
mess = '';
%
if numel(size(S)) ==2
    S = {S};
end
if numel(size(ERR)) ==2
    ERR = {ERR};
end
if numel(size(en)) ==2 && any(size(en)==1)
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
        n_files = numel(en);
    else
        [~,n_files] = size(en);
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
    if ~(numel(en) == n_files  && numel(S) == n_files && numel(ERR) == n_files)
        ok = false;
        mess = 'number of elements in S, ERR and en cellarrays has to be equal';
        return;
    end
else
end

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

function  check_correctness(S, ERR,en)
if is_string(S) || is_string(ERR) || is_string(en)
    qd = {S,ERR,en};
    wrong_fields = cellfun(@(x)(isstring(x)),gd);
    errs = qd(wrong_fields);
    error('GEN_NSPE:invalid_arguments',errs{1})
end


