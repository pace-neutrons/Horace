function mpi_exec = check_and_set_external_mpiexec_(to_enable)
% take logical or numerical input, treat it as true or false, and if it is
% true, try to search for external mpiexec and set up path to it.
% if input reduced to false, return empty string
%

to_enable = logical(to_enable);
if ~to_enable
    mpi_exec = '';
    return;
end

if ispc()
    [rs, rv] = system('where mpiexec');
    mpis = splitlines(strip(rv));
    % Ignore Matlab-bundled mpiexec (firewall issues)
    mpis(cellfun(@(x) contains(x, matlabroot), mpis)) = [];
    if rs == 0 && ~isempty(mpis)
        % If multiple mpiexec on path, prefer user installed MS MPI
        mpi_id = [1 find(cellfun(@(x) contains(x,'Microsoft'), mpis), 1)];
        mpi_exec = mpis{max(mpi_id)};
    else
        % No mpiexec on path, use pre-packaged version
        mpi_exec = '';
    end
else
    % use system-defined mpiexec
    [~, mpi_exec] = system('which mpiexec');
    % strip non-printing characters, spaces and eol/cr-s from the
    % end of mpiexec string.
    mpi_exec = regexprep(mpi_exec,'[\x00-\x20\x7F-\xFF]$','');
end


