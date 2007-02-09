function w = d0d (din)
% D0D   Create a class object from the structure of a 0D dataset.
%
% Syntax:
%   >> w = d0d (din)    % din is the structure; w the corresponding output class
%                       % If din is already a 0D dataset, then w = din
%
% Input:
% ------
%   din     Input structure with necessary fields to create a 0D dataset.
%          Type >> help dnd_checkfields for a full description of the fields
%
% Output:
% -------
%   w       A 0D dataset class with precisely the same fields

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

ndim_req = 0;
class_type = 'd0d';
superiorto('spectrum');

if nargin==0    % make default dataset of requisite dimension
    w = class(dnd_checkfields(ndim_req),class_type);
    return
else
    if strcmp(class(din),class_type)
        w = din;
    elseif isstruct(din)
        [ndim, mess] = dnd_checkfields(din);
        if ~isempty(ndim)
            if ndim==ndim_req
                w = class (din, class_type);
            else
                error (['ERROR: Fields correspond to ',num2str(ndim),'-dimensional dataset'])
            end
        else
            error (mess)
        end
    else
        error ('Invalid argument')
    end
end
