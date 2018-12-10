# scripts for running histology processing on graham

Requires: 
 - neuroglia-helpers
 - matlab access on graham

Getting started:
 - edit `000_setup` with project paths
 - start running scripts!

Note: 
 - not all scripts submit jobs, e.g. `00_importData` runs interactively, so should use an interactive job (`regularInteractive`) when running that
 - genFeatureMaps uses matlab parfor to parallelize across strips of a tif file, and also submits tif files as a job array
 - fine-grained parallelism is controllable using the job-template (e.g. ShortSkinny = 1 core, Short = 8 cores)
 - since jobs are not memory intensive, if processing a large amount of tifs, best to use ShortSkinny.. 

