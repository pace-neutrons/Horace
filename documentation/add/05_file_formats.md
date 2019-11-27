# Horace File Format

#### V3 Implementation

The Horace data file contains serialized MATLAB objects. All read and write access to files is provided though a common `sqw_formats_factory` class. The supported formats are a complex tree of MATLAB classes.

![File IO class hierarchy](..\..\sqw\file_io\CollabDiagram.png)



In contrast to the DND file, the SQW file contains additional header information and a block of pixel data. The pixel data is stored as a 9 by N array in a binary blob. Read/write is done as from a calculated pixel offset.

| Data                   | Description                                   |
| ---------------------- | --------------------------------------------- |
| `u1`, `u2`, `u3`, `u4` | Coordinates of pixel in project axis          |
| `irun`                 | Run index in header block `[1,nHeaderBlocks]` |
| `idet`                 | Detector group number                         |
| `ien`                  | Energy bin number                             |
| `signal`               | Signal                                        |
| `error`                | Variance                                      |

#### V4 redesign

Update the files to use HDF5 / Nexus through the same factor interface.

Use NeXus data format

- require assessment of whether the net performance of using a NeXus format can replicated

Note: the HDF5 libraries supported by MATLAB are limited to specific versions.