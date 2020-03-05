# Disabled tests

## Herbert
- test_herbert_on.m
    - test_herWrongEmpty (no ticket)

- job_dispatcher_common_tests.m
	- test_job_fail_restart https://github.com/pace-neutrons/Herbert/issues/92
	- test_job_with_3workers https://github.com/pace-neutrons/Herbert/issues/92

- test_ParpoolMPI_Framework.m
	- test_labprobe_nonmpi (no ticket)


## Horace
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
	- test_symm_equivalent_zones (no ticket)

- test_tobyfit/
	- test_tobyfit_refine_crystal.m (line 256) https://github.com/pace-neutrons/Horace/issues/111

- test_faccess_sqw_v3.m
	- test_serialize_deserialise (no ticket)

- test_proj_captions.m
	- test_spher_caption (no ticket)
	- test_spher_caption2D (no ticket)
