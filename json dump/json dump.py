import os
import json

QUERY = "SELECT a,b,c FROM r NATURAL JOIN s NATURAL JOIN t;"


def get_json(query: str) -> str:
    output = os.popen(
        f'psql postgres -c "explain (analyze, verbose, costs, settings, buffers, wal, timing, summary, format json) {query};"'
    ).read()
    output = output.splitlines()[2:-2]
    for i in range(len(output)):
        if len(output[i]) > 2:
            output[i] = output[i][:-1]
    output = "\n".join(output)
    output = json.dumps(json.loads(output), indent=2)
    return output


def dump_to_file(output: str, output_path):
    with open(output_path, "w") as f:
        f.write(output)


current_dir = os.path.dirname(os.path.realpath(__file__))
output_path = os.path.join(current_dir, "dump.json")
res = get_json(QUERY)
dump_to_file(res, output_path)
print("done")
