# Disabled tests

- test_change_crystal_1a.m
	- test_u_alighnment_tf_way (no ticket)
	- test_u_alighnment (no ticket)

- test_gen_sqw_powders.m
	- test_combine_cyl_tot (no ticket)

- test_combine_pow.m
	- test_combine_pow_tot (no ticket)

- test_gen_sqw_cylinder.m
	- test_gen_sqw_cyl [single assertion] https://github.com/pace-neutrons/Horace/issues/111

- test_gen_sqw_powder.m
	- test_powder_cuts https://github.com/pace-neutrons/Horace/issues/111

- test_multifit_horace_1.m
	- test_fit_single_or_array2 https://github.com/pace-neutrons/Horace/issues/111

- test_symmetrisation
	- test_symm_equivalent_zones (Optimize Symmetrization #24 : https://github.com/pace-neutrons/Horace/issues/24 -- but is the part of the refactoring

- test_tobyfit/
	- test_tobyfit_refine_crystal.m (line 256) https://github.com/pace-neutrons/Horace/issues/111

- test_faccess_sqw_v3.m
	- test_serialize_deserialise  https://github.com/pace-neutrons/Horace/issues/126

- test_sqw ->                    https://github.com/pace-neutrons/Horace/issues/126
    disabled folder:     
    - test_gen_sqw_accumulate_sqw_herbert.m 
    - test_gen_sqw_accumulate_sqw_parpool.m 
    - test_nsqw2sqw_internal_methods.m 

- test_proj_captions.m  : part of https://github.com/pace-neutrons/Horace/issues/49 -- generic projection refactoring
	- test_spher_caption (no ticket)
	- test_spher_caption2D (no ticket)

- combine_sqw.test.cpp
	- SQW_Reader_Propagate_Pix
	- SQW_Reader_Read_All
