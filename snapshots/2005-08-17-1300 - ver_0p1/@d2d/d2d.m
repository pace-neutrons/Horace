function w = d2d (din)
% D2D   Create a class object from the structure of a 2D dataset.
%
% Syntax:
%   >> w = d2d (din)    % din is the structure; w the corresponding output class
%                       % If din is already a 2D dataset, then w = din
%
% Input:
% ------
%   din     Input structure with necessary fields to create a 2D dataset.
%          Type >> help dnd_checkfields for a full description of the fields
%
% Output:
% -------
%   w       A 2D dataset class with precisely the same fields

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

ndim_req = 2;
superiorto('spectrum');

if strcmp(class(din),'d2d')
    w = din;
else
    [ndim, mess] = dnd_checkfields(din);
    if ~isempty(ndim)
        if ndim==ndim_req
            w = class (din, 'd2d');
        else
            error (['ERROR: Fields correspond to ',num2str(ndim),'-dimensional dataset'])
        end
    else
        error (mess)
    end
end
