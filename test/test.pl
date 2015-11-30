:- use_module(library(ansi_ext)).
:- use_module(library(assoc_ext)).
:- use_module(library(atom_ext)).
:- use_module(library(char_ext)).
:- use_module(library(chr_ext)).
:- use_module(library(cli_ext)).
:- use_module(library(closure)).
:- use_module(library(code_ext)).
:- use_module(library(counter)).
:- use_module(library(csv_ext)).
:- use_module(library(date_ext)).
:- use_module(library(db_ext)).
%/datetime
  :- use_module(library(datetime/rfc3339)).
%/dcg
  %:- use_module(library(dcg/dcg_abnf)).
  :- use_module(library(dcg/dcg_arrow)).
  :- use_module(library(dcg/dcg_ascii)).
  :- use_module(library(dcg/dcg_atom)).
  :- use_module(library(dcg/dcg_bracket)).
  :- use_module(library(dcg/dcg_call)).
  :- use_module(library(dcg/dcg_cardinal)).
  :- use_module(library(dcg/dcg_char)).
  :- use_module(library(dcg/dcg_code)).
  :- use_module(library(dcg/dcg_collection)).
  :- use_module(library(dcg/dcg_content)).
  :- use_module(library(dcg/dcg_debug)).
  :- use_module(library(dcg/dcg_file)).
  :- use_module(library(dcg/dcg_list)).
  :- use_module(library(dcg/dcg_msg)).
  :- use_module(library(dcg/dcg_option)).
  :- use_module(library(dcg/dcg_peek)).
  :- use_module(library(dcg/dcg_phrase)).
  :- use_module(library(dcg/dcg_pl)).
  :- use_module(library(dcg/dcg_quote)).
  :- use_module(library(dcg/dcg_split)).
  :- use_module(library(dcg/dcg_strip)).
  :- use_module(library(dcg/dcg_table)).
  :- use_module(library(dcg/dcg_unicode)).
  :- use_module(library(dcg/dcg_word)).
  :- use_module(library(dcg/dcg_word_wrap)).
  :- use_module(library(dcg/rfc2234)).
:- use_module(library(debug_ext)).
:- use_module(library(default)).
:- use_module(library(dict_ext)).
:- use_module(library(dlist)).
%/fca
  :- use_module(library(fca/fca)).
:- use_module(library(flag_ext)).
%/graph
  :- use_module(library(graph/betweenness)).
  :- use_module(library(graph/graph_closure)).
  :- use_module(library(graph/graph_traverse)).
  :- use_module(library(graph/graph_walk)).
  % /l
    :- use_module(library(graph/l/l_graph)).
  % /s
    :- use_module(library(graph/s/s_edge)).
    :- use_module(library(graph/s/s_graph)).
    :- use_module(library(graph/s/s_metrics)).
    :- use_module(library(graph/s/s_subgraph)).
    :- use_module(library(graph/s/s_test)).
    :- use_module(library(graph/s/s_type)).
    :- use_module(library(graph/s/s_vertex)).
:- use_module(library(hash_ext)).
%/html
  :- use_module(library(html/html_dcg)).
  :- use_module(library(html/html_dom)).
  :- use_module(library(html/html_resource)).
%/http
  %:- use_module(library(http/abnf_list)).
  :- use_module(library(http/csp2)).
  :- use_module(library(http/dcg_http)).
  :- use_module(library(http/http_download)).
  :- use_module(library(http/http_info)).
  :- use_module(library(http/http_receive)).
  :- use_module(library(http/http_reply)).
  :- use_module(library(http/http_request)).
  :- use_module(library(http/http_server)).
  :- use_module(library(http/rfc2109)).
  :- use_module(library(http/rfc2616)).
  :- use_module(library(http/rfc2616_code)).
  :- use_module(library(http/rfc2616_date)).
  :- use_module(library(http/rfc2616_header)).
  :- use_module(library(http/rfc2616_test)).
  :- use_module(library(http/rfc2616_token)).
  :- use_module(library(http/rfc2617)).
  :- use_module(library(http/rfc4790)).
  :- use_module(library(http/rfc5987_code)).
  :- use_module(library(http/rfc5987_token)).
  :- use_module(library(http/rfc6266)).
  :- use_module(library(http/rfc6454)).
  :- use_module(library(http/rfc6454_code)).
  :- use_module(library(http/rfc6797)).
:- use_module(library(image_ext)).
%/iri
  :- use_module(library(iri/iri_ext)).
  :- use_module(library(iri/rfc3987)).
  :- use_module(library(iri/rfc3987_code)).
  :- use_module(library(iri/rfc3987_component)).
  :- use_module(library(iri/rfc3987_token)).
:- use_module(library(json_ext)).
:- use_module(library(list_ext)).
:- use_module(library(list_script)).
%/ltag
  :- use_module(library(ltag/ltag_match)).
  :- use_module(library(ltag/rfc1766)).
  :- use_module(library(ltag/rfc3066)).
  :- use_module(library(ltag/rfc4646)).
  :- use_module(library(ltag/rfc4647)).
  :- use_module(library(ltag/rfc5646)).
%/math
  :- use_module(library(math/dimension)).
  :- use_module(library(math/math_ext)).
  :- use_module(library(math/positional)).
  :- use_module(library(math/radconv)).
  :- use_module(library(math/rational_ext)).
:- use_module(library(memoization)).
:- use_module(library(msg_ext)).
%/nlp
  :- use_module(library(nlp/nlp_dictionary)).
  :- use_module(library(nlp/nlp_emoticon)).
  :- use_module(library(nlp/nlp_grammar)).
:- use_module(library(option_ext)).
%/os
  :- use_module(library(os/archive_ext)).
  :- use_module(library(os/call_on_stream)).
  :- use_module(library(os/datetime_file)).
  :- use_module(library(os/dir_ext)).
  :- use_module(library(os/external_program)).
  :- use_module(library(os/file_ext)).
  :- use_module(library(os/gnu_plot)).
  :- use_module(library(os/gnu_sort)).
  :- use_module(library(os/gnu_wc)).
  :- use_module(library(os/io_ext)).
  :- use_module(library(os/open_any2)).
  :- use_module(library(os/os_ext)).
  :- use_module(library(os/pdf)).
  :- use_module(library(os/process_ext)).
  :- use_module(library(os/thread_counter)).
  :- use_module(library(os/thread_ext)).
  :- use_module(library(os/tts)).
:- use_module(library(pair_ext)).
%/pl
  :- use_module(library(pl/pl_term)).
:- use_module(library(print_ext)).
:- use_module(library(progress)).
%/rest
  :- use_module(library(rest/rest_ext)).
:- use_module(library(service_db)).
%/set
  :- use_module(library(set/direct_subset)).
  :- use_module(library(set/equiv)).
  :- use_module(library(set/intersection)).
  :- use_module(library(set/ordset_closure)).
  :- use_module(library(set/poset)).
  :- use_module(library(set/reflexive_closure)).
  :- use_module(library(set/relation)).
  :- use_module(library(set/relation_closure)).
  :- use_module(library(set/set_ext)).
  :- use_module(library(set/set_ext_experimental)).
  :- use_module(library(set/symmetric_closure)).
  :- use_module(library(set/transitive_closure)).
%/sgml
  :- use_module(library(sgml/sgml_ext)).
:- use_module(library(stream_ext)).
:- use_module(library(string_ext)).
%/svg
  :- use_module(library(svg/svg_dom)).
:- use_module(library(typecheck)).
:- use_module(library(typeconv)).
%/uri
  :- use_module(library(uri/rfc2396)).
  :- use_module(library(uri/rfc2396_code)).
  :- use_module(library(uri/rfc2396_token)).
  :- use_module(library(uri/rfc3986)).
  :- use_module(library(uri/rfc3986_code)).
  :- use_module(library(uri/rfc3986_component)).
  :- use_module(library(uri/rfc3986_token)).
  :- use_module(library(uri/uri_ext)).
  :- use_module(library(uri/uri_file_name)).
%/url
  :- use_module(library(url/rfc1738)).
  :- use_module(library(url/rfc1738_code)).
  :- use_module(library(url/rfc1738_component)).
  :- use_module(library(url/rfc1738_file)).
  :- use_module(library(url/rfc1738_ftp)).
  :- use_module(library(url/rfc1738_gopher)).
  :- use_module(library(url/rfc1738_http)).
:- use_module(library(uuid_ext)).
%/xml
  :- use_module(library(xml/xml_dom)).
  :- use_module(library(xml/xml10_code)).
  :- use_module(library(xml/xml11_code)).
%/xpath
  :- use_module(library(xpath/xpath_table)).
