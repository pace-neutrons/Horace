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
superiorto('spectrum');

if strcmp(class(din),'d0d')
    w = din;
else
    [ndim, mess] = dnd_checkfields(din);
    if ~isempty(ndim)
        if ndim==ndim_req
            w = class (din, 'd0d');
        else
            error (['ERROR: Fields correspond to ',num2str(ndim),'-dimensional dataset'])
        end
    else
        error (mess)
    end
end
