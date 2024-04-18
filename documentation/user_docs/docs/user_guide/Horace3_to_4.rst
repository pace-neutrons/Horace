####################################
Converting from Horace 3 to Horace 4
####################################

Horace 4 has been a major rewrite and refactoring effort on the code
from Horace 3. This document outlines the breaking changes between
versions as well as describing a fast way to convert existing scripts
from Horace 3 to Horace 4.

Projections
-----------

In Horace 4, projections have been expanded and reworked to be
generalised for other shapes of cuts (e.g. spherical, cylindrical). As
a result, the old-style projections, e.g.:

.. code-block:: matlab

   proj1 = struct('u', [1 0 0], 'v', [0 1 0]);
   proj2 = projaxes([1 0 0], [0 1 0]);
   proj3 = ortho_proj([1 0 0], [0 1 0]);

   proj4.u = [1 0 0];
   proj4.v = [0 1 0];

have been deprecated and a warning will be issued if they are
used. For old-style projections the conversion is as simple as
replacing the ``struct``, ``projaxes`` or ``ortho_proj`` with ``line_proj``
(c.f. :ref:`projections
<manual/Cutting_data_of_interest_from_SQW_files_and_objects:Projection in more details>`).

.. code-block:: matlab

   proj1 = line_proj([1 0 0], [0 1 0]);
   proj2 = line_proj([1 0 0], [0 1 0]);
   proj3 = line_proj([1 0 0], [0 1 0]);
   proj4 = line_proj([1 0 0], [0 1 0]);

Symmetrisation
--------------

The function ``sqw.symmetrise_sqw`` has been significantly rewritten
to generalise it and allow rotational symmetry reduction. As part of
this rewrite, it now takes ``Symop`` s as arguments rather than a pair
of vectors.

To update e.g.:

.. code-block:: matlab

   symmetrised = win.symmetrise_sqw([1 0 0], [0 1 0], [1 1 1]);

it simply becomes:

.. code-block:: matlab

   symmetrised = win.symmetrise_sqw(SymopReflection([1 0 0], [0 1 0], [1 1 1]);

.. note::

   The ``SymopReflection`` can also be constructed earlier and reused:

   .. code-block:: matlab

      sym = SymopReflection([1 0 0], [0 1 0], [1 1 1]);
      symmetrised = win.symmetrise_sqw(sym);

Passing a pair of vectors will still be accepted and be internally
transformed into the correct ``Symop``, however, it is still best to
switch.

Crystal Alignment
-----------------

Crystal alignment in Horace 4 has been changed such that alignment is
a two-stage process.

When you call ``change_crystal`` to an ``sqw``, it will not transform
the pixels immediately, but most operations will apply the transform
whenever the pixels are used allowing you to e.g. plot the realigned
state (c.f. :ref:`manual/Correcting_for_sample_misalignment:Correcting
for sample misalignment`). Though this can be costly to do repeatedly,
it is a cheaper than rewriting a file every time and it is for this
reason the change has been made.

In order to finalise a transformation once you are satisfied with the
realignment, simply call ``sqw.apply_alignment``.

.. code-block:: matlab

   w = sqw('my_fav.sqw');

   alignment_info = [... realignment process]

   % Change is only temporary
   w = change_crystal(win, alignment_info);

   % But we can check our data
   plot(w);

   % And when we're satisfied
   w = w.apply_alignment();


Multifit
--------

As of Horace 4, the deprecated legacy multifit syntax (i.e. all in one
line):

.. code-block:: matlab

   [wfit, fitdata] = multifit_sqw(my_new_cut, @sr122_xsec, pars, pfree, pbind, 'list', 1);

has been fully removed. This means that trying to use this syntax will
result in an error. The modern syntax uses an object-based form which
looks like:

.. code-block:: matlab

   kk = multifit(my_new_cut);
   kk = kk.set_fun(@sr122_xsec);
   kk = kk.set_pin(pars);
   kk = kk.set_free(pfree);
   kk = kk.set_bind(pbind);
   kk = kk.set_options('listing', 1);
   [wfit, fitdata] = kk.fit();

While this would be a lot of effort to translate manually, thankfully,
Horace 4.0 comes with a function (``mf_leg_to_new``) to translate the
legacy tyle to the new format:

.. code-block:: matlab

   mf_leg_to_new("[wfit, fitdata] = multifit_sqw(my_new_cut, @sr122_xsec, pars, pfree, pbind, 'list', 1)")

   ans =

      kk = multifit(my_new_cut);
      kk = kk.set_fun(@sr122_xsec);
      kk = kk.set_pin(pars);
      kk = kk.set_free(pfree);
      kk = kk.set_bind(pbind);
      kk = kk.set_options('listing', 1);
      [wfit, fitdata] = kk.fit();

ready to be put into your code.

.. warning::

   The reason for not translating files directly is that this function
   is provided in a *caveat emptor* state and the parameters should
   be double checked to ensure they are what you expect. Any erroneous
   parameters should be reported to the developers at `Horace Help
   <mailto:HoraceHelp@stfc.ac.uk>`__

Deprecated Functions
--------------------

.. note::

   All deprecation warning IDs in horace are of the form
   ``HORACE:function:deprecated``. A complete list is below [1]_

The table below lists functions have been deprecated and their Horace 4 equivalent.

+--------------------------+--------------------+
|Old                       |New                 |
+--------------------------+--------------------+
|``projaxes``              |``line_proj``       |
+--------------------------+--------------------+
|``refine_crystal_dnd``    |``refine_crystal``  |
+--------------------------+--------------------+
|``refine_crystal_horace`` |``refine_crystal``  |
+--------------------------+--------------------+
|``refine_crystal_sqw``    |``refine_crystal``  |
+--------------------------+--------------------+
|``fake_sqw``              |``dummy_sqw``       |
+--------------------------+--------------------+
|``fake_data``             |``dummy_sqw``       |
+--------------------------+--------------------+
|``cut_sqw_sym``           |``cut``             |
+--------------------------+--------------------+
|``cut_sym``               |``cut``             |
+--------------------------+--------------------+
|``signal``                |``coordinates_calc``|
+--------------------------+--------------------+
|``symop``                 |``Symop.create``    |
+--------------------------+--------------------+
|``axes_block``            |``line_axes``       |
+--------------------------+--------------------+
|``ortho_axes``            |``line_axes``       |
+--------------------------+--------------------+
|``projaxes``              |``line_proj``       |
+--------------------------+--------------------+
|``ortho_proj``            |``line_proj``       |
+--------------------------+--------------------+
|``herbert_config``        |``hor_config``      |
+--------------------------+--------------------+

.. [1] Deprecated warnings are as follows:

  - ``HORACE:tobyfit:deprecated``
  - ``HORACE:refine_crystal:deprecated``
  - ``HORACE:fake_sqw:deprecated``
  - ``HORACE:cut_sym:deprecated``
  - ``HORACE:cut_sqw_sym:deprecated``
  - ``HORACE:signal:deprecated``
  - ``HORACE:symop:deprecated``
  - ``HORACE:axes_block:deprecated``
  - ``HORACE:ortho_axes:deprecated``
  - ``HORACE:ortho_proj:deprecated``
  - ``HORACE:projaxes:deprecated``
  - ``HORACE:spher_axes:deprecated``
  - ``HORACE:spher_proj:deprecated``

  To disable all deprecation warnings use the following:

  .. code-block:: matlab

     warns = ["HORACE:tobyfit:deprecated"
              "HORACE:refine_crystal:deprecated"
              "HORACE:fake_sqw:deprecated"
              "HORACE:cut_sym:deprecated"
              "HORACE:cut_sqw_sym:deprecated"
              "HORACE:signal:deprecated"
              "HORACE:symop:deprecated"
              "HORACE:axes_block:deprecated"
              "HORACE:ortho_axes:deprecated"
              "HORACE:ortho_proj:deprecated"
              "HORACE:projaxes:deprecated"
              "HORACE:spher_axes:deprecated"
              "HORACE:spher_proj:deprecated"];
     for warn = warns
        warning('off', warn);
     end
