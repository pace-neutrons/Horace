function [wpdf, wcdf] = IX_dataset_1d(obj)
% Produce IX_dataset_1d objects from the probability distribution function
%
%   >> [wpdf, wcdf] = IX_dataset_1d(obj)
%
% Input:
% ------
%   obj         pdf_table object
%
% Output:
% -------
%   wpdf        Probability dixtribution function (IX_dataset_1d)
%
%   wcdf        Cumulative probability distribution function (IX_dataset_1d)


if ~isscalar(obj), error('Method only takes a scalar object'), end
if ~obj.filled
    error('The probability distribution function is not initialised')
end

wpdf = IX_dataset_1d (obj.x_, obj.f_, zeros(size(obj.f_)),...
    'Probability distribution function','Random variable','Function value');

wcdf = IX_dataset_1d (obj.x_, obj.f_, zeros(size(obj.A_)),...
    'Cumulative distribution function','Random variable','Function value');
