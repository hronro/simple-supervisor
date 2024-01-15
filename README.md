# simple-supervisor

> A simple supervisor for rerunning a process when it crashed. It can be used to run and restart any application.

## Usage

```
simple-supervisor [options] <command> [args...]
```

### Options

- `--max <number>`	Maximum number of restarts (Default to 0, which means unlimited).
- `--on-success`	Rerun the process even if it exited with 0 (If not set, the supervisor will rerun processes only if it exited with non-zero code).
- `--help`, `-h`	Print help message.
- `--version`, `-v`	Print version.