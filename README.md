# simple-supervisor

> A basic supervisor designed to automatically restart a crashed process. It can be utilized to run and restart any application.

## Usage

```
simple-supervisor [options] <command> [args...]
```

### Options

- `--max <number>`	Maximum number of restarts (Default to 0, which means unlimited).
- `--on-success`	Restart the process even if it exited with 0 (If not set, the supervisor will restart processes only if it exited with non-zero code).
- `--help`, `-h`	Print help message.
- `--version`, `-v`	Print version.
