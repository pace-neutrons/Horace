function [par,this]=get_par(this,format)
% Returns detector parameter data from properly initiated data loader
%
%   >> par = get_par(rundata_instance,['-nohor'])
%   >> [par,rundata_instance] = get_par(rundata_instance,['-array'])
%
% Input:
% ------

%   this == rundata_instance    Properly initiated instance of the rundata class
%  '-array','-nohorace'         return results as 6xndet array of coordinates
%
% Output:
% -------
%   par                 Detector parameters
%
%
% one of the GET_PAR methods for retrieving detpar from data.
% note this is the @rundata method, there is also the
% method in data_loaders method

if isempty(this.det_par)
    if isempty(this.loader_)
        error('RUNDATA:invalid_argument','get_par function needs initiated loader');
    end
    if ~exist('format', 'var')
        format={};
    end
    [par,this.loader_]= this.loader.load_par(format{:});
else
    par = this.det_par;
end
