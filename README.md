# indexamajig_htcondor

### Input file : lst file(s) and geom file(s)
 - sample lst files are in the 'file_list' and in the root path
 - sample geom files are in the 'geom_files' and in the root path
 - some sample files to execute indexamajig in the root path
   * mosflm.lp
   * SASE_1.stream
   * geom_file1.geom
   * geom_file2.geom
   * pdb_file1.pdb
 - sample libraries are in the 'lib'
   * libfftw3.so

### Output setting in "2_submit_condor_indexing.sh"
 - 'stream' and 'log' directories are required. Please change directories what you want.
 - Default directory are 'file_stream' and 'log'
   * stream_dir="file_stream"
   * log="log"

### Debug message
 - defualt value is 'DEBUG=0' in "2_submit_condor_indexing.sh"
   * DEBUG=1

### submit condor job
 - You should submit condor job at the submit node, such as pal-ui-el7 or pal-ui02-el7
   ./2_submit_condor_indexing.sh -g 'geom_files dir or file' -i xgandalf -j 72 -f lsf 'file dir or file' -o 'stream file' -p 'pdb file' -e "--int-radius=3,4,5 --threshold=600 --min-snr=4 --min-gradient=100000"

   * ex1) multiful geom and multiful lst:
     - ./2_submit_condor_indexing.sh -g geom_files -i xgandalf -j 72 -f file_list -o SASE_1.stream -p pdb_file1.pdb -e "--int-radius=3,4,5 --threshold=600 --min-snr=4 --min-gradient=100000"

   * ex2) multiful geom and single lst:
     - ./2_submit_condor_indexing.sh -g geom_files -i xgandalf -j 72 -f file_list/r009100.lst -o SASE_1.stream -p  pdb_file1.pdb -e "--int-radius=3,4,5 --threshold=600 --min-snr=4 --min-gradient=100000"

   * ex3) sigle geom and multiful lst
     - ./2_submit_condor_indexing.sh -g geom_files/geom_file1.geom -i xgandalf -j 72 -f file_list -o SASE_1.stream -p pdb_file1.pdb -e "--int-radius=3,4,5 --threshold=600 --min-snr=4 --min-gradient=100000"

   * ex4) sigle geom and single lst
     - ./2_submit_condor_indexing.sh -g geom_files/geom_file1.geom -i xgandalf -j 72 -f file_list/r009100.lst -o SASE_1.stream -p pdb_file1.pdb -e "--int-radius=3,4,5 --threshold=600 --min-snr=4 --min-gradient=100000"


### CrystFEL version used by the jobs
 - "3_exec_indexing.sh" does NOT hard-code a CrystFEL version any more.
   "2_submit_condor_indexing.sh" submits with "getenv = True", so the job runs
   with the environment of the shell you submitted from.

   source /pal/lib/setup_crystfel-0.12.0_hdf5-1.10.5.sh   # CrystFEL 0.12.0
   ./2_submit_condor_indexing.sh ...

 - If no CrystFEL environment is set up, "3_exec_indexing.sh" falls back to
   $CRYSTFEL_SETUP (default: /pal/lib/setup_crystfel-0.12.0_hdf5-1.10.5.sh).
 - Each job log starts with the indexamajig path and version it actually used.
   Check that first if an indexing method is not recognised, e.g. 'smallcell'
   was added in CrystFEL 0.12.0.
