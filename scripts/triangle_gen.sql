create table r as select (random()*100)::int as a, (random()*30)::int as b
       from generate_series(1, 20000);
create table s as select (random()*100)::int as b, (random()*20)::int as c
       from generate_series(1, 2000);
create table t as select (random()*50)::int as a, (random()*40)::int as c
       from generate_series(1, 20000);
