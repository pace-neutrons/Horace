function   self = check_and_set_ion_name_(self,newIonName)
% verify if the name of the input ion is among the names of the ions
% currently accepted by the class and set this name as the input ion name
% if the name is acceptable.
%
% Also initiates the function handles to use for calculating 
% the magnetic form factor.
%
if ismember(newIonName,self.Ions_)
    self.currentIon_ = newIonName;
    [self.J0_ff_,self.J2_ff_,self.J4_ff_,self.J6_ff_]=self.getInterpolant(self.currentIon_);
else
    error('MagneticIons:InvalidArgument',' Ion %s is not currently supported',newIonName)
end
%
