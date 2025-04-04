function [ei,x0,xa,x1,mod_shape_mono,horiz_div,vert_div] =...
    instpars_DGdisk(header)
% Get parameters needed for chopper spectrometer resolution function calculation
%
%   >> [ok,mess,ei,x0,xa,x1,mod_shape_mono,horiz_div,vert_div] =...
%                                               instpars_DGdisk (header)
% Input:
% ------
%   header      Header (experiment_info) object from sqw object
%
% Output: (arrays are column vectors with length equal to the number of contributing runs)
% -------
%   ok          Error status: true if OK, false otherwise
%   mess        Error message: empty if OK, filled otherwise
%   ei          Incident energies (mev)     [Column vector]
%   x0          Moderator-monochromating chopper distance (m)   [column vector]
%   xa          Shaping-monochromating chopper distance (m)     [column vector]
%   x1          Monochromating chopper-sample distance  (m)     [column vector]
%   mod_shape_mono  Array of IX_mod_shape_mono objects              [Column vector]
%   horiz_div       Array of horizontal divergence profile objects  [Column vector]
%   vert_div        Array of horizontal divergence profile objects  [Column vector]


% Get array of instruments
instruments = header.instruments;
nrun=instruments.n_runs;

% Fill output arguments
ei=zeros(nrun,1);
x0=zeros(nrun,1);
xa=zeros(nrun,1);
x1=zeros(nrun,1);

for i=1:nrun
    ei(i)=header.expdata(i).efix;
end

use_unique_objects = true;
% switch between old and new inputs to object lookup
% the old version will be removed after testing
if ~use_unique_objects

    inst=repmat({instruments{1}},[nrun,1]);
    for i=2:nrun
        inst{i}=instruments{i};
    end

    mod_shape_mono=repmat(IX_mod_shape_mono,[nrun,1]);
    horiz_div=repmat(IX_divergence_profile,[nrun,1]);
    vert_div=repmat(IX_divergence_profile,[nrun,1]);
    
    for i=1:nrun
        mod_shape_mono(i)=inst{i}.mod_shape_mono;
        horiz_div(i)=inst{i}.horiz_div;
        vert_div(i)=inst{i}.vert_div;
        
        x1(i)=abs(inst{i}.mono_chopper.distance);
        x0(i)=abs(inst{i}.moderator.distance) - x1(i);          % distance from mono chopper to moderator face
        xa(i)=abs(inst{i}.shaping_chopper.distance) - x1(i);    % distance from shaping chopper to mono chopper
        
    end
    
else % use_unique_objects
    
    mod_shape_mono = instruments.get_unique_field('mod_shape_mono').unique_objects;
    horiz_div      = instruments.get_unique_field('horiz_div').unique_objects;
    vert_div       = instruments.get_unique_field('vert_div').unique_objects;
    
    mono_chopper    = instruments.get_unique_field('mono_chopper').unique_objects;
    moderator       = instruments.get_unique_field('moderator').unique_objects;
    shaping_chopper = instruments.get_unique_field('shaping_chopper').unique_objects;

    for i=1:nrun
        x1(i)=abs(mono_chopper{i}.distance);
        x0(i)=abs(moderator{i}.distance) - x1(i);          % distance from mono chopper to moderator face
        xa(i)=abs(shaping_chopper{i}.distance) - x1(i);    % distance from shaping chopper to mono chopper
    end


end % if ~use_unique_objects

end % instpars_DGdisk
