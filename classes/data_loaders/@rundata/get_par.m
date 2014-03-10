function [par,this]=get_par(this,format)
% Returns detector parameter data from properly initiated data loader
%
%   >> par = get_par(rundata_instance,['-nohor'])
%   >> [par,rundata_instance] = get_par(rundata_instance,['-array'])
%
% Input:
% ------

%   rundata_instance    Properly initiated instance of the rundata class
%  '-array','-nohorace'   return results as 6xndet array of coordinates
%
% Output:
% -------
%   par                 Detector parameters
%


if isempty(this.det_par)
    if isempty(this.loader__)
        error('RUNDATA:invalid_argument','get_par function needs initiated loader');
    end
    if ~exist('format','var')
        format={};
    end
    [par,this.loader__]= this.loader.load_par(format{:});
end
