# commands

run `psql` for shell access

- `\d` schema and table information.
- `\i` to read commands from a file.
- `\o` to write output to a file.
- `\a` toggles aligned output (e.g., for JSON export).
- `\h` for help.
- Tab auto-completion can be very helpful.

export as json:

```
\a
\o plan.json
EXPLAIN (ANALYZE, FORMAT JSON, VERBOSE, BUFFERS ON)
	<your query>
\o
```
