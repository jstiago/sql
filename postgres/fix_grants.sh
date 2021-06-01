#!/bin/bash -ex

schema=${1}

psql <<EOF
  \set ON_ERROR_STOP on
  GRANT SELECT ON ALL TABLES IN SCHEMA ${schema} TO read_only;
  GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ${schema} TO read_write;
  GRANT USAGE ON ALL SEQUENCES IN SCHEMA ${schema} TO read_write;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA ${schema} TO read_write;
EOF