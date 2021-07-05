# Disabled tests
- test_transformation:
    - test_calc_projections.m % -- some unfinished work?
    - test_proj_captions.m  : part of https://github.com/pace-neutrons/Horace/issues/49 --    generic projection refactoring
    - test_spher_caption (no ticket)
    - test_spher_caption2D (no ticket)
- test_proj_captions.m  : part of https://github.com/pace-neutrons/Horace/issues/49 -- generic projection refactoring
    - test_spher_caption (no ticket)
    - test_spher_caption2D (no ticket)
    

- test_change_crystal_1a.m
    - test_u_alighnment_tf_way (no ticket) -- Why disabled?
    - test_u_alighnment (no ticket)

- test_multifit_horace_1.m
    - test_fit_single_or_array2 https://github.com/pace-neutrons/Horace/issues/111
    - test_fit_array_of_datasets (no ticket)
    - test_fit_test_fit_array_of_datasets_2 (no ticket)
    - test_fit_array_of_datasets_3 (no ticket)

- test_symmetrisation
    - test_symm_equivalent_zones (Optimize Symmetrization #24 : https://github.com/pace-neutrons/Horace/issues/24 -- but is the part of the refactoring
        - test_worker
        - test_do_job


- Disabled due to intermittent parallel failures on Jenkins Windows
  -test_gen_sqw_workflow:
    -test_gen_sqw_accumulate_sqw_herbert
       - test_gen_sqw   
       - test_accumulate_and_combine1to4
       - test_accumulate_sqw1456
       - test_accumulate_sqw11456
    - test_gen_sqw_accumulate_sqw_parpool
       - test_gen_sqw
       - test_accumulate_sqw14
       - test_accumulate_and_combine1to4
       - test_accumulate_sqw1456
       - test_accumulate_sqw11456
 test_gen_sqw_workflow:
    -test_gen_sqw_accumulate_sqw_slurm  Disabled everywhere except a system where Slurm cluster is available


 -test_gen_sqw_workflow:
- test_gen_sqw_accumulate_sqw_herbert
    - write_nxsqw_to_sqw -- tmp files combine procedure using Herbert(poor man MPI) framework is replaced by mex_code combining
                            write_nxsqw_to_sqw using Herbert MPI passes but slow and nobody will use it in real life anyway, so it
                            is not tested (disabled). Testing may be enabled for debugging purposes. Set combine_algorithm variable in
                            test_gen_sqw_accumulate_sqw_herbert test constructor to appropriate value to enable this test

- test_rebin.m
    - test_rebin_d1d (no ticket): skipTest('Needs fit_sqw to be implemented.')

- test_sqw_class/test_binary_ops.m -- DnD tests disabled pending code implementation
    - test_adding_sqw_and_dnd_objects_1st_operand_is_sqw_returns_sqw
    - test_adding_sqw_and_dnd_objects_2nd_operand_is_sqw_returns_sqw
    - test_dnd_minus_equivalent_sqw_returns_sqw_with_zero_image_data
    - test_sqw_minus_equivalent_dnd_returns_sqw_with_zero_image_data
    - test_subtracting_dnd_from_sqw_returns_sqw


- test_combine_sqw.m  (https://github.com/pace-neutrons/Horace/issues/464)
    - _test_combine1D

- test_calc_projections
  - test_transf1
