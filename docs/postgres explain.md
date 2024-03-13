# using `EXPLAIN` to analyze queries

```sql
/*
flags:

- ANALYZE        run command
- VERBOSE        show intermediary results
- COSTS          show costs for all nodes
- SETTINGS       show config params
- GENERIC_PLAN   use arguments like $1 (can't be used with ANALYZE)
- BUFFERS        show buffer usage:(blocks hit, read, dirtied, written)
- WAL            show write ahead log stats (used for data integrity)
- TIMING         show exact times (active by default with ANALAYZE)
- SUMMARY        show summary (active by default with ANALAYZE)
- FORMAT { TEXT | XML | JSON | YAML }
*/

EXPLAIN (ANALYZE, /* arguments */)
	/* SQL statement */
;
```

_docs_

- https://www.postgresql.org/docs/current/sql-explain.html
- https://www.postgresql.org/docs/9.5/using-explain.html
- overview: https://www.postgresql.org/docs/current/index.html
- performance tips: https://www.postgresql.org/docs/current/performance-tips.html
- glossary: https://www.pgmustard.com/docs/explain

_visualization tools_

- https://tatiyants.com/pev/
     - source: https://github.com/AlexTatiyants/pev/
- https://explain.dalibo.com/
     - source: https://github.com/dalibo/pev2
- https://www.pgexplain.dev/ (pev2 but with a backend)
     - source: https://github.com/lfborjas/postgres-explain-visualizer
- https://explain.depesz.com/
- https://explain-postgresql.com/
