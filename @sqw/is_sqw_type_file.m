function [sqw_type, nd, mess] = is_sqw_type_file(sqw, infile)
% Determine if file contains data of an sqw-type object or dnd-type sqw object
% 
%   >> [sqw_type, nd, mess] = is_sqw_type_file(sqw, infile)
%
%   sqw is a dummy sqw object used to enforce a call to this method


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% Simply an interface to private function that we wish to keep hidden
[sqw_type, nd, mess] = get_sqw_type_from_file (infile);
