function this= build_test_detectors(this,num_detectors)
% build test detectors

phi_min = this.phi_min;
phi_max = this.phi_max;
dPhi      = (phi_max-phi_min)/(num_detectors-1);

this.group = 1:num_detectors;
this.x2     = ones(1,num_detectors);
this.phi    = phi_min:dPhi:phi_max;
this.azim = zeros(1,num_detectors);
this.width = ones(1,num_detectors);
this.height= ones(1,num_detectors,1);


end

