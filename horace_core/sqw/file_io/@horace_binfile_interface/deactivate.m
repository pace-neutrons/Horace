function obj = deactivate(obj)
% Close respective file keeping all internal information about
% this file in memory.
%
% To use for MPI transfers between workers when open file can
% not be transferred between workers but everything else can
if ~isempty(obj.file_closer_)
% Re #1322 refactoring is due
    obj.file_closer_.delete();
    obj.file_closer_ = [];
end
obj = obj.fclose();
