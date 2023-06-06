#################
List of functions
#################

Listed here are all the functions and commands that can be used in Horace. Each function is listed with a **brief** description of what it does, and an example syntax for its use.

:ref:`Generating SQW files <manual/Generating_SQW_files:Generating SQW files>`

- :ref:`accumulate_sqw <manual/Generating_SQW_files:accumulate_sqw>`
- :ref:`gen_sqw <manual/Generating_SQW_files:gen_sqw>`


:ref:`Correcting for sample misalignment <manual/Correcting_for_sample_misalignment:Correcting for sample misalignment>`

- :ref:`bragg_positions <manual/Correcting_for_sample_misalignment:bragg_positions>`
- :ref:`bragg_positions_view <manual/Correcting_for_sample_misalignment:bragg_positions_view>`
- :ref:`calc_proj_matrix <manual/Correcting_for_sample_misalignment:calc_proj_matrix>`
- :ref:`crystal_pars_correct <manual/Correcting_for_sample_misalignment:crystal_pars_correct>`
- :ref:`refine_crystal <manual/Correcting_for_sample_misalignment:refine_crystal>`
- :ref:`rlu_corr_to_lattice <manual/Correcting_for_sample_misalignment:rlu_corr_to_lattice>`
- :ref:`ubmatrix <manual/Correcting_for_sample_misalignment:ubmatrix>`
- :ref:`uv_correct <manual/Correcting_for_sample_misalignment:uv_correct>`


:ref:`Data diagnostics <manual/Data_diagnostics:Data diagnostics>`

- :ref:`run_inspector <manual/run_inspector:run inspector>`


:ref:`Plotting <manual/Plotting:Plotting>`

- :ref:`1-dimensional plot commands <manual/Plotting:pd (plot data)>`
- :ref:`2-dimensional plot commands <manual/Plotting:da (draw area)>`
- :ref:`3-dimensional plot commands <manual/Plotting:sliceomatic>`
- :ref:`Adjusting figures <manual/Plotting:Colour of lines and markers>`
- :ref:`Spaghetti plot <manual/Plotting:spaghetti_plot>`


:ref:`Manipulating and extracting data from SQW files and objects <manual/Manipulating_and_extracting_data_from_SQW_files_and_objects:Manipulating and extracting data from SQW files and objects>`

- :ref:`cut_sqw <manual/Manipulating_and_extracting_data_from_SQW_files_and_objects:cut_sqw>`
- :ref:`head_sqw <manual/Manipulating_and_extracting_data_from_SQW_files_and_objects:head_horace>`
- :ref:`read <manual/Manipulating_and_extracting_data_from_SQW_files_and_objects:read_sqw>`
- :ref:`save <manual/Manipulating_and_extracting_data_from_SQW_files_and_objects:save>`
- :ref:`save xye ascii file <manual/Manipulating_and_extracting_data_from_SQW_files_and_objects:save>`
- :ref:`extract coordinates <manual/Manipulating_and_extracting_data_from_SQW_files_and_objects:hkle>`


:ref:`Symmetrising etc <manual/Symmetrising_etc:Symmetrising etc>`

- :ref:`Symmetrise <Symmetrising_etc_symmetrise_sqw>`
- :ref:`Combine <Symmetrising_etc_combine_sqw>`
- :ref:`Rebin <Symmetrising_etc_rebin_sqw>`


:ref:`Simulation <manual/Simulation:Simulation>`

- :ref:`func_eval <manual/Simulation:Simulation>`
- :ref:`sqw_eval <manual/Simulation:Simulation>`
- :ref:`disp2sqw_eval <manual/Simulation:Simulation>`
- :ref:`dispersion_plot <manual/Simulation:Simulation>`
- :ref:`disp2sqw_plot <manual/Simulation:Simulation>`

.. _LoF_Fitting:

:ref:`Fitting data <manual/Multifit:Multifit>`

- :ref:`multifit <manual/Multifit:multifit>`
- :ref:`multifit_func <manual/Multifit:multifit_func>`
- :ref:`multifit_sqw <manual/Multifit:multifit_sqw>`
- :ref:`multifit_sqw_sqw <manual/Multifit:multifit_sqw_sqw>`



:ref:`Binary operations <manual/Binary_operations:Binary operations>`

- :ref:`minus <manual/Binary_operations:List of operations and their equivalent code>`
- :ref:`plus <manual/Binary_operations:List of operations and their equivalent code>`
- :ref:`mtimes <manual/Binary_operations:List of operations and their equivalent code>`
- :ref:`mrdivide <manual/Binary_operations:List of operations and their equivalent code>`
- :ref:`mldivide <manual/Binary_operations:List of operations and their equivalent code>`
- :ref:`mpower <manual/Binary_operations:List of operations and their equivalent code>`


:ref:`Unary operations <manual/Unary_operations:Unary operations>`

- :ref:`uplus <manual/Unary_operations:unary plus>`
- :ref:`uminus <manual/Unary_operations:unary minus>`
- :ref:`Trigonometric and hyperbolic functions <manual/Unary_operations:Trigonometric and hyperbolic functions>`
- :ref:`Other mathematical functions <manual/Unary_operations:Other mathematical functions>`


:ref:`Reshaping etc <manual/Reshaping_etc:Reshaping etc>`

- :ref:`replicate <manual/Reshaping_etc:replicate>`
- :ref:`compact <manual/Reshaping_etc:compact>`
- :ref:`permute <manual/Reshaping_etc:permute>`
- :ref:`cut <manual/Reshaping_etc:cut>`
- :ref:`smooth <manual/Reshaping_etc:smooth>`
- :ref:`mask <manual/Reshaping_etc:mask>`
- :ref:`mask_points <manual/Reshaping_etc:mask_points>`
- :ref:`mask_runs <manual/Reshaping_etc:mask_runs>`
- :ref:`section <manual/Reshaping_etc:section>`


:ref:`Read or write to disk <manual/Read_or_write_to_disk:Read or write to disk>`

- :ref:`read <manual/Read_or_write_to_disk:read_horace, read_sqw, read_dnd>`
- :ref:`save <manual/Read_or_write_to_disk:save>`
- :ref:`save xye ascii file <manual/Read_or_write_to_disk:save_xye>`
- :ref:`header <manual/Read_or_write_to_disk:head_horace, head_sqw, head_dnd>`

..
   - :ref:`display <manual/Read_or_write_to_disk:display>`


:ref:`Changing object type <manual/Changing_object_type:Changing object type>`

.. Comment from Chris
   The sqw->dnd bits here have the useful information that the pixels are thrown away.
   It could be added that an average of the pixels are left in the image data.

   The dnd->sqw bit is lacking such a comment.
   As the pixel data will be constructed,
   and will presumably lack detail that will be present in a "real" sqw,
   worth at least a note saying how the construction is done

- :ref:`d0d <manual/Changing_object_type:d0d>`
- :ref:`d1d <manual/Changing_object_type:d1d>`
- :ref:`d2d <manual/Changing_object_type:d2d>`
- :ref:`d3d <manual/Changing_object_type:d3d>`
- :ref:`d4d <manual/Changing_object_type:d4d>`
- :ref:`sqw <manual/Changing_object_type:sqw>`

.. Comment from Chris
   A brief description of what IX_dataset_nd is and why it is useful would be good
   Duc: I'm not sure users need to know - maybe just remove this?

- :ref:`IX_dataset_1d <manual/Changing_object_type:IX_dataset_1d>`
- :ref:`IX_dataset_2d <manual/Changing_object_type:IX_dataset_2d>`
- :ref:`IX_dataset_3d <manual/Changing_object_type:IX_dataset_3d>`
