# Disabled tests

- test_change_crystal_1a.m
	- test_u_alighnment_tf_way (no ticket)
	- test_u_alighnment (no ticket)

- test_gen_sqw_powders.m
	- test_combine_cyl_tot (no ticket)

- test_combine_pow.m
	- test_combine_pow_tot (no ticket)

- test_multifit_horace_1.m
	- test_fit_single_or_array2 https://github.com/pace-neutrons/Horace/issues/111

- test_symmetrisation
	- test_symm_equivalent_zones (Optimize Symmetrization #24 : https://github.com/pace-neutrons/Horace/issues/24 -- but is the part of the refactoring

- test_tobyfit/
	- test_tobyfit_1 https://github.com/pace-neutrons/Horace/issues/186
	- test_tobyfit_refine_crystal_1.m (no ticket)

- test_proj_captions.m  : part of https://github.com/pace-neutrons/Horace/issues/49 -- generic projection refactoring
	- test_spher_caption (no ticket)
	- test_spher_caption2D (no ticket)
 
- test_sqw_gen_workflow:
   - test_gen_sqw_accumulate_sqw_parpool: Disabled on Jenkins:
      -- :test_accumulate_sqw1456 ! Random failures on Jenkins Windows
      -- :test_accumulate_sqw14   !
      -- :test_gen_sqw            ! Random failures on Windows when write_nsqw2_sqw in parallel. Can not start Herbert cluster
                                  ! may be other reason different run

    - test_gen_sqw_accumulate_sqw_herbert: Disabled on Jenkins:
       --:test_accumulate_sqw1456 ! combine_job -- random failures, can not read mess_data_FromN2_ToN1 (2 workers) (unix too)

