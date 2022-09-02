function psidisp(filename, varargin)
% Parallel state independent display (Easily memorable palindrome from disp)
% Quick dump to logging file on system tagged with parent process ID
%
% Usage:
%    psidisp('~/dump/debug', 'hello', a)
%
%    psidisp('c:\dump\debug', 'hello', a)
%
% Produces, for example:
% ~/dump/debug0  % Root process
% ~/dump/debug1  % Worker 1
% etc.


    mpi = MPI_State.instance();

    if isempty(mpi)
        fid = fopen(filename, 'a');
    else
        [fp, bn, ext] = fileparts(filename);
        fid = fopen(fullfile(fp, [bn, num2str(mpi.labIndex), ext]), 'a');
    end

     for i=1:numel(varargin)
         fprintf(fid, "%s\n", evalc('varargin{i}'));
     end
     fclose(fid);

end
