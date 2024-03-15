#
# Usage: awk -F, -f awkparse.awk -f main.awk < input > output
#
# Single line version without comments for copy-paste
# length(FS) == 1 { c=0; s=$0; $0=""; trailingfs=0; while(s) { c++; if ( match(s,"^\"(\"\"|[^\"])*(\"|$)") > 0 ) { if ( substr(s,RLENGTH,1) == "\"" ) { t=substr(s,RSTART+1,RLENGTH-1-1); gsub("\"\"","\"",t); $(c)=t; if ( length(s) == RLENGTH+1 ) trailingfs=1; } else { getline sa; NR--; c--; s = s RS sa; RLENGTH=-1; } } else if ( match(s,"^[^" FS "]*([" FS "]|$)") > 0 ) { if ( substr(s,RLENGTH,1) == FS ) { if ( RLENGTH == length(s) ) trailingfs=1; RLENGTH--; } else if ( substr(s,RLENGTH,1) == "\r" ) RLENGTH--; $(c)=substr(s,RSTART,RLENGTH); } else { printf "Internal error: at filename:lineno:col=%s:%d:%d\n",FILENAME,FNR,c >"/dev/stderr"; exit 1; } if ( trailingfs==1 ) { $(c+1)=""; s=""; } else s=substr(s,RLENGTH+1+1); } }
# 
#
# This follows RFC 4180 with additional capability/logic:
#   - FS may be set to any single character to support any Character-Seperated-Values file and not just Comma Seperated Value files
#   - Trailing FS generate an additional null field to match Brian Kernighan's --csv behavior/pass his test cases/stay consistent with regular AWK behavior
#   - If RS = LF (i.e. awk's default on UNIX systems) both LF and CRLF are supported as line terminators
#   - Otherwise CR immediately preceeding the RS value will be ignored/thrown away
#   - Blank records are ignored
#   - DQUOTE in non-escaped fields are preserved
#   - Binary data in escaped fields should be preserved depending on the AWK interpreter
#   - CR / LF in escaped fields may need to be translated to native EOL by calling program
#   - The character following a closing DQUOTE of an escaped field is assumed to be the FS but no error will be generated even if it isn't
#
#


# Multicharacter and regular expression field seperators are not supported
length(FS) == 1 {
	# Initialize for the loop through input record
	_csvparse_c=0;
	_csvparse_s=$0; $0=""; _csvparse_trailingfs=0;
	while(_csvparse_s) {
		_csvparse_c++;
		# Fields starting with DQUOTE ignore FS through the closing DQUOTE
		#   Two DQUOTE don't count as closing DQUOTE as they will become one DQUOTE
		if ( match(_csvparse_s,"^\"(\"\"|[^\"])*(\"|$)") > 0 ) {
			# If match through DQUOTE then process everything inbetween as the field contents
			if ( substr(_csvparse_s,RLENGTH,1) == "\"" ) {
				# Field is everything between beginning and ending DQUOTE
				_csvparse_t=substr(_csvparse_s,RSTART+1,RLENGTH-1-1);
				# Replace two DQUOTE with one
				gsub("\"\"","\"",_csvparse_t); $(_csvparse_c)=_csvparse_t;
				# If exactly one character remaining on the line assume it is a trailing FS
				if ( length(_csvparse_s) == RLENGTH+1 ) _csvparse_trailingfs=1;
			} else {
				# Otherwise reached EOL before closing DQUOTE and process as a multiline field (i.e. field with embedded CRLF)
				# Reset to parse field again with next line appended to current
				getline _csvparse_sa; NR--; _csvparse_c--;
				_csvparse_s = _csvparse_s RS _csvparse_sa;
			 	# This will retain all of s when advancing below
				RLENGTH=-1;
			}
		} else
			# Field doesn't start with DQUOTE so match everything up to FS or EOL
			if ( match(_csvparse_s,"^[^" FS "]*([" FS "]|$)") > 0 ) {
				# Only grab through character prior to FS
				if ( substr(_csvparse_s,RLENGTH,1) == FS ) {
					# If the line ends on the FS this is a trailing FS
					if ( RLENGTH == length(_csvparse_s) )
						_csvparse_trailingfs=1;
					RLENGTH--;
				} else
					# Check if CR before EOL for UNIX systems (i.e. if RS=LF this handles CRLF on UNIX systems)
					if ( substr(_csvparse_s,RLENGTH,1) == "\r" )
						RLENGTH--;
				$(_csvparse_c)=substr(_csvparse_s,RSTART,RLENGTH);
			} else {
				# Should not be possible to get here so abort
				printf "Internal error: at filename:lineno:col=%s:%d:%d\n",FILENAME,FNR,_csvparse_c >"/dev/stderr"; exit 1;
			}
		if ( _csvparse_trailingfs==1 ) {
			# Set next field to null so that NF is correct and set s to blank to end processing of this record
			$(_csvparse_c+1)=""; _csvparse_s="";
		} else
			# Advance s to character following FS
			_csvparse_s=substr(_csvparse_s,RLENGTH+1+1);
	}
}
