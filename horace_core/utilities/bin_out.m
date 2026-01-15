classdef bin_out < uint32
    % enumeration class describe possible outputs of the bin_pixels methods
    % of AxesBlockBase and aProjectionBase and their children in higher
    % operational modes
   enumeration
      npix         (1)
      s            (2)
      e            (3)
      pix_ok       (4)
      unique_runid (5)
      pix_idx      (6)
      selected     (7)
      sigerr_sel   (4)
      N_outs       (8)
   end
end