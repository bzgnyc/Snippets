# Snippets 
A collection of code snippets


## Contents
- [RFC 4180 CSV parser in AWK](#csvparse)

## RFC 4180 CSV parser in AWK
Parse CSV files that follow RFC 4180 (e.g. quoted strings) in AWK:

    awk -F, -f csvparse.awk -f _yourmain.awk_ < _input.csv_

Additionally FS (e.g. via -F) may be set to any character for parsing any Character-Seperated-Values file and not just Comman Seperated Values files.
