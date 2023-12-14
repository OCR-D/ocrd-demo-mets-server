# METS Server demo

cf. `Makefile` for the code

## Usage

`make clone` to download the workspace

`make sequential` to run workflow in sequence

`make start-server &` to start the METS server (in the background)

`make parallel` to run workflow in parallel page-wise (with timeouts and error fallback)

`make parallel-chunks` to run workflow in parallel job-wise (without error handling)

`ocrd workspace list-page --help` for the partitioning/chunking options

`make rm-sequential` and `make rm-parallel` to remove the workspaces

Variables:
- `PROCESSOR` - which processor to run. Defaults to ocrd-vandalize
- `NUMBER_OF_THREADS` - how many jobs to run in parallel
- `ECHO` - set to `echo` to dry-run

## Benchmark

On a machine w/ 8 cores.

Sequential:

```
169.31user 6.58system 2:55.65elapsed 100%CPU (0avgtext+0avgdata 209488maxresident)
0inputs+1445976outputs (0major+3411932minor)pagefaults 0swaps
/usr/bin/time make sequential  169.32s user 6.59s system 100% cpu 2:55.65 total
```

Parallel chunks w/4 jobs:

```
164.22user 6.89system 0:47.53elapsed 359%CPU (0avgtext+0avgdata 192548maxresident)k
0inputs+1274824outputs (0major+3642408minor)pagefaults 0swaps
/usr/bin/time make parallel-chunks NUMBER_OF_THREADS=4  164.22s user 6.90s system 359% cpu 47.536 total
```

Parallel chunks w/8 jobs

```
226.84user 9.27system 0:34.18elapsed 690%CPU (0avgtext+0avgdata 191928maxresident)k
0inputs+1274856outputs (0major+3827022minor)pagefaults 0swaps
/usr/bin/time make parallel-chunks NUMBER_OF_THREADS=8  226.85s user 9.28s system 690% cpu 34.188 total
```

Parallel chunks w/16 jobs (sanity check)

```
252.12user 11.21system 0:35.84elapsed 734%CPU (0avgtext+0avgdata 191968maxresident)k
400inputs+1274920outputs (19major+4210729minor)pagefaults 0swaps
/usr/bin/time make parallel-chunks NUMBER_OF_THREADS=16  252.13s user 11.21s system 734% cpu 35.850 total
```

Parallel page-wise w/8 jobs

```
422.27user 53.79system 1:35.12elapsed 500%CPU (0avgtext+0avgdata 161360maxresident)k
2616inputs+1305872outputs (11major+10164013minor)pagefaults 0swaps
/usr/bin/time make parallel  422.28s user 53.79s system 500% cpu 1:35.13 total
```
