# Changelog

## 2026-10-27

Please download the scripts again. Older copies, including the one in
`/pal/htcondor/htcondor_sample_ori.tar`, have this line in `3_exec_indexing.sh`:

```bash
source /pal/lib/setup_crystfel-0.9.1_hdf5-1.10.5.sh
```

It overrides the CrystFEL version you set up before submitting, so those copies
run 0.9.1 even if you loaded 0.12.0 or 0.13.0. If you keep an old copy, edit or
remove that line to choose the version.

### Changed
- **Jobs use the CrystFEL version set up in the shell you submit from.**
  `2_submit_condor_indexing.sh` now submits with `getenv = True`, and
  `3_exec_indexing.sh` no longer sources a fixed version. Source the version
  you need before submitting:

  ```bash
  source /pal/lib/setup_crystfel-0.13.0_hdf5-1.12.2-threadsafe-v18.sh
  ./2_submit_condor_indexing.sh ...
  ```

  If no CrystFEL environment is set up, `3_exec_indexing.sh` sources
  `$CRYSTFEL_SETUP`, which is CrystFEL 0.9.1 by default, the same as before.
- Each job log now begins with the host, the `indexamajig` path and its version.

### Fixed
- All options given with `-e` are passed to indexamajig. Before, only the first
  one was passed and the rest were dropped.
- Option names in the examples: `--min-srn` is now `--min-snr`, and
  `--min-fradient` is now `--min-gradient`. indexamajig rejects `--min-srn`.
- The `-i` usage message now lists `smallcell` (CrystFEL 0.12.0 or newer).

### Note for CrystFEL 0.10 or newer
These scripts run indexamajig with `--peaks=cxi`. From CrystFEL 0.10 on, the
geometry file must say where the peak list is. Otherwise no peaks are read and
nothing is indexed:

```
peak_list = /entry_1/result_1
peak_list_type = cxi
```

CrystFEL 0.9.1 ignores these lines, so you can add them to your geometry file
whichever version you use.

Commits: 2495651, acf3fde, be9f7fc, d74d2a3
