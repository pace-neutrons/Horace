function ucoords=calc_ucoords_multirun (kfix, emode, k, en, detdcn, spec_to_pix, ir, id, ie)
% Calculate the components of Q in reference frame fixed w.r.t. spectrometer
%
%   >> ucoords = calc_ucoords_multirun (kfix, emode, k, en, detdcn, spec_to_pix, ir, id, ie)
%
% Input:
% ------
%   kfix        Fixed wavevectors for each run (Ang^-1) (row vector)
%                   Size=[1,nrun], where nrun >= maximum run index 
%   emode       Direct geometry=1, indirect geometry=2, elastic=0
%   k           Array of wavevectors at bin centres (Ang^-1)
%               (Size = [ne_max,nrun] where ne_max >= maximum number of energy bins)
%   en          Array of energy transfer at bin centres (meV)
%                   Size = [ne_max,nrun] where
%                       ne_max >= maximum number of energy bins)
%                       nrun >= maximum run index 
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%                   Size = [ne_max,nrun] where
%                       ne_max >= maximum number of energy bins)
%                       nrun >= maximum run index 
%   spec_to_pix Array of matricies to convert from spectrometer coordinates
%               (x-axis along ki, z-axis vertically upwards) to pixel coordinates.
%               Need to account for the possibility that the crystal has been reoriented,
%               in which case the pixels are no longer in crystal Cartesian coordinates.
%                - If a single matrix size=[3,3] it is assumed this apples for all runs
%                - Otherwise size=[3,3,nrun], where nrun >= maximum run index 
%   ir          Index of runs for each pixel (row vector)
%   id          Index of detectors into detdcn for each pixel (row vector)
%   ie          Index of energy bins for each pixel (row vector)
%
% Output:
% -------
%   ucoords     Coordinate of pixels (size=[4,numel(id)])


% Original author: T.G.Perring
%
% $Revision: 882 $ ($Date: 2014-07-20 10:12:36 +0100 (Sun, 20 Jul 2014) $)

    
% Get components of Q in spectrometer frame (x || ki, z vertical)
ne_max=size(k,1);
npix=numel(ir);
k_row=reshape(k,1,numel(k));
en_row=reshape(en,1,numel(en));
ind_e = ne_max*(ir-1) + ie;

if emode==1
    qspec = repmat(kfix(ir),[3,1]) - repmat(k_row(ind_e),[3,1]).*detdcn(:,id);
    if size(spec_to_pix,3)==1
        ucoords = [spec_to_pix*qspec; en_row(ind_e)];
    else
        ucoords = [squeeze(mtimesx(spec_to_pix(:,:,ir),reshape(qspec,[3,1,npix]))); en_row(ind_e)];
    end
    
elseif emode==2
    qspec = [k(ind_e);zeros(2,npix)] - repmat(kfix(ir),[3,1]).*detdcn(:,id);
    if size(spec_to_pix,3)==1
        ucoords = [spec_to_pix*qspec; en_row(ind_e)];
    else
        ucoords = [squeeze(mtimesx(spec_to_pix(:,:,ir),reshape(qspec,[3,1,npix]))); en_row(ind_e)];
    end

elseif emode==0
    Q_by_k = repmat([1;0;0],[1,npix]) - detdcn;
    qspec = repmat(k_row(ind_e),[3,1]).*Q_by_k;
    if size(spec_to_pix,3)==1
        ucoords = [spec_to_pix*qspec; zeros(1,npix)];
    else
        ucoords = [squeeze(mtimesx(spec_to_pix(:,:,ir),reshape(qspec,[3,1,npix]))); zeros(1,npix)];
    end
    
else
    error('EMODE must =1 (direct geometry), =2 (indirect geometry), or =0 (elastic)')
    
end
