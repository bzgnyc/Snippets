# Snippets

A collection of code snippets


## Contents

- [RFC 4180 CSV parser in AWK](#RFC-4180-CSV-parser-in-AWK)
- [Snapshots to Delta/Effective Dated Tables in SQL](#Snapshots-to-deltaeffective-dated-tables-in-SQL)


## RFC 4180 CSV parser in AWK

Parse CSV files that follow RFC 4180 (e.g. quoted strings) in AWK:

> awk -F, -f csvparse.awk -f *yourmain.awk* < *input.csv*

Additionally FS (e.g. via -F) may be set to any character for parsing any Character-Seperated-Values file and not just Comman Seperated Values files.  *csvparse.awk* has been tested with Brian Kernighan's AWK, BSD AWK, GAWK, and MAWK.


## Snapshots to Delta/Effective Dated Tables in SQL

SQL code to create delta/effective-dated tables from snapshots
