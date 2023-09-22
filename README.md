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
'stream' and 'log' directories are required. Please change directories what you want.
Default directory are 'file_stream' and 'log'

  stream_dir="file_stream"
  log="log"

### Debug message
defualt value is 'DEBUG=0' in "2_submit_condor_indexing.sh"

  DEBUG=1


### submit condor job
You should submit condor job at the submit node, such as pal-ui-el7 or pal-ui02-el7
./2_submit_condor_indexing.sh -g 'geom_files dir or file' -i xgandalf -j 72 -f lsf 'file dir or file' -o 'stream file' -p 'pdb file' -e "--int-radius=3,4,5 --threshold=600 --min-srn=4 --min-gradient=100000"

ex1) multiful geom and multiful lst
./2_multiful_geom_condor_indexing.sh -g geom_files -i xgandalf -j 72 -f file_list -o SASE_1.stream -p 1vds_sase_temp3.pdb -e "--int-radius=3,4,5 --threshold=600 --min-srn=4 --min-gradient=100000"

ex2) multiful geom and single lst
./2_multiful_geom_condor_indexing.sh -g geom_files -i xgandalf -j 72 -f file_list/r009100.lst -o SASE_1.stream -p 1vds_sase_temp3.pdb -e "--int-radius=3,4,5 --threshold=600 --min-srn=4 --min-gradient=100000"

ex3) sigle geom and multiful lst
./2_multiful_geom_condor_indexing.sh -g geom_files/geom_file1.geom -i xgandalf -j 72 -f file_list -o SASE_1.stream -p 1vds_sase_temp3.pdb -e "--int-radius=3,4,5 --threshold=600 --min-srn=4 --min-gradient=100000"

ex4) sigle geom and single lst
./2_multiful_geom_condor_indexing.sh -g geom_files/geom_file1.geom -i xgandalf -j 72 -f file_list/r009100.lst -o SASE_1.stream -p 1vds_sase_temp3.pdb -e "--int-radius=3,4,5 --threshold=600 --min-srn=4 --min-gradient=100000"

