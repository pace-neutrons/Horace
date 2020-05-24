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

- test_proj_captions.m  : part of https://github.com/pace-neutrons/Horace/issues/49 -- generic projection refactoring
	- test_spher_caption (no ticket)
	- test_spher_caption2D (no ticket)

- test_gen_sqw_workflow:
   - test_gen_sqw_accumulate_sqw_herbert: Disabled combine_job using file-based exchange on Jenkins:
          due to random failures write_nsqw2_sqw, can not read mess_data_FromN2_ToN1 (2 workers) (unix too)
       random hangups in accumulate_headers_job: disabled on windows jenkins
   - test_gen_sqw
   - test_accumulate_sqw11456
          
   - test_gen_sqw_accumulate_sqw_parpool:   
        Disabled combine_job using MPI exchange on Jenkins Windows:  due to random failures write_nsqw2_sqw,(time-out)
        for:
        -test_gen_sqw
        -test_accumulate_and_combine1to4
        -test_accumulate_sqw14
        -test_accumulate_sqw1456;
        -test_accumulate_sqw11456;
          