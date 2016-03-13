##
# Extraction of the 
# That AWK script extracts a list of abbreviations for country states,
# from the Geonames-derived 'allCountries_w_alt.txt' data file:
#
# See ../geonames/data/por/admin/aggregateGeonamesPor.sh for more details on
# the way to derive that file from Geonames original data files.
#

##
# Sample input lines:
# ^^^3455077^Paraná^Parana^-24.5^-51.33333^BR^^Brazil^South America^A^ADM1^18^Paraná^Parana^^^^^^10439601^^672^America/Sao_Paulo^-2.0^-3.0^-3.0^2015-06-08^Estado de Parana,Estado de Paraná,Estado do Parana,Estado do Paraná,PR,Parana,Paraná^http://en.wikipedia.org/wiki/Paran%C3%A1_%28state%29^|Paraná|ps||Estado do Paraná||abbr|PR||es|Estado de Paraná|p|es|Paraná|s
#
# Sample output lines:
# AU^08^Western Australia^WA


##
# Helper functions
@include "awklib/geo_lib.awk"

##
# Initialisation
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "extract_states.awk"

    # List of selected countries
	ctry_list["US"] = 1
	ctry_list["CA"] = 1
	ctry_list["BR"] = 1
	ctry_list["AR"] = 1
	ctry_list["AU"] = 1

	# Header
	hdr_line = "ctry_code^geo_id^adm1_code^adm1_name^abbr"
	print (hdr_line)
}


##
# POR entries corresponding to country states:
# ^^^3455077^Paraná^Parana^-24.5^-51.33333^BR^^Brazil^South America^A^ADM1^18^Paraná^Parana^^^^^^10439601^^672^America/Sao_Paulo^-2.0^-3.0^-3.0^2015-06-08^Estado de Parana,Estado de Paraná,Estado do Parana,Estado do Paraná,PR,Parana,Paraná^http://en.wikipedia.org/wiki/Paran%C3%A1_%28state%29^|Paraná|ps||Estado do Paraná||abbr|PR||es|Estado de Paraná|p|es|Paraná|s
#
/^\^\^\^([0-9]{1,12})\^.*\^([0-9]{4}-[0-9]{2}-[0-9]{2})/ {
  # Geonames ID
  geo_id = $4

  # Country code
  ctry_code = $9

  # Geonames feature code
  feat_code = $14

  if (ctry_code in ctry_list && feat_code == "ADM1") {
    adm1_code = $15
    state_name = $16
    alt_names = $33

    # Parse the section of alternate names
	sep_saved = FS
    OFS = "|"; FS = OFS
    $0 = alt_names

    for (idx=0; idx < NF; idx++) {
      if ($idx == "abbr") {
        print (ctry_code "^" geo_id "^" adm1_code "^" state_name "^" $(idx+1))
        idx = NF
		break
      }
    }

    FS = sep_saved
  }
}

