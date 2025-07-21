function data = sqw_op_move_to_bz0_and_remove_bckgrnd(pageop_obj,bg_model,rlu,r2_ignore,fJi)
%sqw_op_move_to_bz0_and_remove_bckgrnd moves foreground signal within 
% specified cut-off radius and moves background signal into first Brilluoin zone.
%
% Inputs:
% pageop_obj -- Initialized instance of PageOp_sqw_op_bin_pixels object 
%               providing all necessary data.
% bg_model   -- class calculating background singal within 
% rlu        -- reciprocal lattice vectors for the used lattice
% r2_ignore  -- square of cut-off radius to select background (A^-2)
% fJi        -- function handle to calculate magnetic form-factor
%

% Get access to [9 x Npix] page of pixels data
data  = pageop_obj.page_data;
q_coord = data(1:3,:); % and retrieve its momentum transfer coordinates

% Filter non-magnetic results ignoring signal beyond of cut-off radious
Q2 = q_coord(1,:).*q_coord(1,:)+q_coord(2,:).*q_coord(2,:)+q_coord(3,:).*q_coord (3,:);
keep = Q2<r2_ignore;   % foreground
data = data(:,keep);
q_coord = q_coord(:,keep);
Q2      = Q2(keep);
if isempty(data)
    return;  % leave if this page does not contain foreground data
end
%
% filter strange secondary reflections located in rlu positions
filt_scale = 0.5*rlu;
q_filt = round(q_coord(1:2,:)./filt_scale(1)).*filt_scale(1); % define positions of the reflections
r_filt2 = (0.07*filt_scale(1))^2;  % define cut-off radious for secondary reflections
% identify pixels which located within cut-off radius from secondary
% reflection senters
keep2 = (q_coord(1,:)-q_filt(1,:)).^2+(q_coord(2,:)-q_filt(2,:)).^2 >= r_filt2;
data = data(:,keep2);
if isempty(data)
    return;  % leave all data in this page have been filtered
end
%
q_coord = q_coord(:,keep2);
% Calculate magnetic form factor
q2 = Q2(keep2)/(16*pi*pi);
clear Q2;
MFF = fJi{1}(q2).^2+fJi{2}(q2).^2+fJi{3}(q2).^2+fJi{4}(q2).^2;

sig_var = data([8,9],:);

% move everything into 1/4 of first square zone with basis.
% Cubic lattice scale in BCC lattice
scale = 2*rlu;

% BRAGG positions in the new lattice are located at the even rlu values
img_shift = round(q_coord./scale(:)).*scale(:); 

% move all q-coordinates into expanded Brillouin zone +-1*rlu size
q_coord   = q_coord - img_shift;

% move 7 cubes with negative coordinates of expanded Brillouin zone into the first cube.
invert = q_coord<0;
q_coord(invert) = -q_coord(invert);

% calculate  background.
q4 = data(4,:);
bg_signal = bg_model(q_coord(1,:),q_coord(2,:),q_coord(3,:),q4);
out_of_range = isnan(bg_signal);
bg_signal(out_of_range) = 0;
% 
% remove background and Correct for Magnetic form factor after 
% background has been removed.
sig_var(1,:) = (data(8,:)-bg_signal)./MFF;
% suppress negative signal and put its error to 0 to avoid its usage in 
% fitting
over_compensated = sig_var(1,:)<0;
sig_var(1,over_compensated) = 0;
sig_var(2,over_compensated) = 0;

% construct modified result
data(1:3,:) = q_coord;
data(8:9,:) = sig_var;

end